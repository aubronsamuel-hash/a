from __future__ import annotations

from contextlib import contextmanager
from typing import Any

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

from .config import settings


class Base(DeclarativeBase):
    pass


def _engine_kwargs() -> dict[str, Any]:
    kw: dict[str, Any] = {}
    if settings.DB_DSN.startswith("sqlite"):
        kw["connect_args"] = {"check_same_thread": False}
    else:
        kw["pool_size"] = settings.DB_POOL_SIZE
        kw["max_overflow"] = settings.DB_MAX_OVERFLOW
        kw["pool_timeout"] = settings.DB_POOL_TIMEOUT
    return kw


engine = create_engine(settings.DB_DSN, **_engine_kwargs())

SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


@contextmanager
def session_scope():
    db = SessionLocal()
    try:
        yield db
        db.commit()
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()
