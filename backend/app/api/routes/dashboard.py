from collections import Counter
from datetime import datetime, timezone

from fastapi import APIRouter, Depends

from app.api.deps import require_owner, require_owner_or_kasir
from app.services.github_service import github_service

router = APIRouter(prefix="/api/dashboard", tags=["dashboard"])


@router.get("/summary")
async def summary(claims: dict = Depends(require_owner_or_kasir)):
    orders = await github_service.read_json("orders.json", [])
    today = datetime.now(timezone.utc).date().isoformat()

    paid_statuses = {"paid", "processing", "ready", "completed"}
    today_orders = [o for o in orders if o["created_at"].startswith(today)]
    today_revenue = sum(o["total"] for o in today_orders if o["status"] in paid_statuses)

    status_counts = Counter(o["status"] for o in orders)

    return {
        "today_order_count": len(today_orders),
        "today_revenue": today_revenue,
        "total_orders_all_time": len(orders),
        "status_breakdown": status_counts,
        "pending_payment_count": status_counts.get("pending_payment", 0),
    }


@router.get("/best-sellers")
async def best_sellers(limit: int = 5, claims: dict = Depends(require_owner)):
    orders = await github_service.read_json("orders.json", [])
    counter: Counter = Counter()
    for o in orders:
        if o["status"] not in {"paid", "processing", "ready", "completed"}:
            continue
        for item in o["items"]:
            counter[item["name"]] += item["qty"]
    return [{"name": name, "qty_sold": qty} for name, qty in counter.most_common(limit)]
