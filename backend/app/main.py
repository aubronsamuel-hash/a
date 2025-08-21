from __future__ import annotations

import contextvars
import json
import logging
from datetime import UTC, datetime
from logging import Formatter, LogRecord, StreamHandler
from pathlib import Path
from uuid import uuid4

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from prometheus_fastapi_instrumentator import Instrumentator
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError
from starlette.responses import JSONResponse, Response
from starlette.staticfiles import StaticFiles

from .api import router as api_router
from .auth import router as auth_router
from .config import settings
from .db import Base, engine, session_scope
from .hash import hash_password
from .rate_limit import get_limiter
from .repo_users import create_user, get_by_username
from .security_headers import SecurityHeadersMiddleware
from .users_api import router as users_router

_request_id_ctx: contextvars.ContextVar[str | None] = contextvars.ContextVar(
    "request_id", default=None
)
_global_limiter = get_limiter(settings.RATE_LIMIT_BACKEND, settings.REDIS_URL)


class JsonFormatter(Formatter):
    def format(self, record: LogRecord) -> str:  # noqa: D401 - simple JSON formatter
        payload: dict[str, object] = {
            "ts": datetime.now(tz=UTC).isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
        }
        rid = _request_id_ctx.get()
        if rid:
            payload["request_id"] = rid
        if hasattr(record, "path"):
            payload["path"] = record.path
        if hasattr(record, "status_code"):
            payload["status"] = record.status_code
        return json.dumps(payload, ensure_ascii=True)


def _setup_logging() -> None:
    level = getattr(logging, settings.APP_LOG_LEVEL.upper(), logging.INFO)
    logging.basicConfig(level=level)
    handler = StreamHandler()
    if settings.LOG_JSON:
        handler.setFormatter(JsonFormatter())
    else:
        handler.setFormatter(Formatter("%(asctime)s [%(levelname)s] %(message)s"))
    root = logging.getLogger()
    root.handlers = [handler]


def _auto_seed_admin() -> None:
    if not settings.ADMIN_AUTOSEED:
        return
    with session_scope() as db:
        u = get_by_username(db, settings.ADMIN_USERNAME)
        if u:
            if getattr(u, "role", "user") != "admin":
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


MAINT_ALLOW_PATHS = {"/healthz", "/livez", "/readyz", "/metrics"}


def create_app() -> FastAPI:
    _setup_logging()
    Base.metadata.create_all(bind=engine)
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

    app.add_middleware(SecurityHeadersMiddleware)

    # Request ID middleware
    @app.middleware("http")
    async def request_id_mw(request: Request, call_next):  # noqa: D401 - middleware
        req_hdr = settings.REQUEST_ID_HEADER
        rid = request.headers.get(req_hdr) or str(uuid4())
        _request_id_ctx.set(rid)
        try:
            response: Response = await call_next(request)
        finally:
            pass
        response.headers[req_hdr] = rid
        return response

    # Maintenance Mode (503)
    @app.middleware("http")
    async def maintenance_mw(request: Request, call_next):
        if settings.MAINTENANCE_MODE and request.url.path not in MAINT_ALLOW_PATHS:
            logging.warning(
                "Maintenance active - blocage requete", extra={"path": request.url.path}
            )
            return JSONResponse(
                {"detail": "Maintenance en cours. Revenez plus tard."},
                status_code=503,
                headers={"Retry-After": str(settings.MAINTENANCE_RETRY_AFTER_SECONDS)},
            )
        return await call_next(request)

    # Read-only Mode (423)
    @app.middleware("http")
    async def readonly_mw(request: Request, call_next):
        if settings.READ_ONLY_MODE:
            method = request.method.upper()
            if method in {"POST", "PUT", "PATCH", "DELETE"} and not request.url.path.startswith(
                "/auth/"
            ):
                logging.warning(
                    "Lecture seule active - mutation bloquee",
                    extra={"path": request.url.path},
                )
                return JSONResponse(
                    {"detail": "Mode lecture seule actif. Operation interdite."},
                    status_code=423,
                )
        return await call_next(request)

    # Global rate limit middleware
    @app.middleware("http")
    async def rate_limit_global_mw(request: Request, call_next):  # noqa: D401 - middleware
        if settings.RATE_LIMIT_ENABLE:
            ip = request.client.host if request.client else "unknown"
            ok, _remaining, reset_in = _global_limiter.allow(
                key=f"global:{ip}",
                max_calls=settings.RATE_LIMIT_GLOBAL_MAX,
                window_seconds=settings.RATE_LIMIT_GLOBAL_WINDOW_SECONDS,
            )
            if not ok:
                return JSONResponse(
                    {"detail": "Trop de requetes. Reessayez plus tard."},
                    status_code=429,
                    headers={"Retry-After": str(reset_in)},
                )
        return await call_next(request)

    # Logging middleware
    @app.middleware("http")
    async def logging_mw(request: Request, call_next):  # noqa: D401 - middleware
        logging.info(
            json.dumps({"event": "request", "method": request.method, "path": request.url.path})
        )
        response: Response = await call_next(request)
        rec = logging.getLogger().makeRecord(
            name="app", level=logging.INFO, fn="", lno=0, msg="response", args=(), exc_info=None
        )
        rec.path = request.url.path
        rec.status_code = getattr(response, "status_code", 0)
        logging.getLogger().handle(rec)
        return response

    @app.exception_handler(Exception)
    async def on_error(request: Request, exc: Exception):  # noqa: D401 - simple handler
        logging.exception("Erreur serveur: %s", exc)
        return JSONResponse({"detail": "Erreur interne serveur"}, status_code=500)

    @app.get("/livez", tags=["health"])
    def livez():  # noqa: D401 - health endpoint
        return {"status": "alive"}

    @app.get("/readyz", tags=["health"])
    def readyz():  # noqa: D401 - readiness endpoint
        try:
            with engine.connect() as conn:
                conn.execute(text("SELECT 1"))
            return {"status": "ready"}
        except Exception:  # pragma: no cover - defensive
            return JSONResponse({"status": "not-ready"}, status_code=503)

    app.include_router(auth_router)
    app.include_router(api_router)
    app.include_router(users_router)

    Instrumentator().instrument(app).expose(app, endpoint="/metrics")

    if settings.FRONT_DIST_DIR:
        dist = Path(settings.FRONT_DIST_DIR).resolve()
        if dist.exists() and dist.is_dir():
            app.mount("/", StaticFiles(directory=str(dist), html=True), name="spa")

    return app


app = create_app()

