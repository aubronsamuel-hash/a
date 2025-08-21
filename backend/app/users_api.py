from __future__ import annotations

import hashlib
from math import ceil

from fastapi import APIRouter, Depends, Header, HTTPException, Query, Response, status
from sqlalchemy.orm import Session

from .audit_log import write_event
from .deps import get_db, pagination_params, require_admin
from .hash import hash_password
from .repo_users import (
    count_users,
    create_user,
    get_by_username,
    last_ts_users,
    list_users,
)
from .schemas import PageMeta, UserCreateIn, UserOut, UsersListOut

router = APIRouter()


def _compute_etag(
    total: int, last_ts: object | None, page: int, page_size: int, order: str
) -> str:
    last_str = str(last_ts) if last_ts is not None else "0"
    raw = f"{total}:{last_str}:{page}:{page_size}:{order}"
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


@router.get("/users", response_model=UsersListOut, tags=["users"])
def users_list(
    response: Response,
    pg=Depends(pagination_params),  # noqa: B008
    db: Session = Depends(get_db),  # noqa: B008
    _: dict = Depends(require_admin),  # noqa: B008
    order: str = Query(default="created_desc", pattern="^(created|username)_(asc|desc)$"),
    if_none_match: str | None = Header(default=None, alias="If-None-Match"),
) -> UsersListOut | Response:
    total = count_users(db)
    pages = ceil(max(total, 1) / pg["page_size"])
    page = min(max(pg["page"], 1), max(pages, 1))
    items = list_users(
        db,
        offset=(page - 1) * pg["page_size"],
        limit=pg["page_size"],
        order=order,
    )
    last_ts = last_ts_users(db)
    etag = _compute_etag(total, last_ts, page, pg["page_size"], order)
    if if_none_match and if_none_match == etag:
        response.headers["ETag"] = etag
        response.headers["Cache-Control"] = "private, max-age=30"
        return Response(status_code=304)
    response.headers["ETag"] = etag
    response.headers["Cache-Control"] = "private, max-age=30"
    meta = PageMeta(total=total, pages=pages, page=page, page_size=pg["page_size"], etag=etag)
    return UsersListOut(meta=meta, data=[UserOut.model_validate(i) for i in items])


@router.post("/users", response_model=UserOut, status_code=201, tags=["users"])
def users_create(
    body: UserCreateIn,
    db: Session = Depends(get_db),  # noqa: B008
    current: dict = Depends(require_admin),  # noqa: B008
) -> UserOut:
    if get_by_username(db, body.username):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Username deja utilise")
    u = create_user(db, username=body.username, password_hash=hash_password(body.password))
    db.commit()
    write_event(
        action="user.create",
        actor=current["username"],
        status="success",
        target=u.username,
        meta={"role": getattr(u, "role", "user")},
    )
    return UserOut.model_validate(u)


@router.post("/users/{username}/promote", response_model=UserOut, tags=["users"])
def users_promote(
    username: str,
    db: Session = Depends(get_db),  # noqa: B008
    current: dict = Depends(require_admin),  # noqa: B008
) -> UserOut:
    from .repo_users import promote_to_admin  # import tardif pour limiter cycles

    u = promote_to_admin(db, username)
    if not u:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Utilisateur introuvable")
    db.commit()
    write_event(
        action="user.promote",
        actor=current["username"],
        status="success",
        target=username,
    )
    return UserOut.model_validate(u)
