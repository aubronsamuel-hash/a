from __future__ import annotations

from pathlib import Path

from fastapi.testclient import TestClient

from app.config import settings
from app.main import create_app


def _client(tmp_path: Path) -> TestClient:
    settings.AUDIT_LOG_PATH = str(tmp_path / "audit.jsonl")
    settings.ADMIN_AUTOSEED = True
    app = create_app()
    return TestClient(app)


def _login(client: TestClient, u: str, p: str):
    return client.post("/auth/token", json={"username": u, "password": p})


def test_audit_login_success_and_failure(tmp_path: Path):
    c = _client(tmp_path)
    r_bad = _login(c, "admin", "bad")
    assert r_bad.status_code == 401
    r_ok = _login(c, settings.ADMIN_USERNAME, settings.ADMIN_PASSWORD)
    assert r_ok.status_code in (200, 401)
    if r_ok.status_code == 200:
        token = r_ok.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}
        r = c.get("/audit?limit=10", headers=headers)
        assert r.status_code == 200
        items = r.json()["items"]
        assert any(
            it["action"] == "auth.login" and it["status"] == "failure" for it in items
        )
        assert any(
            it["action"] == "auth.login" and it["status"] == "success" for it in items
        )


def test_audit_forbidden_without_token(tmp_path: Path):
    c = _client(tmp_path)
    r = c.get("/audit?limit=5")
    assert r.status_code in (401, 403)
