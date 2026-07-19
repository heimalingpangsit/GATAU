import uuid

from fastapi import APIRouter, HTTPException, status

from app.models.schemas import CartItemIn, CartOut, CartItemOut
from app.services.cache_service import cache_service
from app.services.github_service import github_service

router = APIRouter(prefix="/api/cart", tags=["cart"])


async def _build_cart_out(session_id: str, raw_items: list[dict]) -> CartOut:
    menu = await github_service.read_json("menu.json", [])
    menu_by_id = {m["id"]: m for m in menu}

    items_out: list[CartItemOut] = []
    total = 0
    for it in raw_items:
        m = menu_by_id.get(it["menu_id"])
        if not m:
            continue  # menu mungkin sudah dihapus owner
        subtotal = m["price"] * it["qty"]
        total += subtotal
        items_out.append(
            CartItemOut(
                menu_id=it["menu_id"],
                qty=it["qty"],
                notes=it.get("notes", ""),
                name=m["name"],
                price=m["price"],
                subtotal=subtotal,
            )
        )
    return CartOut(session_id=session_id, items=items_out, total=total)


@router.post("/new-session")
async def new_session():
    return {"session_id": str(uuid.uuid4())}


@router.get("/{session_id}", response_model=CartOut)
async def get_cart(session_id: str):
    cart = await cache_service.get_cart(session_id)
    raw_items = cart["items"] if cart else []
    return await _build_cart_out(session_id, raw_items)


@router.post("/{session_id}/items", response_model=CartOut)
async def add_item(session_id: str, item: CartItemIn):
    menu = await github_service.read_json("menu.json", [])
    if not any(m["id"] == item.menu_id and m.get("is_available") for m in menu):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Menu tidak tersedia")

    cart = await cache_service.get_cart(session_id)
    raw_items = cart["items"] if cart else []
    for existing in raw_items:
        if existing["menu_id"] == item.menu_id and existing.get("notes", "") == item.notes:
            existing["qty"] += item.qty
            break
    else:
        raw_items.append(item.model_dump())

    await cache_service.save_cart(session_id, raw_items)
    return await _build_cart_out(session_id, raw_items)


@router.put("/{session_id}/items/{menu_id}", response_model=CartOut)
async def update_item_qty(session_id: str, menu_id: str, qty: int):
    cart = await cache_service.get_cart(session_id)
    raw_items = cart["items"] if cart else []
    if qty <= 0:
        raw_items = [i for i in raw_items if i["menu_id"] != menu_id]
    else:
        for i in raw_items:
            if i["menu_id"] == menu_id:
                i["qty"] = qty
    await cache_service.save_cart(session_id, raw_items)
    return await _build_cart_out(session_id, raw_items)


@router.delete("/{session_id}/items/{menu_id}", response_model=CartOut)
async def remove_item(session_id: str, menu_id: str):
    cart = await cache_service.get_cart(session_id)
    raw_items = [i for i in (cart["items"] if cart else []) if i["menu_id"] != menu_id]
    await cache_service.save_cart(session_id, raw_items)
    return await _build_cart_out(session_id, raw_items)


@router.delete("/{session_id}", status_code=status.HTTP_204_NO_CONTENT)
async def clear_cart(session_id: str):
    await cache_service.clear_cart(session_id)
