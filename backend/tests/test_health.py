from app.main import app
from fastapi.testclient import TestClient

client = TestClient(app)


def test_healthz_ok():
    r = client.get("/healthz")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_readyz_ok(monkeypatch):
    from app import health

    def fake_execute(*a, **k):
        return 1

    monkeypatch.setattr(
        health,
        "SessionLocal",
        lambda: type("T", (), {"execute": fake_execute, "close": lambda self: None})(),
    )

    r = client.get("/readyz")
    assert r.status_code == 200
    assert r.json()["status"] == "ready"


def test_readyz_db_error(monkeypatch):
    from app import health
    from sqlalchemy.exc import OperationalError

    def fake_execute(*a, **k):
        raise OperationalError("x", "y", "z")

    monkeypatch.setattr(
        health,
        "SessionLocal",
        lambda: type("T", (), {"execute": fake_execute, "close": lambda self: None})(),
    )

    r = client.get("/readyz")
    assert r.status_code == 503
    assert r.json()["status"] == "db_error"
