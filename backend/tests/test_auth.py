from fastapi.testclient import TestClient

from app.config import settings
from app.main import app

client = TestClient(app)


def _get_token(username: str) -> str | None:
    for pw in ("secretXYZ", settings.ADMIN_PASSWORD):
        r = client.post("/auth/token", json={"username": username, "password": pw})
        if r.status_code == 200:
            return r.json()["access_token"]
    return None


def test_login_ok_and_me() -> None:
    token = _get_token(settings.ADMIN_USERNAME)
    assert token is not None
    r = client.get("/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert r.status_code == 200
    assert r.json()["username"] == settings.ADMIN_USERNAME


def test_me_unauthorized_no_token() -> None:
    r = client.get("/auth/me")
    assert r.status_code == 401
