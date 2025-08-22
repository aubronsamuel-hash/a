from app.config import settings
from app.main import app
from fastapi.testclient import TestClient

client = TestClient(app)


def test_login_ok_via_db():
    # admin est autoseed via startup si ADMIN_AUTOSEED=true
    for pw in ("secretXYZ", settings.ADMIN_PASSWORD):
        r = client.post(
            "/auth/token",
            json={"username": settings.ADMIN_USERNAME, "password": pw},
        )
        if r.status_code == 200:
            break
    assert r.status_code == 200
    token = r.json()["access_token"]
    r2 = client.get("/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert r2.status_code == 200
    assert r2.json()["username"] == settings.ADMIN_USERNAME


def test_login_ko_wrong_password():
    r = client.post(
        "/auth/token",
        json={"username": settings.ADMIN_USERNAME, "password": "bad"},
    )
    assert r.status_code == 401
