from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from .deps import get_current_user, get_db, pagination_params
from .hash import hash_password
from .repo_users import create_user, get_by_username, list_users
from .schemas import UserCreateIn, UserOut

router = APIRouter()


@router.get("/users", response_model=list[UserOut], tags=["users"])
def users_list(
    pg=Depends(pagination_params),  # noqa: B008
    db: Session = Depends(get_db),  # noqa: B008
    current=Depends(get_current_user),  # noqa: B008
):
    offset = (pg["page"] - 1) * pg["page_size"]
    items = list_users(db, offset=offset, limit=pg["page_size"])
    return [UserOut.model_validate(i) for i in items]


@router.post("/users", response_model=UserOut, status_code=201, tags=["users"])
def users_create(
    body: UserCreateIn,
    db: Session = Depends(get_db),  # noqa: B008
    current=Depends(get_current_user),  # noqa: B008
):
    if get_by_username(db, body.username):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Username deja utilise")
    u = create_user(db, username=body.username, password_hash=hash_password(body.password))
    db.commit()
    return UserOut.model_validate(u)
