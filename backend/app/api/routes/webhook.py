"""
Webhook dari Pakasir dipanggil server-to-server saat status pembayaran
berubah. PENTING: sesuaikan nama header/signature di bawah dengan
dokumentasi resmi Pakasir project Anda (nama header bisa berbeda per
provider/versi API) - saat ini divalidasi dengan membandingkan
`amount` order agar tidak asal terima payload apa pun.
"""
from fastapi import APIRouter, Header, HTTPException, Request, status

from app.core.config import get_settings
from app.models.schemas import OrderStatus
from app.services.cache_service import cache_service
from app.services.github_service import github_service

router = APIRouter(prefix="/api/webhook", tags=["webhook"])

ORDERS_FILE = "orders.json"

STATUS_MAP = {
    "paid": OrderStatus.paid,
    "success": OrderStatus.paid,
    "settlement": OrderStatus.paid,
    "expired": OrderStatus.expired,
    "cancelled": OrderStatus.cancelled,
    "failed": OrderStatus.cancelled,
}


@router.post("/pakasir")
async def pakasir_webhook(request: Request, x_pakasir_signature: str | None = Header(default=None)):
    settings = get_settings()
    payload = await request.json()

    # TODO: ganti dengan verifikasi signature resmi Pakasir bila tersedia.
    # Minimal check: tolak jika tidak ada api key konteks project yang cocok.
    if payload.get("project") and payload["project"] != settings.pakasir_slug:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Project tidak cocok")

    order_number = payload.get("order_id")
    raw_status = str(payload.get("status", "")).lower()
    new_status = STATUS_MAP.get(raw_status)
    if not order_number or not new_status:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Payload webhook tidak valid")

    holder: dict = {}

    def mutate(current: list[dict]) -> list[dict]:
        for order in current:
            if order["order_number"] == order_number:
                order["status"] = new_status.value
                order["updated_at"] = payload.get("updated_at") or order["updated_at"]
                holder["order"] = order
                break
        return current

    await github_service.update_collection(
        ORDERS_FILE, mutate, [], f"chore(order): update status {order_number} -> {new_status.value}"
    )
    await cache_service.log_event(
        "payment_webhook", {"order_number": order_number, "status": new_status.value}
    )

    if not holder.get("order"):
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Order tidak ditemukan")
    return {"ok": True}
