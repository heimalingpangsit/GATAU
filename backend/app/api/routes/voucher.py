import uuid

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.deps import require_owner
from app.models.schemas import Voucher, VoucherCreate
from app.services.cache_service import cache_service
from app.services.github_service import github_service

router = APIRouter(prefix="/api/vouchers", tags=["vouchers"])
VOUCHER_FILE = "vouchers.json"
CACHE_KEY = "vouchers:list"


@router.get("", response_model=list[Voucher])
async def list_vouchers(claims: dict = Depends(require_owner)):
    return await github_service.read_json(VOUCHER_FILE, [])


@router.post("/validate")
async def validate_voucher(code: str, subtotal: int):
    """Endpoint publik dipakai saat checkout untuk cek & hitung diskon."""
    vouchers = await github_service.read_json(VOUCHER_FILE, [])
    v = next((x for x in vouchers if x["code"].lower() == code.lower()), None)
    if not v or not v.get("active", True):
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Voucher tidak ditemukan / tidak aktif")
    if v.get("quota") is not None and v.get("used_count", 0) >= v["quota"]:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Kuota voucher sudah habis")
    if subtotal < v.get("min_purchase", 0):
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            f"Minimal belanja Rp{v['min_purchase']:,} untuk pakai voucher ini",
        )
    if v["type"] == "percentage":
        discount = int(subtotal * v["value"] / 100)
        if v.get("max_discount"):
            discount = min(discount, v["max_discount"])
    else:
        discount = v["value"]
    discount = min(discount, subtotal)
    return {"code": v["code"], "discount": discount}


@router.post("", response_model=Voucher, status_code=status.HTTP_201_CREATED)
async def create_voucher(payload: VoucherCreate, claims: dict = Depends(require_owner)):
    new_v = Voucher(id=str(uuid.uuid4()), used_count=0, **payload.model_dump())

    def mutate(current: list[dict]) -> list[dict]:
        current.append(new_v.model_dump())
        return current

    await github_service.update_collection(
        VOUCHER_FILE, mutate, [], f"feat(voucher): tambah voucher '{payload.code}'"
    )
    return new_v


@router.put("/{voucher_id}", response_model=Voucher)
async def update_voucher(voucher_id: str, payload: VoucherCreate, claims: dict = Depends(require_owner)):
    holder: dict = {}

    def mutate(current: list[dict]) -> list[dict]:
        for item in current:
            if item["id"] == voucher_id:
                item.update(payload.model_dump())
                holder["item"] = item
                break
        else:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Voucher tidak ditemukan")
        return current

    await github_service.update_collection(
        VOUCHER_FILE, mutate, [], f"feat(voucher): update {voucher_id}"
    )
    return holder["item"]


@router.delete("/{voucher_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_voucher(voucher_id: str, claims: dict = Depends(require_owner)):
    def mutate(current: list[dict]) -> list[dict]:
        return [i for i in current if i["id"] != voucher_id]

    await github_service.update_collection(
        VOUCHER_FILE, mutate, [], f"feat(voucher): hapus {voucher_id}"
    )
