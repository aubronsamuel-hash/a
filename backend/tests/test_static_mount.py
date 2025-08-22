from __future__ import annotations

from pathlib import Path

from app.config import settings
from app.main import create_app
from fastapi.testclient import TestClient


def test_spa_mount_ok(tmp_path: Path) -> None:
    dist = tmp_path / "dist"
    dist.mkdir(parents=True, exist_ok=True)
    (dist / "index.html").write_text(
        "<!doctype html><html><body>Hello SPA</body></html>", encoding="utf-8"
    )
    settings.FRONT_DIST_DIR = str(dist)
    try:
        app = create_app()
    finally:
        settings.FRONT_DIST_DIR = ""
    client = TestClient(app)
    r = client.get("/")
    assert r.status_code == 200
    assert "Hello SPA" in r.text


def test_spa_mount_ko_when_missing(tmp_path: Path) -> None:
    settings.FRONT_DIST_DIR = str(tmp_path / "nope")
    try:
        app = create_app()
    finally:
        settings.FRONT_DIST_DIR = ""
    client = TestClient(app)
    r = client.get("/")
    assert r.status_code == 404
