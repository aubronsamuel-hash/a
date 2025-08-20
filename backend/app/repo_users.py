from __future__ import annotations

from collections.abc import Sequence

from sqlalchemy import select
from sqlalchemy.orm import Session

from .models import User


def get_by_username(db: Session, username: str) -> User | None:
    return db.scalar(select(User).where(User.username == username))


def list_users(db: Session, offset: int, limit: int) -> Sequence[User]:
    return db.scalars(select(User).offset(offset).limit(limit)).all()


def create_user(db: Session, username: str, password_hash: str) -> User:
    u = User(username=username, password_hash=password_hash)
    db.add(u)
    db.flush()
    db.refresh(u)
    return u
