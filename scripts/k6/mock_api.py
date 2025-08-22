from fastapi import FastAPI
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST
from starlette.responses import Response
app = FastAPI(title="MockAPI")
@app.get("/healthz")
def healthz():
    return {"status": "ok"}
@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
