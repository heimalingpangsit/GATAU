import random
import string
import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException, status

from app.models.schemas import CheckoutRequest, Order, OrderItem, OrderStatus
from app.services.cache_service import cache_service
from app.services.github_service import github_service
from app.services.pakasir_service import pakasir_service

router = APIRouter(prefix="/api/checkout", tags=["checkout"])

ORDERS_FILE = "orders.json"


def _generate_order_number() -> str:
    today = datetime.now(timezone.utc).strftime("%y%m%d")
    rand = "".join(random.choices(string.digits, k=4))
    return f"KDZ-{today}-{rand}"


@router.post("", response_model=Order, status_code=status.HTTP_201_CREATED)
async def checkout(payload: CheckoutRequest):
    cart = await cache_service.get_cart(payload.session_id)
    if not cart or not cart.get("items"):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Keranjang kosong")

    menu = await github_service.read_json("menu.json", [])
    menu_by_id = {m["id"]: m for m in menu}

    order_items: list[OrderItem] = []
    subtotal = 0
    for it in cart["items"]:
        m = menu_by_id.get(it["menu_id"])
        if not m or not m.get("is_available"):
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST, f"Menu '{it['menu_id']}' sudah tidak tersedia"
            )
        line_subtotal = m["price"] * it["qty"]
        subtotal += line_subtotal
        order_items.append(
            OrderItem(
                menu_id=m["id"],
                name=m["name"],
                price=m["price"],
                qty=it["qty"],
                subtotal=line_subtotal,
                notes=it.get("notes", ""),
            )
        )

    discount = 0
    if payload.voucher_code:
        vouchers = await github_service.read_json("vouchers.json", [])
        v = next((x for x in vouchers if x["code"].lower() == payload.voucher_code.lower()), None)
        if not v or not v.get("active", True):
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Voucher tidak valid")
        if v["type"] == "percentage":
            discount = int(subtotal * v["value"] / 100)
            if v.get("max_discount"):
                discount = min(discount, v["max_discount"])
        else:
            discount = v["value"]
        discount = min(discount, subtotal)

    total = subtotal - discount
    order_id = str(uuid.uuid4())
    now = datetime.now(timezone.utc).isoformat()

    order = Order(
        id=order_id,
        order_number=_generate_order_number(),
        customer_name=payload.customer_name,
        customer_whatsapp=payload.customer_whatsapp,
        order_type=payload.order_type,
        address=payload.address,
        items=order_items,
        subtotal=subtotal,
        discount=discount,
        voucher_code=payload.voucher_code,
        total=total,
        payment_method=payload.payment_method,
        status=OrderStatus.pending_payment,
        created_at=now,
        updated_at=now,
    )

    # 1. Buat transaksi QRIS di Pakasir dulu (agar tahu link QR sebelum commit order)
    pakasir_resp = await pakasir_service.create_transaction(
        order_id=order.order_number, amount=total
    )
    order.qris_url = pakasir_resp.get("qr_url") or pakasir_resp.get("payment_url")
    order.pakasir_transaction_id = pakasir_resp.get("transaction_id") or pakasir_resp.get("id")

    # 2. Simpan order ke GitHub (source of truth)
    def mutate(current: list[dict]) -> list[dict]:
        current.append(order.model_dump())
        return current

    await github_service.update_collection(
        ORDERS_FILE, mutate, [], f"feat(order): order baru {order.order_number}"
    )

    # 3. Naikkan used_count voucher jika dipakai
    if payload.voucher_code:
        def mutate_voucher(current: list[dict]) -> list[dict]:
            for v in current:
                if v["code"].lower() == payload.voucher_code.lower():
                    v["used_count"] = v.get("used_count", 0) + 1
            return current

        await github_service.update_collection(
            "vouchers.json", mutate_voucher, [], f"chore(voucher): pakai {payload.voucher_code}"
        )

    # 4. Bersihkan cart
    await cache_service.clear_cart(payload.session_id)
    await cache_service.log_event("checkout", {"order_number": order.order_number, "total": total})

    return order
