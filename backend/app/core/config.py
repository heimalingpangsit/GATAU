"""
Konfigurasi aplikasi. Semua nilai sensitif diambil dari environment (.env),
TIDAK PERNAH di-hardcode di sini.
"""
from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # GitHub
    github_token: str
    github_owner: str
    github_repo: str
    github_branch: str = "main"
    github_data_path: str = "data"

    # Pakasir
    pakasir_api_key: str
    pakasir_slug: str
    pakasir_base_url: str = "https://app.pakasir.com"

    # MongoDB (cache/session/log only)
    mongo_uri: str = "mongodb://localhost:27017"
    mongo_db_name: str = "kebab_dzaqy_cache"

    # JWT
    jwt_secret_key: str
    jwt_algorithm: str = "HS256"
    jwt_access_token_expire_minutes: int = 120

    # Default accounts (dipakai untuk seeding pertama kali jika data/users.json belum ada)
    default_owner_username: str
    default_owner_password: str
    default_kasir_username: str
    default_kasir_password: str
    default_kasir_whatsapp: str

    app_name: str = "KEBAB DZAQY"
    frontend_origin: str = "http://localhost:5173"
    environment: str = "development"


@lru_cache
def get_settings() -> Settings:
    return Settings()
