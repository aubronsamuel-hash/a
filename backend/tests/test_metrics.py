from app.main import create_app
from fastapi.testclient import TestClient


def test_metrics_enabled_exposes_text(monkeypatch):
    monkeypatch.setenv("METRICS_ENABLED", "1")
    monkeypatch.setenv("METRICS_PATH", "/metrics")
    app = create_app()
    c = TestClient(app)
    c.get("/healthz")
    r = c.get("/metrics")
    assert r.status_code == 200
    ct = r.headers.get("content-type", "")
    assert ct.startswith("text/plain")
    body = r.text
    assert "# HELP" in body
    assert (
        "http_requests_total" in body
        or "http_server_requests_total" in body
        or "http_requests_duration_seconds" in body
    )

def test_metrics_disabled_returns_404(monkeypatch):
    monkeypatch.setenv("METRICS_ENABLED", "0")
    monkeypatch.setenv("METRICS_PATH", "/metrics")
    app = create_app()
    c = TestClient(app)
    r = c.get("/metrics")
    assert r.status_code in (404, 405)
