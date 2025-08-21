from __future__ import annotations

import time


class FixedWindowLimiter:
    """In-memory fixed window rate limiter."""

    def __init__(self) -> None:
        self._store: dict[str, tuple[float, int]] = {}

    def allow(self, key: str, max_calls: int, window_seconds: int) -> tuple[bool, int, int]:
        """Return whether the call is allowed, remaining quota, and reset time."""
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
