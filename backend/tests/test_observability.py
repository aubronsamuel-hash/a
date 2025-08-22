from app.config import settings
from app.main import app
from fastapi.testclient import TestClient

client = TestClient(app)


def test_request_id_propagation_and_generation():
    hdr = settings.REQUEST_ID_HEADER
    r = client.get("/healthz", headers={hdr: "abc-123"})
    assert r.status_code == 200
    assert r.headers[hdr] == "abc-123"
    r2 = client.get("/healthz")
    assert r2.status_code == 200
    assert hdr in r2.headers
    assert len(r2.headers[hdr]) > 0


def test_metrics_endpoint_ok():
    r = client.get("/metrics")
    assert r.status_code == 200
    assert "text/plain" in r.headers.get("content-type", "")
    assert "process_cpu_seconds_total" in r.text


def test_livez_readyz_ok():
    r1 = client.get("/livez")
    assert r1.status_code == 200
    r2 = client.get("/readyz")
    assert r2.status_code == 200
    assert r2.json()["status"] in ("ready",)
