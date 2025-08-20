from __future__ import annotations

import logging
from logging import Formatter, StreamHandler

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from starlette.responses import JSONResponse

from .api import router as api_router
from .auth import router as auth_router
from .config import settings


def _setup_logging() -> None:
    level = getattr(logging, settings.APP_LOG_LEVEL.upper(), logging.INFO)
    logging.basicConfig(level=level)
    handler = StreamHandler()
    handler.setFormatter(Formatter("%(asctime)s [%(levelname)s] %(message)s"))
    root = logging.getLogger()
    root.handlers = [handler]


def create_app() -> FastAPI:
    _setup_logging()
    app = FastAPI(title=settings.APP_NAME)
    if settings.CORS_ORIGINS:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=settings.CORS_ORIGINS,
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )

    @app.middleware("http")
    async def logging_mw(request: Request, call_next):
        logging.info("Requete %s %s", request.method, request.url.path)
        response = await call_next(request)
        return response

    @app.exception_handler(Exception)
    async def on_error(request: Request, exc: Exception):
        logging.exception("Erreur serveur: %s", exc)
        return JSONResponse({"detail": "Erreur interne serveur"}, status_code=500)

    app.include_router(auth_router)
    app.include_router(api_router)
    return app


app = create_app()
