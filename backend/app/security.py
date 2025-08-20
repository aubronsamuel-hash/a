from __future__ import annotations

from datetime import UTC, datetime, timedelta

import jwt
from fastapi import HTTPException, status
from pydantic import BaseModel

from .config import settings


class TokenData(BaseModel):
    sub: str
    exp: int


def create_access_token(sub: str) -> str:
    expire = datetime.now(tz=UTC) + timedelta(seconds=settings.JWT_TTL_SECONDS)
    payload = {"sub": sub, "exp": int(expire.timestamp())}
    token = jwt.encode(payload, settings.JWT_SECRET, algorithm=settings.JWT_ALGO)
    return token


def decode_access_token(token: str) -> TokenData:
    try:
        payload = jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGO])
        return TokenData(sub=str(payload.get("sub")), exp=int(payload.get("exp")))
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token expire",
        ) from None
    except jwt.InvalidTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token invalide",
        ) from None
