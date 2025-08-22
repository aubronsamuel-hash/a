import jwt
from app.main import create_app
from fastapi.testclient import TestClient

SECRET = "testsecret"
ALGO = "HS256"


def make_token(sub="u1", roles=None, email=None):
    roles = roles or []
    payload = {"sub": sub, "roles": roles}
    if email:
        payload["email"] = email
    return jwt.encode(payload, SECRET, algorithm=ALGO)


def test_me_ping_ok_with_any_token(monkeypatch):
    monkeypatch.setenv("JWT_SECRET", SECRET)
    monkeypatch.setenv("JWT_ALGO", ALGO)
    app = create_app()
    c = TestClient(app)
    tok = make_token(roles=["user"])
    r = c.get("/me/ping", headers={"Authorization": f"Bearer {tok}"})
    assert r.status_code == 200
    assert r.json()["ok"] is True


def test_admin_ping_forbidden_without_admin(monkeypatch):
    monkeypatch.setenv("JWT_SECRET", SECRET)
    monkeypatch.setenv("JWT_ALGO", ALGO)
    app = create_app()
    c = TestClient(app)
    tok = make_token(roles=["user"])
    r = c.get("/admin/ping", headers={"Authorization": f"Bearer {tok}"})
    assert r.status_code == 403


def test_admin_ping_ok_with_admin(monkeypatch):
    monkeypatch.setenv("JWT_SECRET", SECRET)
    monkeypatch.setenv("JWT_ALGO", ALGO)
    app = create_app()
    c = TestClient(app)
    tok = make_token(roles=["admin"])
    r = c.get("/admin/ping", headers={"Authorization": f"Bearer {tok}"})
    assert r.status_code == 200
    assert r.json()["admin"] is True


def test_unauthenticated_gets_401(monkeypatch):
    monkeypatch.setenv("JWT_SECRET", SECRET)
    monkeypatch.setenv("JWT_ALGO", ALGO)
    app = create_app()
    c = TestClient(app)
    r = c.get("/admin/ping")
    assert r.status_code == 401
