from __future__ import annotations

import json
import os
from datetime import UTC, datetime
from typing import Any

from .config import settings


def _now_iso() -> str:
    return datetime.now(tz=UTC).isoformat()


def write_event(
    action: str,
    actor: str | None,
    status: str,
    target: str | None = None,
    ip: str | None = None,
    meta: dict[str, Any] | None = None,
) -> None:
    """Append a JSON line describing an audit event.

    Best-effort: silently ignore any write errors.
    """
    rec = {
        "ts": _now_iso(),
        "action": action,
        "actor": actor,
        "target": target,
        "status": status,
        "ip": ip,
        "meta": meta or {},
    }
    try:
        path = settings.AUDIT_LOG_PATH
        os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
        with open(path, "a", encoding="utf-8") as f:
            f.write(json.dumps(rec, ensure_ascii=True) + "\n")
    except Exception:  # pragma: no cover - best effort
        pass


def read_events(limit: int = 50, after_iso: str | None = None) -> list[dict[str, Any]]:
    """Read events from the audit log file, most recent first."""
    path = settings.AUDIT_LOG_PATH
    if not os.path.exists(path):
        return []
    items: list[dict[str, Any]] = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except Exception:  # pragma: no cover - malformed line
                continue
            items.append(obj)
    items.sort(key=lambda x: x.get("ts", ""), reverse=True)
    if after_iso:
        items = [x for x in items if x.get("ts", "") > after_iso]
    return items[: max(1, min(limit, 500))]
