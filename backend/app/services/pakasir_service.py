"""
Integrasi QRIS Pakasir. Dokumentasi resmi: https://pakasir.com/docs
Semua panggilan dilakukan dari BACKEND (server-to-server), API key
TIDAK PERNAH dikirim ke frontend.
"""
from __future__ import annotations

from typing import Any

import httpx

from app.core.config import get_settings


class PakasirServiceError(Exception):
    pass


class PakasirService:
    def __init__(self) -> None:
        self.settings = get_settings()

    def _headers(self) -> dict[str, str]:
        return {
            "Authorization": f"Bearer {self.settings.pakasir_api_key}",
            "Content-Type": "application/json",
        }

    async def create_transaction(
        self, order_id: str, amount: int, redirect_url: str | None = None
    ) -> dict[str, Any]:
        """
        Membuat transaksi QRIS baru. Mengembalikan payload dari Pakasir
        (termasuk qr_url / payment_url yang dipakai frontend untuk
        menampilkan kode QR ke pembeli).
        """
        url = f"{self.settings.pakasir_base_url}/api/transactions"
        body = {
            "project": self.settings.pakasir_slug,
            "order_id": order_id,
            "amount": amount,
            "payment_method": "qris",
        }
        if redirect_url:
            body["redirect_url"] = redirect_url

        async with httpx.AsyncClient(timeout=15) as client:
            resp = await client.post(url, headers=self._headers(), json=body)
        if resp.status_code not in (200, 201):
            raise PakasirServiceError(
                f"Gagal membuat transaksi Pakasir: {resp.status_code} {resp.text}"
            )
        return resp.json()

    async def get_transaction_status(self, order_id: str) -> dict[str, Any]:
        url = (
            f"{self.settings.pakasir_base_url}/api/transactions/"
            f"{self.settings.pakasir_slug}/{order_id}"
        )
        async with httpx.AsyncClient(timeout=15) as client:
            resp = await client.get(url, headers=self._headers())
        if resp.status_code != 200:
            raise PakasirServiceError(
                f"Gagal cek status transaksi: {resp.status_code} {resp.text}"
            )
        return resp.json()


pakasir_service = PakasirService()
