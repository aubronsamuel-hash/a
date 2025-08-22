from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator


def setup_metrics(app: FastAPI, endpoint: str = "/metrics") -> None:
    # Instrumentation standard: latences, compteurs, tailles reponses, etc.
    Instrumentator().instrument(app).expose(app, endpoint=endpoint, include_in_schema=False)
