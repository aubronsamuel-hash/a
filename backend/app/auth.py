from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Request, Response, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from .audit_log import write_event
from .config import settings
from .deps import get_current_user, get_db
from .hash import hash_password, verify_password
from .rate_limit import get_limiter
from .repo_users import get_by_username
from .schemas import ChangePasswordIn
from .security import (
    create_access_token,
    create_refresh_token,
    decode_refresh_token,
)

router = APIRouter()
_auth_limiter = get_limiter(settings.RATE_LIMIT_BACKEND, settings.REDIS_URL)


class TokenOut(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class LoginIn(BaseModel):
    username: str
    password: str


def _auth_rl_check(ip: str) -> None:
    if not settings.RATE_LIMIT_ENABLE:
        return
    ok, _remaining, reset_in = _auth_limiter.allow(
        key=f"auth:{ip}",
        max_calls=settings.RATE_LIMIT_AUTH_MAX,
        window_seconds=settings.RATE_LIMIT_AUTH_WINDOW_SECONDS,
    )
    if not ok:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Trop de tentatives. Reessayez plus tard.",
            headers={"Retry-After": str(reset_in)},
        )


@router.post("/auth/token", response_model=TokenOut, tags=["auth"])
def login(request: Request, form: LoginIn, db: Session = Depends(get_db)) -> TokenOut:  # noqa: B008
    ip = request.client.host if request.client else "unknown"
    _auth_rl_check(ip)
    user = get_by_username(db, form.username)
    if not user or not verify_password(form.password, user.password_hash):
        write_event(
            action="auth.login",
            actor=form.username,
            status="failure",
            ip=ip,
            meta={"reason": "invalid_credentials"},
        )
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Identifiants invalides",
        )
    access = create_access_token(sub=user.username, role=user.role)
    refresh = create_refresh_token(sub=user.username, role=user.role)
    write_event(
        action="auth.login",
        actor=user.username,
        status="success",
        ip=ip,
        meta={"role": user.role},
    )
    return TokenOut(access_token=access, refresh_token=refresh, token_type="bearer")


class RefreshIn(BaseModel):
    refresh_token: str


@router.post("/auth/refresh", response_model=TokenOut, tags=["auth"])
def refresh(body: RefreshIn) -> TokenOut:
    data = decode_refresh_token(body.refresh_token)
    access = create_access_token(sub=data.sub, role=data.role)
    refresh_tok = create_refresh_token(sub=data.sub, role=data.role)
    return TokenOut(access_token=access, refresh_token=refresh_tok, token_type="bearer")


@router.post("/auth/change-password", status_code=204, tags=["auth"])
def change_password(
    body: ChangePasswordIn,
    db: Session = Depends(get_db),  # noqa: B008
    current=Depends(get_current_user),  # noqa: B008
):
    user = get_by_username(db, current["username"])
    assert user is not None
    if not verify_password(body.old_password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Ancien mot de passe incorrect"
        )
    user.password_hash = hash_password(body.new_password)
    db.add(user)
    db.commit()
    return Response(status_code=204)

