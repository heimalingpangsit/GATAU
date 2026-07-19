import uuid

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.deps import require_owner
from app.models.schemas import Banner, BannerCreate
from app.services.cache_service import cache_service
from app.services.github_service import github_service

router = APIRouter(prefix="/api/banners", tags=["banners"])
BANNER_FILE = "banners.json"
CACHE_KEY = "banners:list"


@router.get("", response_model=list[Banner])
async def list_banners(active_only: bool = True):
    cached = await cache_service.get_cache(CACHE_KEY)
    items = cached if cached is not None else await github_service.read_json(BANNER_FILE, [])
    if cached is None:
        await cache_service.set_cache(CACHE_KEY, items)
    if active_only:
        items = [i for i in items if i.get("active", True)]
    return sorted(items, key=lambda x: x.get("order", 0))


@router.post("", response_model=Banner, status_code=status.HTTP_201_CREATED)
async def create_banner(payload: BannerCreate, claims: dict = Depends(require_owner)):
    new_b = Banner(id=str(uuid.uuid4()), **payload.model_dump())

    def mutate(current: list[dict]) -> list[dict]:
        current.append(new_b.model_dump())
        return current

    await github_service.update_collection(
        BANNER_FILE, mutate, [], f"feat(banner): tambah banner '{payload.title}'"
    )
    await cache_service.invalidate(CACHE_KEY)
    return new_b


@router.put("/{banner_id}", response_model=Banner)
async def update_banner(banner_id: str, payload: BannerCreate, claims: dict = Depends(require_owner)):
    holder: dict = {}

    def mutate(current: list[dict]) -> list[dict]:
        for item in current:
            if item["id"] == banner_id:
                item.update(payload.model_dump())
                holder["item"] = item
                break
        else:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Banner tidak ditemukan")
        return current

    await github_service.update_collection(
        BANNER_FILE, mutate, [], f"feat(banner): update {banner_id}"
    )
    await cache_service.invalidate(CACHE_KEY)
    return holder["item"]


@router.delete("/{banner_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_banner(banner_id: str, claims: dict = Depends(require_owner)):
    def mutate(current: list[dict]) -> list[dict]:
        return [i for i in current if i["id"] != banner_id]

    await github_service.update_collection(
        BANNER_FILE, mutate, [], f"feat(banner): hapus {banner_id}"
    )
    await cache_service.invalidate(CACHE_KEY)
