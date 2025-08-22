from app import api
from app.config import settings


def test_redis_ready_bad_url(monkeypatch):
    monkeypatch.setattr(settings, "READINESS_REQUIRE_REDIS", True)
    monkeypatch.setattr(settings, "REDIS_URL", "redis:///0")
    assert api._redis_ready() is False
