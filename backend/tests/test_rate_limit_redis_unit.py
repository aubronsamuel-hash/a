from __future__ import annotations

import fakeredis
from app.rate_limit import RedisFixedWindowLimiter


def test_redis_limiter_fixed_window_allows_then_blocks() -> None:
    r = fakeredis.FakeRedis(decode_responses=True)
    limiter = RedisFixedWindowLimiter(r)
    key = "ut:ip:1"
    max_calls = 3
    window = 5
    results = [limiter.allow(key, max_calls, window)[0] for _ in range(5)]
    assert results[:3] == [True, True, True]
    assert results[3:] == [False, False]
    ok, _remaining, reset_in = limiter.allow("other", 1, window)
    assert ok is True
    assert 0 <= reset_in <= window
