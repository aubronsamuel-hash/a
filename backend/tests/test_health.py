from fastapi.testclient import TestClient

from app.main import app
from app.version import version

client = TestClient(app)


def test_health_ok() -> None:
    r = client.get("/healthz")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"
    assert r.json()["version"].startswith(version)


def test_unknown_path_404() -> None:
    r = client.get("/does-not-exist")
    assert r.status_code == 404
