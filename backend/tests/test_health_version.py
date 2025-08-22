from __future__ import annotations

from app.main import app
from app.version import version
from fastapi.testclient import TestClient

client = TestClient(app)


def test_health_version_matches() -> None:
    r = client.get("/healthz")
    assert r.status_code == 200
    assert r.json()["version"].startswith(version)
