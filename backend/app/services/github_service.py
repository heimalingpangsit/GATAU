"""
GitHub sebagai "database" utama.

Setiap collection (menu, voucher, banner, orders, users) disimpan sebagai
satu file JSON di dalam repo, contoh:
    data/menu.json
    data/vouchers.json
    data/banners.json
    data/orders.json
    data/users.json

Service ini menyediakan operasi read/write generik + retry, dan sebuah
async lock per-file supaya dua request yang menulis file yang sama secara
bersamaan tidak saling menimpa (read-modify-write dengan SHA git).

Catatan penting (disampaikan ke user): GitHub REST API punya rate limit
~5000 request/jam untuk token authenticated, dan setiap tulis = 1 commit.
Untuk mengurangi jumlah request, hasil READ di-cache ke MongoDB dengan TTL
pendek (lihat cache_service.py). WRITE selalu langsung ke GitHub (sumber
kebenaran), lalu cache di-refresh.
"""
from __future__ import annotations

import asyncio
import base64
import json
from collections import defaultdict
from typing import Any

import httpx
from tenacity import retry, stop_after_attempt, wait_exponential

from app.core.config import get_settings

GITHUB_API = "https://api.github.com"

# lock per path supaya read-modify-write ke file yang sama tidak race
_locks: dict[str, asyncio.Lock] = defaultdict(asyncio.Lock)


class GitHubServiceError(Exception):
    pass


class GitHubService:
    def __init__(self) -> None:
        self.settings = get_settings()

    def _headers(self) -> dict[str, str]:
        return {
            "Authorization": f"Bearer {self.settings.github_token}",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
        }

    def _contents_url(self, path: str) -> str:
        return (
            f"{GITHUB_API}/repos/{self.settings.github_owner}/"
            f"{self.settings.github_repo}/contents/{path}"
        )

    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=0.5, max=4))
    async def get_file(self, path: str) -> tuple[dict[str, Any] | list[Any] | None, str | None]:
        """Return (parsed_json, sha). If file doesn't exist -> (None, None)."""
        async with httpx.AsyncClient(timeout=15) as client:
            resp = await client.get(
                self._contents_url(path),
                headers=self._headers(),
                params={"ref": self.settings.github_branch},
            )
        if resp.status_code == 404:
            return None, None
        if resp.status_code != 200:
            raise GitHubServiceError(f"GET {path} failed: {resp.status_code} {resp.text}")
        data = resp.json()
        content = base64.b64decode(data["content"]).decode("utf-8")
        return json.loads(content), data["sha"]

    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=0.5, max=4))
    async def put_file(
        self, path: str, data: Any, message: str, sha: str | None = None
    ) -> str:
        """Create or update a JSON file in the repo. Returns new sha."""
        encoded = base64.b64encode(
            json.dumps(data, indent=2, ensure_ascii=False).encode("utf-8")
        ).decode("utf-8")
        body: dict[str, Any] = {
            "message": message,
            "content": encoded,
            "branch": self.settings.github_branch,
        }
        if sha:
            body["sha"] = sha
        async with httpx.AsyncClient(timeout=15) as client:
            resp = await client.put(
                self._contents_url(path), headers=self._headers(), json=body
            )
        if resp.status_code not in (200, 201):
            raise GitHubServiceError(f"PUT {path} failed: {resp.status_code} {resp.text}")
        return resp.json()["content"]["sha"]

    async def read_json(self, filename: str, default: Any) -> Any:
        path = f"{self.settings.github_data_path}/{filename}"
        data, _sha = await self.get_file(path)
        return data if data is not None else default

    async def write_json(self, filename: str, data: Any, message: str) -> None:
        """Direct overwrite (used internally, after acquiring lock)."""
        path = f"{self.settings.github_data_path}/{filename}"
        _current, sha = await self.get_file(path)
        await self.put_file(path, data, message, sha)

    async def update_collection(self, filename: str, mutate_fn, default: Any, message: str):
        """
        Safe read-modify-write pattern:
            new_data = mutate_fn(current_data)
        Guarded by an in-process lock per filename to avoid clobbering
        concurrent writes coming from this same backend instance.
        """
        lock = _locks[filename]
        async with lock:
            path = f"{self.settings.github_data_path}/{filename}"
            current, sha = await self.get_file(path)
            if current is None:
                current = default
            new_data = mutate_fn(current)
            await self.put_file(path, new_data, message, sha)
            return new_data


github_service = GitHubService()
