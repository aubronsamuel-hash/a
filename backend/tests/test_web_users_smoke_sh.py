from __future__ import annotations

import os
import subprocess
import time

import requests


def _start_api(env: dict[str, str]) -> subprocess.Popen:
    proc = subprocess.Popen(
        [
            "uvicorn",
            "app.main:app",
            "--app-dir",
            "backend",
            "--host",
            "0.0.0.0",
            "--port",
            "8001",
        ],
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    base = env.get("BASE", "http://localhost:8001")
    for _ in range(30):
        try:
            if requests.get(f"{base}/healthz", timeout=0.5).status_code == 200:
                return proc
        except Exception:
            pass
        time.sleep(0.5)
    proc.terminate()
    raise RuntimeError("API did not start")


def test_web_users_smoke_script_handles_alt_password(tmp_path: os.PathLike[str]):
    env = os.environ.copy()
    env.update(
        {
            "ADMIN_AUTOSEED": "true",
            "ADMIN_USERNAME": "admin",
            "ADMIN_PASSWORD": "secretXYZ",
            "JWT_SECRET": "test-secret",
            "DB_DSN": f"sqlite:///{tmp_path}/test.db",
            "BASE": "http://localhost:8001",
        }
    )
    proc = _start_api(env)
    try:
        res = subprocess.run(
            ["bash", "scripts/bash/web_users_smoke.sh"],
            env=env,
            capture_output=True,
            text=True,
            timeout=60,
        )
        assert res.returncode == 0, res.stdout + res.stderr
        assert "Front smoke ETag OK" in res.stdout
    finally:
        proc.terminate()
        proc.wait(timeout=5)
