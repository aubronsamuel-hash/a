from fastapi.testclient import TestClient

from app.config import settings
from app.main import app

client = TestClient(app)


def _access(u: str, p: str) -> str:
    r = client.post("/auth/token", json={"username": u, "password": p})
    assert r.status_code == 200
    return r.json()["access_token"]


def test_promote_user_to_admin_and_list():
    adm = _access(settings.ADMIN_USERNAME, "secretXYZ")
    # create user
    rcreate = client.post(
        "/users",
        headers={"Authorization": f"Bearer {adm}"},
        json={"username": "promme", "password": "pppppp"},
    )
    assert rcreate.status_code == 201
    # promote
    rprom = client.post("/users/promme/promote", headers={"Authorization": f"Bearer {adm}"})
    assert rprom.status_code == 200
    assert rprom.json()["role"] == "admin"
    # list ok
    rlist = client.get("/users", headers={"Authorization": f"Bearer {adm}"})
    assert rlist.status_code == 200

