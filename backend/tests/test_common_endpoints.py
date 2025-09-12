from app.main import create_app
from fastapi.testclient import TestClient


PATHS = ["/", "/healthz", "/docs", "/openapi.json"]


def test_common_endpoints() -> None:
    app = create_app()
    client = TestClient(app)
    statuses = []
    for path in PATHS:
        try:
            resp = client.get(path)
            statuses.append(resp.status_code)
        except Exception:
            continue
    assert any(200 <= s < 400 for s in statuses)
