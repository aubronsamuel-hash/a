from __future__ import annotations

from collections.abc import Sequence
from typing import Any

from sqlalchemy import asc, desc, func, select
from sqlalchemy.orm import Session

from .models import User


def get_by_username(db: Session, username: str) -> User | None:
    return db.scalar(select(User).where(User.username == username))


def list_users(db: Session, offset: int, limit: int, order: str = "created_desc") -> Sequence[User]:
    order_col: Any = {
        "created_asc": asc(User.created_at),
        "created_desc": desc(User.created_at),
        "username_asc": asc(User.username),
        "username_desc": desc(User.username),
    }.get(order, desc(User.created_at))
    stmt = select(User).order_by(order_col).offset(offset).limit(limit)
    return db.scalars(stmt).all()


def count_users(db: Session) -> int:
    return db.scalar(select(func.count()).select_from(User)) or 0


def last_ts_users(db: Session):
    # utilise COALESCE(updated_at, created_at) pour robustesse
    return db.scalar(select(func.max(func.coalesce(User.updated_at, User.created_at))))


def create_user(db: Session, username: str, password_hash: str, role: str = "user") -> User:
    u = User(username=username, password_hash=password_hash, role=role)
    db.add(u)
    db.flush()
    db.refresh(u)
    return u


def promote_to_admin(db: Session, username: str) -> User | None:
    u = get_by_username(db, username)
    if not u:
        return None
    u.role = "admin"
    db.add(u)
    db.flush()
    db.refresh(u)
    return u
