from __future__ import annotations

from app.main import create_app
from fastapi.testclient import TestClient


def test_security_headers_present() -> None:
    app = create_app()
    client = TestClient(app)
    r = client.get("/healthz")
    assert r.status_code == 200
    h = {k.lower(): v for k, v in r.headers.items()}
    assert h.get("x-content-type-options") == "nosniff"
    assert h.get("x-frame-options") == "DENY"
    assert "default-src" in h.get("content-security-policy", "")
    assert h.get("referrer-policy") == "strict-origin-when-cross-origin"
    assert "strict-transport-security" not in h
