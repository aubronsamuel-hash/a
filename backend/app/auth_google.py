import hashlib
import hmac
from datetime import datetime, timedelta, timezone
from urllib.parse import urlencode

import jwt  # PyJWT
from fastapi import APIRouter, HTTPException, Request
from fastapi.responses import JSONResponse, RedirectResponse

from .core.config import get_settings

router = APIRouter(prefix="/auth/google", tags=["auth"])

GOOGLE_AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth"


def _make_state(secret: str) -> str:
    ts = str(int(datetime.now(tz=timezone.utc).timestamp()))
    mac = hmac.new(secret.encode("utf-8"), ts.encode("utf-8"), hashlib.sha256).hexdigest()
    return f"{ts}.{mac[:16]}"


def _build_auth_url(settings) -> str:
    if not settings.GOOGLE_CLIENT_ID or not settings.GOOGLE_REDIRECT_URI:
        raise ValueError("GOOGLE_CLIENT_ID/GOOGLE_REDIRECT_URI manquants")
    scopes = " ".join(settings.GOOGLE_SCOPES)
    params = {
        "client_id": settings.GOOGLE_CLIENT_ID,
        "redirect_uri": settings.GOOGLE_REDIRECT_URI,
        "response_type": "code",
        "scope": scopes,
        "access_type": "offline",
        "include_granted_scopes": "true",
        "prompt": "consent",
        "state": _make_state(settings.STATE_SECRET),
    }
    return f"{GOOGLE_AUTH_URL}?{urlencode(params)}"


def _issue_app_jwt(settings, sub: str, email: str | None = None) -> str:
    now = datetime.now(tz=timezone.utc)
    payload = {
        "iss": settings.APP_NAME,
        "sub": sub,
        "email": email,
        "provider": "google",
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(minutes=settings.JWT_EXPIRE_MINUTES)).timestamp()),
    }
    token = jwt.encode(payload, settings.JWT_SECRET, algorithm=settings.JWT_ALGO)
    if isinstance(token, bytes):
        token = token.decode("utf-8")
    return token


@router.get("/start")
async def google_start():
    settings = get_settings()
    try:
        url = _build_auth_url(settings)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    return RedirectResponse(url=url, status_code=307)


@router.post("/test-callback")
async def google_test_callback(request: Request):
    settings = get_settings()
    if not settings.OAUTH_GOOGLE_TEST_MODE:
        raise HTTPException(status_code=403, detail="test-mode desactive")
    data = await request.json()
    email = data.get("email")
    sub = data.get("sub") or (f"google:{email}" if email else None)
    if not sub:
        raise HTTPException(status_code=422, detail="sub ou email requis en test-mode")
    token = _issue_app_jwt(settings, sub=sub, email=email)
    return JSONResponse({"token": token, "user": {"sub": sub, "email": email, "provider": "google"}})
