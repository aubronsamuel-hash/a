from __future__ import annotations

from fastapi import APIRouter, Depends
from pydantic import BaseModel

from .deps import get_current_user, pagination_params

router = APIRouter()


class HealthModel(BaseModel):
    status: str
    version: str


@router.get("/healthz", response_model=HealthModel, tags=["health"])
def healthz() -> HealthModel:
    return HealthModel(status="ok", version="0.2.0")


class EchoIn(BaseModel):
    message: str


class EchoOut(BaseModel):
    message: str
    page: int
    page_size: int


@router.post("/echo", response_model=EchoOut, tags=["debug"])
def echo(payload: EchoIn, pg: dict[str, int] = Depends(pagination_params)) -> EchoOut:  # noqa: B008
    return EchoOut(message=payload.message, page=pg["page"], page_size=pg["page_size"])


class MeOut(BaseModel):
    username: str


@router.get("/auth/me", response_model=MeOut, tags=["auth"])
def me(current: dict[str, str] = Depends(get_current_user)) -> MeOut:  # noqa: B008
    return MeOut(username=current["username"])


class SecretOut(BaseModel):
    secret: str


@router.get("/debug/secret", response_model=SecretOut, tags=["debug"])
def secret(current: dict[str, str] = Depends(get_current_user)) -> SecretOut:  # noqa: B008
    return SecretOut(secret=f"Bonjour {current['username']}, zone protegee.")
