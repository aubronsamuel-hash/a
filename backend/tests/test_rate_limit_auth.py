from __future__ import annotations

from app.auth import _auth_limiter
from app.config import settings
from app.main import app
from fastapi.testclient import TestClient

client = TestClient(app)


def test_auth_rate_limit_401_then_429() -> None:
    settings.RATE_LIMIT_ENABLE = True
    settings.RATE_LIMIT_AUTH_MAX = 3
    settings.RATE_LIMIT_AUTH_WINDOW_SECONDS = 60
    _auth_limiter._store.clear()  # type: ignore[attr-defined]
    codes: list[int] = []
    for _ in range(5):
        r = client.post(
            "/auth/token",
            json={"username": settings.ADMIN_USERNAME, "password": "bad"},
        )
        codes.append(r.status_code)
    assert 401 in codes, "Au moins un 401 attendu"
    assert 429 in codes, "Au moins un 429 attendu quand la limite est depassee"
