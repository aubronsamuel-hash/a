from __future__ import annotations

import os


def _split_csv(value: str) -> list[str]:
    return [v.strip() for v in value.split(",") if v.strip()]


class Settings:
    APP_NAME: str = os.getenv("APP_NAME", "Coulisses Crew API")
    APP_ENV: str = os.getenv("APP_ENV", "dev")
    APP_HOST: str = os.getenv("APP_HOST", "0.0.0.0")
    APP_PORT: int = int(os.getenv("APP_PORT", "8001"))
    APP_LOG_LEVEL: str = os.getenv("APP_LOG_LEVEL", "info")
    APP_DEFAULT_PAGE_SIZE: int = int(os.getenv("APP_DEFAULT_PAGE_SIZE", "50"))
    APP_MAX_PAGE_SIZE: int = int(os.getenv("APP_MAX_PAGE_SIZE", "200"))
    APP_REQUEST_TIMEOUT_SECONDS: int = int(os.getenv("APP_REQUEST_TIMEOUT_SECONDS", "15"))

    JWT_SECRET: str = os.getenv("JWT_SECRET", "changeme-dev")
    JWT_ALGO: str = os.getenv("JWT_ALGO", "HS256")
    JWT_TTL_SECONDS: int = int(os.getenv("JWT_TTL_SECONDS", "3600"))
    REFRESH_JWT_SECRET: str = os.getenv("REFRESH_JWT_SECRET", "changeme-refresh-dev")
    REFRESH_JWT_TTL_SECONDS: int = int(os.getenv("REFRESH_JWT_TTL_SECONDS", "1209600"))
    CORS_ORIGINS: list[str] = _split_csv(os.getenv("CORS_ORIGINS", ""))

    ADMIN_AUTOSEED: bool = os.getenv("ADMIN_AUTOSEED", "true").lower() == "true"
    ADMIN_USERNAME: str = os.getenv("ADMIN_USERNAME", "admin")
    ADMIN_PASSWORD: str = os.getenv("ADMIN_PASSWORD", "admin123")

    DB_DSN: str = os.getenv("DB_DSN", "sqlite:///./cc.db")
    DB_POOL_SIZE: int = int(os.getenv("DB_POOL_SIZE", "10"))
    DB_MAX_OVERFLOW: int = int(os.getenv("DB_MAX_OVERFLOW", "20"))
    DB_POOL_TIMEOUT: int = int(os.getenv("DB_POOL_TIMEOUT", "10"))

    # Observabilite
    REQUEST_ID_HEADER: str = os.getenv("REQUEST_ID_HEADER", "X-Request-ID")
    LOG_JSON: bool = os.getenv("LOG_JSON", "true").lower() == "true"

    # Rate limiting
    RATE_LIMIT_ENABLE: bool = os.getenv("RATE_LIMIT_ENABLE", "true").lower() == "true"
    RATE_LIMIT_GLOBAL_MAX: int = int(os.getenv("RATE_LIMIT_GLOBAL_MAX", "120"))
    RATE_LIMIT_GLOBAL_WINDOW_SECONDS: int = int(
        os.getenv("RATE_LIMIT_GLOBAL_WINDOW_SECONDS", "60")
    )
    RATE_LIMIT_AUTH_MAX: int = int(os.getenv("RATE_LIMIT_AUTH_MAX", "10"))
    RATE_LIMIT_AUTH_WINDOW_SECONDS: int = int(
        os.getenv("RATE_LIMIT_AUTH_WINDOW_SECONDS", "60")
    )
    RATE_LIMIT_BACKEND: str = os.getenv("RATE_LIMIT_BACKEND", "memory")
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379/0")

    # Frontend build (SPA)
    FRONT_DIST_DIR: str = os.getenv("FRONT_DIST_DIR", "")


settings = Settings()
