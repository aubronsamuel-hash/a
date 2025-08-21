from __future__ import annotations

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_security_headers_present() -> None:
    r = client.get("/healthz")
    assert r.status_code == 200
    h = r.headers
    assert h.get("x-content-type-options") == "nosniff"
    assert h.get("x-frame-options") == "DENY"
    assert "default-src" in (h.get("content-security-policy") or "")
    assert h.get("referrer-policy") == "no-referrer"
    assert "max-age" in (h.get("strict-transport-security") or "")
