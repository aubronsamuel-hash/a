from __future__ import annotations

from collections.abc import Generator

from fastapi import Header, HTTPException, Query, status
from sqlalchemy.orm import Session

from .config import settings
from .db import SessionLocal
from .security import decode_access_token


def pagination_params(
    page: int = Query(1, ge=1, description="Numero de page (>=1)"),
    page_size: int = Query(
        default=settings.APP_DEFAULT_PAGE_SIZE,
        ge=1,
        le=settings.APP_MAX_PAGE_SIZE,
        description="Taille de page",
    ),
):
    return {"page": page, "page_size": page_size}


def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_current_user(authorization: str | None = Header(default=None)) -> dict[str, str]:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token manquant")
    token = authorization.split(" ", 1)[1]
    data = decode_access_token(token)
    return {"username": data.sub}
