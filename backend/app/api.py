from __future__ import annotations

import logging
import socket

from fastapi import APIRouter, Depends, Request
from pydantic import BaseModel
from sqlalchemy import text
from starlette.responses import JSONResponse

from .config import settings
from .db import engine
from .deps import get_current_user, pagination_params
from .version import version
from .logging_setup import get_logger

router = APIRouter()
log = get_logger(__name__)


class HealthModel(BaseModel):
    status: str
    version: str


@router.get("/healthz", response_model=HealthModel, tags=["health"])
def healthz() -> HealthModel:
    log.info("healthz OK")
    return HealthModel(status="ok", version=version)


@router.get("/livez", tags=["health"])
def livez() -> dict[str, str]:
    return {"status": "ok"}


def _db_ready() -> bool:
    try:
        with engine.connect() as conn:
            conn = conn.execution_options(
                timeout=settings.READINESS_DB_TIMEOUT_SECONDS
            )
            conn.execute(text("SELECT 1"))
        return True
    except Exception as e:  # pragma: no cover - log only
        logging.warning("Readiness DB KO: %s", e)
        return False


def _redis_ready() -> bool:
    try:
        if not settings.READINESS_REQUIRE_REDIS:
            return True
        from urllib.parse import urlparse

        import redis  # type: ignore

        url = urlparse(settings.REDIS_URL)
        client = redis.Redis(
            host=url.hostname, port=url.port or 6379, db=int((url.path or "/0").lstrip("/"))
        )
        client.ping()
        return True
    except Exception as e:  # pragma: no cover - log only
        logging.warning("Readiness Redis KO: %s", e)
        return False


@router.get("/readyz", tags=["health"])
def readyz(_request: Request) -> JSONResponse:
    if not _db_ready():
        return JSONResponse({"status": "not-ready", "reason": "db"}, status_code=503)
    if not _redis_ready():
        return JSONResponse({"status": "not-ready", "reason": "redis"}, status_code=503)
    try:
        host = socket.gethostname()
    except Exception:  # pragma: no cover - fallback
        host = "unknown"
    return JSONResponse({"status": "ready", "host": host, "version": version})


class EchoIn(BaseModel):
    message: str


class EchoOut(BaseModel):
    message: str
    page: int
    page_size: int


@router.post("/echo", response_model=EchoOut, tags=["debug"])
def echo(payload: EchoIn, pg=Depends(pagination_params)):  # noqa: B008
    return {"message": payload.message, "page": pg["page"], "page_size": pg["page_size"]}


class MeOut(BaseModel):
    username: str
    role: str


@router.get("/auth/me", response_model=MeOut, tags=["auth"])
def me(current=Depends(get_current_user)) -> MeOut:  # noqa: B008
    return MeOut(username=current["username"], role=current["role"])
