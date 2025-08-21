from fastapi.testclient import TestClient

from app.config import settings
from app.main import create_app


def test_create_app_resets_db():
    app1 = create_app()
    c1 = TestClient(app1)
    tok1 = c1.post(
        "/auth/token",
        json={"username": settings.ADMIN_USERNAME, "password": settings.ADMIN_PASSWORD},
    ).json()["access_token"]
    r1 = c1.post(
        "/users",
        headers={"Authorization": f"Bearer {tok1}"},
        json={"username": "regen", "password": "regenpass"},
    )
    assert r1.status_code == 201

    app2 = create_app()
    c2 = TestClient(app2)
    tok2 = c2.post(
        "/auth/token",
        json={"username": settings.ADMIN_USERNAME, "password": settings.ADMIN_PASSWORD},
    ).json()["access_token"]
    r2 = c2.post(
        "/users",
        headers={"Authorization": f"Bearer {tok2}"},
        json={"username": "regen", "password": "regenpass"},
    )
    assert r2.status_code == 201
