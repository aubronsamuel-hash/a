from fastapi import APIRouter
from fastapi.responses import JSONResponse
from sqlalchemy.exc import OperationalError
from sqlalchemy import text
from .db import SessionLocal

router = APIRouter()

@router.get("/healthz")
def healthz():
    return JSONResponse({"status": "ok"})

@router.get("/readyz")
def readyz():
    try:
        db = SessionLocal()
        db.execute(text("SELECT 1"))
        db.close()
        return JSONResponse({"status": "ready"})
    except OperationalError:
        return JSONResponse({"status": "db_error"}, status_code=503)
