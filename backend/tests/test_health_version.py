from __future__ import annotations

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health_version_090() -> None:
    r = client.get("/healthz")
    assert r.status_code == 200
    assert r.json()["version"].startswith("0.9.0")
