from __future__ import annotations

from fastapi import APIRouter, Depends
from pydantic import BaseModel

from .deps import get_current_user, pagination_params

router = APIRouter()


class HealthModel(BaseModel):
    status: str
    version: str


@router.get("/healthz", response_model=HealthModel, tags=["health"])
def healthz():
    return {"status": "ok", "version": "0.9.0"}


class EchoIn(BaseModel):
    message: str


class EchoOut(BaseModel):
    message: str
    page: int
    page_size: int


@router.post("/echo", response_model=EchoOut, tags=["debug"])
def echo(payload: EchoIn, pg=Depends(pagination_params)):  # noqa: B008
    return {"message": payload.message, "page": pg["page"], "page_size": pg["page_size"]}


class MeOut(BaseModel):
    username: str
    role: str


@router.get("/auth/me", response_model=MeOut, tags=["auth"])
def me(current=Depends(get_current_user)) -> MeOut:  # noqa: B008
    return MeOut(username=current["username"], role=current["role"])
