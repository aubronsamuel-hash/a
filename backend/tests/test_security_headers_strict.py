from __future__ import annotations

from fastapi.testclient import TestClient

from app.main import create_app


def test_security_headers_present_and_valid(monkeypatch):
    # Env stricte mais sans HSTS pour eviter faux positifs en dev HTTP
    monkeypatch.setenv("SEC_HEADERS_ENABLE", "true")
    monkeypatch.setenv("CSP_DEFAULT_SRC", "self")
    monkeypatch.setenv("CSP_SCRIPT_SRC", "self")
    monkeypatch.setenv("CSP_STYLE_SRC", "self")
    monkeypatch.setenv("CSP_IMG_SRC", "self data:")
    monkeypatch.setenv("CSP_FONT_SRC", "self data:")
    monkeypatch.setenv("CSP_CONNECT_SRC", "self")
    monkeypatch.setenv("CSP_FRAME_SRC", "none")
    monkeypatch.setenv("CSP_ALLOW_UNSAFE_INLINE", "false")
    monkeypatch.setenv("HSTS_ENABLE", "false")

    app = create_app()
    c = TestClient(app)
    r = c.get("/healthz")
    assert r.status_code == 200
    h = {k.lower(): v for k, v in r.headers.items()}
    assert "content-security-policy" in h
    csp = h["content-security-policy"]
    assert "default-src 'self'" in csp
    assert "script-src" in csp and "nonce-" in csp
    assert h.get("x-content-type-options") == "nosniff"
    assert h.get("referrer-policy") == "strict-origin-when-cross-origin"
    assert h.get("x-frame-options") == "DENY"
    assert "permissions-policy" in h


def test_csp_allows_inline_only_if_flag(monkeypatch):
    monkeypatch.setenv("SEC_HEADERS_ENABLE", "true")
    monkeypatch.setenv("CSP_ALLOW_UNSAFE_INLINE", "true")
    app = create_app()
    c = TestClient(app)
    r = c.get("/healthz")
    h = {k.lower(): v for k, v in r.headers.items()}
    assert "content-security-policy" in h
    assert "'unsafe-inline'" in h["content-security-policy"]

