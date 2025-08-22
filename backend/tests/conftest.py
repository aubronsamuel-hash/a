from __future__ import annotations

import os
from collections.abc import Iterator

import pytest
from app.config import settings

# Initial toggles before importing app in tests
settings.RATE_LIMIT_ENABLE = False
settings.RATE_LIMIT_GLOBAL_MAX = 10_000
settings.RATE_LIMIT_AUTH_MAX = 10_000
settings.ADMIN_AUTOSEED = True
settings.ADMIN_USERNAME = "admin"
settings.ADMIN_PASSWORD = "admin123"
os.environ.setdefault("CORS_ENABLE", "true")
os.environ.setdefault("CORS_ALLOW_ORIGINS", "http://localhost:3000,http://localhost:5173")


@pytest.fixture(autouse=True)
def _test_env_toggles() -> Iterator[None]:
    settings.RATE_LIMIT_ENABLE = False
    settings.RATE_LIMIT_GLOBAL_MAX = 10_000
    settings.RATE_LIMIT_AUTH_MAX = 10_000
    settings.ADMIN_AUTOSEED = True
    settings.ADMIN_USERNAME = "admin"
    settings.ADMIN_PASSWORD = "admin123"
    os.environ.setdefault("CORS_ENABLE", "true")
    os.environ.setdefault(
        "CORS_ALLOW_ORIGINS", "http://localhost:3000,http://localhost:5173"
    )
    yield
