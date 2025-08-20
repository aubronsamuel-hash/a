from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health_version_080():
    r = client.get("/healthz")
    assert r.status_code == 200
    assert r.json()["version"].startswith("0.8.0")

