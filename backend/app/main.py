from __future__ import annotations

import logging
from logging import Formatter, StreamHandler

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.exc import IntegrityError
from starlette.responses import JSONResponse

from .api import router as api_router
from .auth import router as auth_router
from .config import settings
from .db import Base, engine, session_scope
from .hash import hash_password
from .repo_users import create_user, get_by_username
from .users_api import router as users_router


def _setup_logging() -> None:
    level = getattr(logging, settings.APP_LOG_LEVEL.upper(), logging.INFO)
    logging.basicConfig(level=level)
    handler = StreamHandler()
    handler.setFormatter(Formatter("%(asctime)s [%(levelname)s] %(message)s"))
    root = logging.getLogger()
    root.handlers = [handler]


def _auto_seed_admin() -> None:
    if not settings.ADMIN_AUTOSEED:
        return
    with session_scope() as db:
        u = get_by_username(db, settings.ADMIN_USERNAME)
        if u:
            if u.role != "admin":
                u.role = "admin"
                db.add(u)
            return
        try:
            create_user(
                db,
                settings.ADMIN_USERNAME,
                hash_password(settings.ADMIN_PASSWORD),
                role="admin",
            )
            logging.info("Admin autoseed cree: %s", settings.ADMIN_USERNAME)
        except IntegrityError:
            db.rollback()


def create_app() -> FastAPI:
    _setup_logging()
    # Init DB schema
    Base.metadata.create_all(bind=engine)

    # Auto-seed admin
    _auto_seed_admin()

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
    app.include_router(users_router)
    return app


app = create_app()
