from __future__ import annotations

from app.main import create_app
from fastapi.testclient import TestClient


def test_metrics_contains_http_requests_total() -> None:
    app = create_app()
    c = TestClient(app)
    # generer une requete
    assert c.get("/healthz").status_code == 200
    # lire /metrics et verifier un compteur standard
    m = c.get("/metrics")
    assert m.status_code == 200
    body = m.text
    assert "http_requests_total" in body
