from __future__ import annotations

import os

from fastapi import APIRouter

from .features import KNOWN_FEATURES, parse_features

router = APIRouter()


@router.get("/features", tags=["features"])
def get_features():
    env_val = os.getenv("FEATURES_ENABLED")
    parsed = parse_features(env_val)
    return {
        "known": sorted(KNOWN_FEATURES),
        "enabled": [k for k, v in parsed.items() if v],
        "raw": env_val or "",
    }
