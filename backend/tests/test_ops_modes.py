from __future__ import annotations

from app.config import settings
from app.main import create_app
from fastapi.testclient import TestClient


def _client() -> TestClient:
    app = create_app()
    return TestClient(app)


def test_maintenance_blocks_non_health_allows_health(monkeypatch) -> None:
    monkeypatch.setattr(settings, "MAINTENANCE_MODE", True)
    c = _client()
    r_health = c.get("/healthz")
    assert r_health.status_code == 200
    r_users = c.get("/users")
    assert r_users.status_code == 503


def test_readonly_blocks_mutations_but_allows_auth_and_get(monkeypatch) -> None:
    monkeypatch.setattr(settings, "READ_ONLY_MODE", True)
    monkeypatch.setattr(settings, "ADMIN_AUTOSEED", True)
    c = _client()
    tok = c.post(
        "/auth/token",
        json={"username": settings.ADMIN_USERNAME, "password": settings.ADMIN_PASSWORD},
    )
    assert tok.status_code in (200, 401)
    r_get = c.get("/users")
    assert r_get.status_code != 423
    r_post = c.post("/users", json={"username": "x", "password": "y"})
    assert r_post.status_code == 423
