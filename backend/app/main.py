from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import get_settings
from app.services.github_service import GitHubServiceError
from app.services.pakasir_service import PakasirServiceError
from fastapi import Request
from fastapi.responses import JSONResponse

from app.api.routes import (
    auth,
    banner,
    cart,
    checkout,
    dashboard,
    export,
    menu,
    order,
    voucher,
    webhook,
)

settings = get_settings()

app = FastAPI(
    title=settings.app_name,
    description="POS + pemesanan online untuk KEBAB DZAQY. GitHub sebagai database utama.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.frontend_origin],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(GitHubServiceError)
async def github_error_handler(request: Request, exc: GitHubServiceError):
    return JSONResponse(status_code=502, content={"detail": f"Gagal akses GitHub: {exc}"})


@app.exception_handler(PakasirServiceError)
async def pakasir_error_handler(request: Request, exc: PakasirServiceError):
    return JSONResponse(status_code=502, content={"detail": f"Gagal akses Pakasir: {exc}"})


app.include_router(auth.router)
app.include_router(menu.router)
app.include_router(voucher.router)
app.include_router(banner.router)
app.include_router(cart.router)
app.include_router(checkout.router)
app.include_router(order.router)
app.include_router(webhook.router)
app.include_router(dashboard.router)
app.include_router(export.router)


@app.get("/")
async def root():
    return {"app": settings.app_name, "status": "ok"}


@app.get("/health")
async def health():
    return {"status": "healthy"}
