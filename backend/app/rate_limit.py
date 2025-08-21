from __future__ import annotations

import time
from typing import Any, Protocol, cast

try:
    import redis
except Exception:  # pragma: no cover - optional dependency
    redis = cast(Any, None)


class Limiter(Protocol):
    def allow(self, key: str, max_calls: int, window_seconds: int) -> tuple[bool, int, int]:
        ...


class InMemoryFixedWindowLimiter:
    """Fixed-window limiter stored in-process."""

    def __init__(self) -> None:
        self._store: dict[str, tuple[float, int]] = {}

    def allow(self, key: str, max_calls: int, window_seconds: int) -> tuple[bool, int, int]:
        now = time.time()
        win_start, count = self._store.get(key, (now, 0))
        if now - win_start >= window_seconds:
            win_start = now
            count = 0
        count += 1
        self._store[key] = (win_start, count)
        remaining = max(0, max_calls - count)
        reset_in = max(0, int(window_seconds - (now - win_start)))
        return count <= max_calls, remaining, reset_in


class RedisFixedWindowLimiter:
    """Redis-based fixed-window limiter using INCR/EXPIRE."""

    def __init__(self, client: Any) -> None:
        self.client = client

    def allow(self, key: str, max_calls: int, window_seconds: int) -> tuple[bool, int, int]:
        count = int(self.client.incr(key))
        if count == 1:
            self.client.expire(key, window_seconds)
        remaining = max(0, max_calls - count)
        ttl = self.client.ttl(key)
        reset_in = int(ttl) if isinstance(ttl, int) and ttl >= 0 else window_seconds
        return count <= max_calls, remaining, reset_in


_limiter_singleton: Limiter | None = None


def get_limiter(backend: str = "memory", redis_url: str | None = None) -> Limiter:
    global _limiter_singleton
    if _limiter_singleton is not None:
        return _limiter_singleton
    if backend.lower() == "redis":
        if redis is None:  # pragma: no cover - fallback when redis package missing
            _limiter_singleton = InMemoryFixedWindowLimiter()
            return _limiter_singleton
        url = redis_url or "redis://localhost:6379/0"
        client = redis.Redis.from_url(url, decode_responses=True)
        _limiter_singleton = RedisFixedWindowLimiter(client)
        return _limiter_singleton
    _limiter_singleton = InMemoryFixedWindowLimiter()
    return _limiter_singleton
