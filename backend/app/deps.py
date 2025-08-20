from __future__ import annotations

from fastapi import Query

from .config import settings


def pagination_params(
    page: int = Query(1, ge=1, description="Numero de page (>=1)"),
    page_size: int = Query(
        default=settings.APP_DEFAULT_PAGE_SIZE,
        ge=1,
        le=settings.APP_MAX_PAGE_SIZE,
        description="Taille de page",
    ),
):
    return {"page": page, "page_size": page_size}
