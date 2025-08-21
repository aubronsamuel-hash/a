from __future__ import annotations

import os
from typing import List


def _env_bool(name: str, default: bool) -> bool:
    v = os.getenv(name)
    if v is None:
        return default
    return v.lower() in ("1", "true", "yes", "on")


def _split_csv(name: str, default: str) -> List[str]:
    raw = os.getenv(name, default)
    parts = [p.strip() for p in raw.split(",") if p.strip()]
    return parts


class CorsSettings:
    def __init__(self) -> None:
        self.enabled = _env_bool("CORS_ENABLE", True)
        self.allow_origins = _split_csv("CORS_ALLOW_ORIGINS", "")
        self.allow_methods = _split_csv(
            "CORS_ALLOW_METHODS", "GET,POST,PUT,PATCH,DELETE,OPTIONS,HEAD"
        )
        self.allow_headers = _split_csv(
            "CORS_ALLOW_HEADERS", "Authorization,Content-Type"
        )
        self.allow_credentials = _env_bool("CORS_ALLOW_CREDENTIALS", False)
        try:
            self.max_age = int(os.getenv("CORS_MAX_AGE", "600"))
        except ValueError:
            self.max_age = 600
