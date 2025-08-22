import os

from app.main import create_app
from fastapi.testclient import TestClient


def test_meta_scaling_reads_env(monkeypatch):
    monkeypatch.setenv("WEB_CONCURRENCY", "7")
    monkeypatch.setenv("GUNICORN_TIMEOUT", "45")
    app = create_app()
    c = TestClient(app)
    r = c.get("/_meta/scaling")
    assert r.status_code == 200
    data = r.json()
    assert data["WEB_CONCURRENCY"] == "7"
    assert data["GUNICORN_TIMEOUT"] == "45"


def test_meta_scaling_defaults_present():
    app = create_app()
    c = TestClient(app)
    r = c.get("/_meta/scaling")
    assert r.status_code == 200
    data = r.json()
    # Les cles existent meme si non definies
    for k in [
        "WEB_CONCURRENCY","THREADS","GUNICORN_TIMEOUT","GUNICORN_GRACEFUL_TIMEOUT",
        "GUNICORN_KEEPALIVE","GUNICORN_MAX_REQUESTS","GUNICORN_MAX_REQUESTS_JITTER"
    ]:
        assert k in data
