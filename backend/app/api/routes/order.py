from fastapi import APIRouter, Depends, HTTPException, status

from app.api.deps import require_owner_or_kasir
from app.models.schemas import Order, OrderStatus
from app.services.github_service import github_service
from app.services.pakasir_service import pakasir_service

router = APIRouter(prefix="/api/orders", tags=["orders"])
ORDERS_FILE = "orders.json"


@router.get("", response_model=list[Order])
async def list_orders(
    status_filter: OrderStatus | None = None,
    claims: dict = Depends(require_owner_or_kasir),
):
    orders = await github_service.read_json(ORDERS_FILE, [])
    if status_filter:
        orders = [o for o in orders if o["status"] == status_filter.value]
    return sorted(orders, key=lambda o: o["created_at"], reverse=True)


@router.get("/by-number/{order_number}", response_model=Order)
async def get_order_public(order_number: str):
    """Endpoint publik dipakai buyer untuk polling status pesanannya."""
    orders = await github_service.read_json(ORDERS_FILE, [])
    order = next((o for o in orders if o["order_number"] == order_number), None)
    if not order:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Order tidak ditemukan")
    return order


@router.post("/by-number/{order_number}/sync-payment", response_model=Order)
async def sync_payment_status(order_number: str):
    """Fallback manual jika webhook belum sampai: cek langsung ke Pakasir."""
    result = await pakasir_service.get_transaction_status(order_number)
    raw_status = str(result.get("status", "")).lower()
    status_map = {"paid": "paid", "success": "paid", "settlement": "paid", "expired": "expired"}
    new_status = status_map.get(raw_status)

    holder: dict = {}

    def mutate(current: list[dict]) -> list[dict]:
        for order in current:
            if order["order_number"] == order_number:
                if new_status:
                    order["status"] = new_status
                holder["order"] = order
                break
        else:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Order tidak ditemukan")
        return current

    await github_service.update_collection(
        ORDERS_FILE, mutate, [], f"chore(order): sync status {order_number}"
    )
    return holder["order"]


@router.put("/{order_id}/status", response_model=Order)
async def update_order_status(
    order_id: str, new_status: OrderStatus, claims: dict = Depends(require_owner_or_kasir)
):
    holder: dict = {}

    def mutate(current: list[dict]) -> list[dict]:
        for order in current:
            if order["id"] == order_id:
                order["status"] = new_status.value
                holder["order"] = order
                break
        else:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Order tidak ditemukan")
        return current

    await github_service.update_collection(
        ORDERS_FILE, mutate, [], f"feat(order): {order_id} -> {new_status.value} oleh {claims['sub']}"
    )
    return holder["order"]
