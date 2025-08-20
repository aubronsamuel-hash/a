from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from .deps import get_db, pagination_params, require_admin
from .hash import hash_password
from .repo_users import create_user, get_by_username, list_users, promote_to_admin
from .schemas import UserCreateIn, UserOut

router = APIRouter()


@router.get("/users", response_model=list[UserOut], tags=["users"])
def users_list(
    pg=Depends(pagination_params),  # noqa: B008
    db: Session = Depends(get_db),  # noqa: B008
    _: dict = Depends(require_admin),  # noqa: B008
) -> list[UserOut]:
    offset = (pg["page"] - 1) * pg["page_size"]
    items = list_users(db, offset=offset, limit=pg["page_size"])
    return [UserOut.model_validate(i) for i in items]


@router.post("/users", response_model=UserOut, status_code=201, tags=["users"])
def users_create(
    body: UserCreateIn,
    db: Session = Depends(get_db),  # noqa: B008
    _: dict = Depends(require_admin),  # noqa: B008
) -> UserOut:
    if get_by_username(db, body.username):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Username deja utilise")
    u = create_user(db, username=body.username, password_hash=hash_password(body.password))
    db.commit()
    return UserOut.model_validate(u)


@router.post("/users/{username}/promote", response_model=UserOut, tags=["users"])
def users_promote(
    username: str,
    db: Session = Depends(get_db),  # noqa: B008
    _: dict = Depends(require_admin),  # noqa: B008
) -> UserOut:
    u = promote_to_admin(db, username)
    if not u:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Utilisateur introuvable")
    db.commit()
    return UserOut.model_validate(u)

