from __future__ import annotations

from datetime import UTC, datetime, timedelta

import jwt
from fastapi import HTTPException, status
from pydantic import BaseModel

from .config import settings


class TokenData(BaseModel):
    sub: str
    role: str
    exp: int


def _encode(payload: dict, secret: str, algo: str) -> str:
    return jwt.encode(payload, secret, algorithm=algo)


def _decode(token: str, secret: str, algos: list[str]) -> dict:
    return jwt.decode(token, secret, algorithms=algos)


def create_access_token(sub: str, role: str) -> str:
    expire = datetime.now(tz=UTC) + timedelta(seconds=settings.JWT_TTL_SECONDS)
    payload = {"sub": sub, "role": role, "exp": int(expire.timestamp()), "typ": "access"}
    return _encode(payload, settings.JWT_SECRET, settings.JWT_ALGO)


def create_refresh_token(sub: str, role: str) -> str:
    expire = datetime.now(tz=UTC) + timedelta(seconds=settings.REFRESH_JWT_TTL_SECONDS)
    payload = {"sub": sub, "role": role, "exp": int(expire.timestamp()), "typ": "refresh"}
    return _encode(payload, settings.REFRESH_JWT_SECRET, settings.JWT_ALGO)


def decode_access_token(token: str) -> TokenData:
    try:
        payload = _decode(token, settings.JWT_SECRET, [settings.JWT_ALGO])
        if payload.get("typ") != "access":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Token invalide (type)"
            )
        return TokenData(
            sub=str(payload.get("sub")),
            role=str(payload.get("role")),
            exp=int(payload.get("exp", 0)),
        )
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


def decode_refresh_token(token: str) -> TokenData:
    try:
        payload = _decode(token, settings.REFRESH_JWT_SECRET, [settings.JWT_ALGO])
        if payload.get("typ") != "refresh":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh invalide (type)"
            )
        return TokenData(
            sub=str(payload.get("sub")),
            role=str(payload.get("role")),
            exp=int(payload.get("exp", 0)),
        )
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh expire",
        ) from None
    except jwt.InvalidTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh invalide",
        ) from None

