from fastapi.testclient import TestClient

from app.config import settings
from app.main import app

client = TestClient(app)


def _login(u: str, p: str):
    r = client.post("/auth/token", json={"username": u, "password": p})
    return r


def test_refresh_ok_and_ko():
    r = _login(settings.ADMIN_USERNAME, settings.ADMIN_PASSWORD)
    assert r.status_code == 200
    refresh = r.json()["refresh_token"]
    r2 = client.post("/auth/refresh", json={"refresh_token": refresh})
    assert r2.status_code == 200
    assert "access_token" in r2.json()
    # KO: token bidon
    r3 = client.post("/auth/refresh", json={"refresh_token": "bad"})
    assert r3.status_code == 401


def test_change_password_ok_and_wrong_old():
    # login
    r = _login(settings.ADMIN_USERNAME, settings.ADMIN_PASSWORD)
    assert r.status_code == 200
    tok = r.json()["access_token"]
    # wrong old
    rko = client.post(
        "/auth/change-password",
        headers={"Authorization": f"Bearer {tok}"},
        json={"old_password": "zzz", "new_password": "secretXYZ"},
    )
    assert rko.status_code == 401
    # ok
    rok = client.post(
        "/auth/change-password",
        headers={"Authorization": f"Bearer {tok}"},
        json={"old_password": settings.ADMIN_PASSWORD, "new_password": "secretXYZ"},
    )
    assert rok.status_code == 204
    # login avec ancien doit echouer
    r_old = _login(settings.ADMIN_USERNAME, settings.ADMIN_PASSWORD)
    assert r_old.status_code == 401
    # login avec nouveau ok
    r_new = _login(settings.ADMIN_USERNAME, "secretXYZ")
    assert r_new.status_code == 200


def test_users_admin_only_403_for_user():
    # creer un user normal via admin
    admin = _login(settings.ADMIN_USERNAME, "secretXYZ").json()["access_token"]
    rcreate = client.post(
        "/users",
        headers={"Authorization": f"Bearer {admin}"},
        json={"username": "u2", "password": "p2secret"},
    )
    assert rcreate.status_code == 201
    # login user
    ruser = _login("u2", "p2secret")
    tok_user = ruser.json()["access_token"]
    # user tente d acceder /users -> 403
    rlist = client.get("/users", headers={"Authorization": f"Bearer {tok_user}"})
    assert rlist.status_code == 403

