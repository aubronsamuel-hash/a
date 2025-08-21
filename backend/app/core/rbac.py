from typing import List, Set

from fastapi import Depends, HTTPException, Request, status

from .config import get_settings
from .security import decode_jwt


def get_current_principal(request: Request):
    auth = request.headers.get("Authorization")
    if not auth or not auth.lower().startswith("bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Token manquant"
        )
    token = auth.split(" ", 1)[1].strip()
    settings = get_settings()
    payload = decode_jwt(token, settings.JWT_SECRET, [settings.JWT_ALGO])
    roles = payload.get("roles")
    if roles is None:
        role = payload.get("role")
        roles = [role] if role else []
    if not isinstance(roles, list):
        roles = []
    principal = {
        "sub": payload.get("sub"),
        "email": payload.get("email"),
        "roles": roles,
        "payload": payload,
    }
    return principal


def require_roles(required: List[str]):
    req: Set[str] = set([r.strip() for r in required if r and r.strip()])
    if not req:
        async def _noop(principal=Depends(get_current_principal)):
            return principal
        return _noop

    async def _enforcer(principal=Depends(get_current_principal)):
        roles = set(principal.get("roles") or [])
        if roles.intersection(req):
            return principal
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Acces refuse: role insuffisant",
        )

    return _enforcer
