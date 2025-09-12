from app.main import create_app
from fastapi.testclient import TestClient


def test_health_smoke() -> None:
    app = create_app()
    client = TestClient(app)
    r = client.get("/healthz")
    assert r.status_code == 200
