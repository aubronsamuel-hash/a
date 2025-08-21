from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse

from ..core.rbac import get_current_principal, require_roles

router = APIRouter(prefix="", tags=["protected"])


@router.get("/me/ping")
async def me_ping(principal=Depends(get_current_principal)):
    return JSONResponse(
        {"ok": True, "user": {"sub": principal.get("sub"), "roles": principal.get("roles")}}
    )


@router.get("/admin/ping")
async def admin_ping(principal=Depends(require_roles(["admin"]))):
    return JSONResponse(
        {
            "ok": True,
            "admin": True,
            "user": {"sub": principal.get("sub"), "roles": principal.get("roles")},
        }
    )
