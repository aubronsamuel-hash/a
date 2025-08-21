from __future__ import annotations

from fastapi.testclient import TestClient

from app.main import create_app


def _preflight(client: TestClient, origin: str, method: str, req_headers: str = "Authorization,Content-Type"):
    return client.options(
        "/healthz",
        headers={
            "Origin": origin,
            "Access-Control-Request-Method": method,
            "Access-Control-Request-Headers": req_headers,
        },
    )


def test_cors_preflight_ok(monkeypatch):
    monkeypatch.setenv("CORS_ENABLE", "true")
    monkeypatch.setenv("CORS_ALLOW_ORIGINS", "http://localhost:5173,https://app.example.com")
    monkeypatch.setenv("CORS_ALLOW_METHODS", "GET,POST")
    monkeypatch.setenv("CORS_ALLOW_HEADERS", "Authorization,Content-Type")
    app = create_app()
    c = TestClient(app)
    r = _preflight(c, "http://localhost:5173", "POST")
    assert r.status_code in (200, 204)
    h = {k.lower(): v for k, v in r.headers.items()}
    assert h.get("access-control-allow-origin") == "http://localhost:5173"
    assert "authorization" in h.get("access-control-allow-headers", "").lower()
    assert "post" in h.get("access-control-allow-methods", "").lower()


def test_cors_disabled_no_headers(monkeypatch):
    monkeypatch.setenv("CORS_ENABLE", "false")
    app = create_app()
    c = TestClient(app)
    r = _preflight(c, "http://localhost:5173", "GET")
    h = {k.lower(): v for k, v in r.headers.items()}
    assert "access-control-allow-origin" not in h
