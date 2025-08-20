from fastapi.testclient import TestClient

from app.config import settings
from app.main import app

client = TestClient(app)


def _get_token(username: str, password: str) -> str | None:
    r = client.post("/auth/token", json={"username": username, "password": password})
    if r.status_code == 200:
        return r.json()["access_token"]
    return None


def test_login_ok_and_me() -> None:
    token = _get_token(settings.DEV_USER, settings.DEV_PASSWORD)
    assert token is not None
    r = client.get("/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert r.status_code == 200
    assert r.json()["username"] == settings.DEV_USER


def test_login_ko_bad_password() -> None:
    r = client.post("/auth/token", json={"username": settings.DEV_USER, "password": "bad"})
    assert r.status_code == 401


def test_me_unauthorized_no_token() -> None:
    r = client.get("/auth/me")
    assert r.status_code == 401


def test_secret_ok_and_ko() -> None:
    token = _get_token(settings.DEV_USER, settings.DEV_PASSWORD)
    assert token
    r_ok = client.get("/debug/secret", headers={"Authorization": f"Bearer {token}"})
    assert r_ok.status_code == 200
    r_ko = client.get("/debug/secret", headers={"Authorization": "Bearer invalid"})
    assert r_ko.status_code == 401
