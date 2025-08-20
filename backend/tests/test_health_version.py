from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health_version_070():
    r = client.get("/healthz")
    assert r.status_code == 200
    assert r.json()["version"].startswith("0.7.0")

