from __future__ import annotations

import json
from pathlib import Path

from app.main import create_app
from fastapi.testclient import TestClient
from tools.export_openapi import main as export_main


def test_openapi_endpoint_ok() -> None:
    app = create_app()
    c = TestClient(app)
    r = c.get("/openapi.json")
    assert r.status_code == 200
    data = r.json()
    assert "openapi" in data
    assert "info" in data and "title" in data["info"] and "version" in data["info"]


def test_openapi_export_offline_writes_file(tmp_path: Path, monkeypatch) -> None:
    monkeypatch.setenv("EXPORT_OPENAPI_DIR", str(tmp_path))
    monkeypatch.setenv("EXPORT_OPENAPI_FILE", "schema.json")
    # s assurer d un PYTHONPATH correct en environnement de test
    monkeypatch.setenv("PYTHONPATH", "backend")
    rc = export_main()
    assert rc == 0
    p = tmp_path / "schema.json"
    assert p.exists()
    data = json.loads(p.read_text(encoding="utf-8"))
    assert "openapi" in data and isinstance(data["openapi"], str)
