"""
MongoDB HANYA dipakai untuk:
- cache hasil read dari GitHub (supaya tidak boros rate limit)
- session cart tamu (guest, tanpa login)
- log aktivitas / audit trail

MongoDB TIDAK PERNAH menjadi sumber data utama menu/voucher/banner/order.
GitHub tetap jadi source of truth; jika cache kosong/kadaluarsa, service
akan fallback membaca ulang dari GitHub.
"""
from __future__ import annotations

import time
from typing import Any

from motor.motor_asyncio import AsyncIOMotorClient

from app.core.config import get_settings

_client: AsyncIOMotorClient | None = None

CACHE_TTL_SECONDS = 30  # cache pendek supaya data tetap "realtime-ish"


def get_client() -> AsyncIOMotorClient:
    global _client
    if _client is None:
        settings = get_settings()
        _client = AsyncIOMotorClient(settings.mongo_uri)
    return _client


def get_db():
    settings = get_settings()
    return get_client()[settings.mongo_db_name]


class CacheService:
    async def get_cache(self, key: str) -> Any | None:
        db = get_db()
        doc = await db.cache.find_one({"_id": key})
        if not doc:
            return None
        if time.time() - doc["cached_at"] > CACHE_TTL_SECONDS:
            return None
        return doc["value"]

    async def set_cache(self, key: str, value: Any) -> None:
        db = get_db()
        await db.cache.update_one(
            {"_id": key},
            {"$set": {"value": value, "cached_at": time.time()}},
            upsert=True,
        )

    async def invalidate(self, key: str) -> None:
        db = get_db()
        await db.cache.delete_one({"_id": key})

    # ---------- Guest cart session ----------
    async def get_cart(self, session_id: str) -> dict[str, Any] | None:
        db = get_db()
        return await db.carts.find_one({"_id": session_id})

    async def save_cart(self, session_id: str, items: list[dict[str, Any]]) -> None:
        db = get_db()
        await db.carts.update_one(
            {"_id": session_id},
            {"$set": {"items": items, "updated_at": time.time()}},
            upsert=True,
        )

    async def clear_cart(self, session_id: str) -> None:
        db = get_db()
        await db.carts.delete_one({"_id": session_id})

    # ---------- Log ----------
    async def log_event(self, event_type: str, payload: dict[str, Any]) -> None:
        db = get_db()
        await db.logs.insert_one(
            {"event_type": event_type, "payload": payload, "created_at": time.time()}
        )


cache_service = CacheService()
