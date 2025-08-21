from fastapi.testclient import TestClient
from app.core.config import get_settings
from app.main import create_app


def test_google_start_redirect_ok(monkeypatch):
    monkeypatch.setenv("GOOGLE_CLIENT_ID", "abc.apps.googleusercontent.com")
    monkeypatch.setenv("GOOGLE_REDIRECT_URI", "http://localhost/callback")
    monkeypatch.setenv("GOOGLE_SCOPES", "openid,email,profile")
    get_settings.cache_clear()
    app = create_app()
    c = TestClient(app)
    r = c.get("/auth/google/start", allow_redirects=False)
    assert r.status_code in (302, 307)
    loc = r.headers.get("location")
    assert loc and loc.startswith("https://accounts.google.com/o/oauth2/v2/auth?")
    assert "client_id=abc.apps.googleusercontent.com" in loc
    assert "redirect_uri=http%3A%2F%2Flocalhost%2Fcallback" in loc


def test_google_start_missing_env_returns_400(monkeypatch):
    monkeypatch.delenv("GOOGLE_CLIENT_ID", raising=False)
    monkeypatch.setenv("GOOGLE_REDIRECT_URI", "http://localhost/callback")
    get_settings.cache_clear()
    app = create_app()
    c = TestClient(app)
    r = c.get("/auth/google/start", allow_redirects=False)
    assert r.status_code == 400


def test_google_test_callback_ok(monkeypatch):
    monkeypatch.setenv("OAUTH_GOOGLE_TEST_MODE", "1")
    monkeypatch.setenv("JWT_SECRET", "testsecret")
    get_settings.cache_clear()
    app = create_app()
    c = TestClient(app)
    r = c.post("/auth/google/test-callback", json={"email": "u@example.com", "sub": "google-123"})
    assert r.status_code == 200
    data = r.json()
    assert "token" in data and data["user"]["sub"] == "google-123"


def test_google_test_callback_forbidden_when_disabled(monkeypatch):
    monkeypatch.setenv("OAUTH_GOOGLE_TEST_MODE", "0")
    get_settings.cache_clear()
    app = create_app()
    c = TestClient(app)
    r = c.post("/auth/google/test-callback", json={"email": "u@example.com"})
    assert r.status_code == 403
