from __future__ import annotations

from fastapi.testclient import TestClient

from app.main import create_app


def test_livez_ok() -> None:
    app = create_app()
    client = TestClient(app)
    r = client.get("/livez")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_readyz_ok(monkeypatch) -> None:
    from app import api as api_mod

    monkeypatch.setattr(api_mod, "_db_ready", lambda: True)
    monkeypatch.setattr(api_mod, "_redis_ready", lambda: True)
    app = create_app()
    client = TestClient(app)
    r = client.get("/readyz")
    assert r.status_code == 200
    assert r.json()["status"] == "ready"


def test_readyz_db_ko(monkeypatch) -> None:
    from app import api as api_mod

    monkeypatch.setattr(api_mod, "_db_ready", lambda: False)
    app = create_app()
    client = TestClient(app)
    r = client.get("/readyz")
    assert r.status_code == 503
    assert r.json()["status"] == "not-ready"
