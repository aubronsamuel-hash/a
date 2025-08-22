from __future__ import annotations

from app.features import KNOWN_FEATURES, parse_features
from app.middleware_features import FeaturesHeaderMiddleware
from app.routes_features import router as features_router
from fastapi import FastAPI
from fastapi.testclient import TestClient


def test_parse_features_ok_and_ignore_unknowns():
    # Unknowns ignored
    d = parse_features("observability, unknown1 , rate-limit, ,openapi-export,foo")
    assert d["observability"] is True
    assert d["rate-limit"] is True
    assert d["openapi-export"] is True
    # inconnues doivent exister dans le dict (False si non reconnues)
    for k in KNOWN_FEATURES:
        assert k in d
    # features non citees -> False
    assert d["redis-cache"] is False


def test_endpoint_and_header(monkeypatch):
    monkeypatch.setenv("FEATURES_ENABLED", "security-headers, k6-smoke")
    app = FastAPI()
    app.add_middleware(FeaturesHeaderMiddleware)
    app.include_router(features_router)
    c = TestClient(app)
    r = c.get("/features")
    assert r.status_code == 200
    data = r.json()
    assert "enabled" in data and "known" in data
    # en-tete X-Features present
    assert "x-features" in {k.lower(): v for k, v in r.headers.items()}
    # la valeur de l en-tete reflète les actives
    xf = r.headers.get("X-Features", "")
    assert "security-headers" in xf and "k6-smoke" in xf
