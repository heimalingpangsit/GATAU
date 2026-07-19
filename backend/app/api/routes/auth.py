from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.deps import get_current_claims
from app.core.config import get_settings
from app.core.security import create_access_token, hash_password, verify_password
from app.models.schemas import LoginRequest, LoginResponse, UserOut
from app.services.cache_service import cache_service
from app.services.github_service import github_service

router = APIRouter(prefix="/api/auth", tags=["auth"])

USERS_FILE = "users.json"


async def _ensure_seed_users() -> list[dict]:
    """Jika data/users.json belum ada di repo, buat dengan akun default
    dari .env (password langsung di-hash, tidak disimpan plaintext)."""
    users = await github_service.read_json(USERS_FILE, default=None)
    if users:
        return users

    settings = get_settings()
    now = datetime.now(timezone.utc).isoformat()
    seed = [
        {
            "username": settings.default_owner_username,
            "password_hash": hash_password(settings.default_owner_password),
            "role": "owner",
            "whatsapp": None,
            "active": True,
            "created_at": now,
        },
        {
            "username": settings.default_kasir_username,
            "password_hash": hash_password(settings.default_kasir_password),
            "role": "kasir",
            "whatsapp": settings.default_kasir_whatsapp,
            "active": True,
            "created_at": now,
        },
    ]
    await github_service.write_json(
        USERS_FILE, seed, "chore: seed default owner & kasir accounts"
    )
    return seed


@router.post("/login", response_model=LoginResponse)
async def login(payload: LoginRequest):
    users = await _ensure_seed_users()
    user = next((u for u in users if u["username"] == payload.username), None)
    if not user or not user.get("active", True):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Username atau password salah")
    if not verify_password(payload.password, user["password_hash"]):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Username atau password salah")

    token = create_access_token(subject=user["username"], role=user["role"])
    await cache_service.log_event(
        "login", {"username": user["username"], "role": user["role"]}
    )
    return LoginResponse(access_token=token, role=user["role"], username=user["username"])


@router.get("/me", response_model=UserOut)
async def me(claims: dict = Depends(get_current_claims)):
    users = await github_service.read_json(USERS_FILE, default=[])
    user = next((u for u in users if u["username"] == claims["sub"]), None)
    if not user:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "User tidak ditemukan")
    return UserOut(
        username=user["username"],
        role=user["role"],
        whatsapp=user.get("whatsapp"),
        active=user.get("active", True),
    )
