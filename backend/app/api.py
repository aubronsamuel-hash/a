from __future__ import annotations

from fastapi import APIRouter, Depends
from pydantic import BaseModel

from .deps import pagination_params

router = APIRouter()


class HealthModel(BaseModel):
    status: str
    version: str


@router.get("/healthz", response_model=HealthModel, tags=["health"])
def healthz() -> HealthModel:
    return HealthModel(status="ok", version="0.1.0")


class EchoIn(BaseModel):
    message: str


class EchoOut(BaseModel):
    message: str
    page: int
    page_size: int


@router.post("/echo", response_model=EchoOut, tags=["debug"])
def echo(payload: EchoIn, pg: dict[str, int] = Depends(pagination_params)) -> EchoOut:  # noqa: B008
    # Exemple de logs cote serveur: on laisse a main.py
    return EchoOut(message=payload.message, page=pg["page"], page_size=pg["page_size"])
