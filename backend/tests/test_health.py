from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health_ok() -> None:
    r = client.get("/healthz")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_unknown_path_404() -> None:
    r = client.get("/does-not-exist")
    assert r.status_code == 404
