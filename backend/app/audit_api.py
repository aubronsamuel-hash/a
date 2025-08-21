from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel, Field

from .audit_log import read_events
from .deps import require_admin

router = APIRouter()


class AuditItem(BaseModel):
    ts: str
    action: str
    actor: str | None = None
    target: str | None = None
    status: str
    ip: str | None = None
    meta: dict[str, object] = Field(default_factory=dict)


class AuditOut(BaseModel):
    items: list[AuditItem]


@router.get("/audit", response_model=AuditOut, tags=["admin"])
def list_audit(
    limit: int = Query(50, ge=1, le=500),
    after: str | None = None,
    _: dict = Depends(require_admin),  # noqa: B008
) -> AuditOut:
    items = read_events(limit=limit, after_iso=after)
    return AuditOut(items=[AuditItem.model_validate(it) for it in items])
