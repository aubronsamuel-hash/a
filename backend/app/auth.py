from __future__ import annotations

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel

from .config import settings
from .security import create_access_token

router = APIRouter()


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"


class LoginIn(BaseModel):
    username: str
    password: str


@router.post("/auth/token", response_model=TokenOut, tags=["auth"])
def login(form: LoginIn) -> TokenOut:
    if form.username != settings.DEV_USER or form.password != settings.DEV_PASSWORD:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Identifiants invalides",
        )
    token = create_access_token(sub=form.username)
    return TokenOut(access_token=token)
