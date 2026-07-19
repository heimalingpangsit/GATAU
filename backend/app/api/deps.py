from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer

from app.core.security import decode_access_token
from app.models.schemas import UserRole

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login", auto_error=False)


async def get_current_claims(token: str | None = Depends(oauth2_scheme)) -> dict:
    if not token:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Belum login")
    claims = decode_access_token(token)
    if not claims:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Token tidak valid atau kadaluarsa")
    return claims


def require_role(*roles: UserRole):
    async def _checker(claims: dict = Depends(get_current_claims)) -> dict:
        if claims.get("role") not in [r.value for r in roles]:
            raise HTTPException(status.HTTP_403_FORBIDDEN, "Tidak punya akses")
        return claims

    return _checker


require_owner = require_role(UserRole.owner)
require_owner_or_kasir = require_role(UserRole.owner, UserRole.kasir)
