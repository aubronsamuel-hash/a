from fastapi.testclient import TestClient

from app.config import settings
from app.main import app

client = TestClient(app)


def _token() -> str:
    # try new password first (may have been changed in other tests)
    r = client.post(
        "/auth/token",
        json={"username": settings.ADMIN_USERNAME, "password": "secretXYZ"},
    )
    if r.status_code != 200:
        r = client.post(
            "/auth/token",
            json={"username": settings.ADMIN_USERNAME, "password": settings.ADMIN_PASSWORD},
        )
    assert r.status_code == 200
    return r.json()["access_token"]


def test_users_list_and_create_ok_ko():
    t = _token()
    r = client.get("/users", headers={"Authorization": f"Bearer {t}"})
    assert r.status_code == 200
    r2 = client.post(
        "/users",
        headers={"Authorization": f"Bearer {t}"},
        json={"username": "user1", "password": "secret123"},
    )
    assert r2.status_code == 201
    r3 = client.post(
        "/users",
        headers={"Authorization": f"Bearer {t}"},
        json={"username": "user1", "password": "secretXXX"},
    )
    assert r3.status_code == 409
