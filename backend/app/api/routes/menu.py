import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.deps import require_owner
from app.models.schemas import MenuItem, MenuItemCreate, MenuItemUpdate
from app.services.cache_service import cache_service
from app.services.github_service import github_service

router = APIRouter(prefix="/api/menu", tags=["menu"])
MENU_FILE = "menu.json"
CACHE_KEY = "menu:list"


@router.get("", response_model=list[MenuItem])
async def list_menu(only_available: bool = False):
    """Endpoint publik (buyer tanpa login). Dibaca lewat cache dulu."""
    cached = await cache_service.get_cache(CACHE_KEY)
    items = cached if cached is not None else await github_service.read_json(MENU_FILE, [])
    if cached is None:
        await cache_service.set_cache(CACHE_KEY, items)
    if only_available:
        items = [i for i in items if i.get("is_available")]
    return items


@router.post("", response_model=MenuItem, status_code=status.HTTP_201_CREATED)
async def create_menu(payload: MenuItemCreate, claims: dict = Depends(require_owner)):
    now = datetime.now(timezone.utc).isoformat()
    new_item = MenuItem(id=str(uuid.uuid4()), created_at=now, updated_at=now, **payload.model_dump())

    def mutate(current: list[dict]) -> list[dict]:
        current.append(new_item.model_dump())
        return current

    await github_service.update_collection(
        MENU_FILE, mutate, [], f"feat(menu): tambah menu '{payload.name}'"
    )
    await cache_service.invalidate(CACHE_KEY)
    return new_item


@router.put("/{menu_id}", response_model=MenuItem)
async def update_menu(menu_id: str, payload: MenuItemUpdate, claims: dict = Depends(require_owner)):
    updated_holder: dict = {}

    def mutate(current: list[dict]) -> list[dict]:
        for item in current:
            if item["id"] == menu_id:
                item.update({k: v for k, v in payload.model_dump().items() if v is not None})
                item["updated_at"] = datetime.now(timezone.utc).isoformat()
                updated_holder["item"] = item
                break
        else:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Menu tidak ditemukan")
        return current

    await github_service.update_collection(
        MENU_FILE, mutate, [], f"feat(menu): update menu {menu_id}"
    )
    await cache_service.invalidate(CACHE_KEY)
    return updated_holder["item"]


@router.delete("/{menu_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_menu(menu_id: str, claims: dict = Depends(require_owner)):
    found = {"ok": False}

    def mutate(current: list[dict]) -> list[dict]:
        new_list = [i for i in current if i["id"] != menu_id]
        found["ok"] = len(new_list) != len(current)
        return new_list

    await github_service.update_collection(
        MENU_FILE, mutate, [], f"feat(menu): hapus menu {menu_id}"
    )
    if not found["ok"]:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Menu tidak ditemukan")
    await cache_service.invalidate(CACHE_KEY)
