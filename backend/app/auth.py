from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from .deps import get_db
from .hash import verify_password
from .repo_users import get_by_username
from .security import create_access_token

router = APIRouter()


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"


class LoginIn(BaseModel):
    username: str
    password: str


@router.post("/auth/token", response_model=TokenOut, tags=["auth"])
def login(form: LoginIn, db: Session = Depends(get_db)):  # noqa: B008
    user = get_by_username(db, form.username)
    if not user or not verify_password(form.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Identifiants invalides",
        )
    token = create_access_token(sub=form.username)
    return {"access_token": token, "token_type": "bearer"}
