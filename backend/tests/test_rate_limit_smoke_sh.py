from __future__ import annotations

import os
import subprocess
import time

import pytest


def _pkill_uvicorn() -> None:
    subprocess.run(
        ["pkill", "-f", "uvicorn app.main:app"],
        check=False,
        capture_output=True,
    )


def test_compose_up_redis_handles_no_docker() -> None:
    res = subprocess.run([
        "bash",
        "scripts/bash/compose_up_redis.sh",
    ], capture_output=True, text=True, timeout=30)
    assert res.returncode == 0, res.stdout + res.stderr
    assert "Docker n'est pas installe" in (res.stderr + res.stdout)


@pytest.mark.timeout(120)
def test_smoke_rate_limit_memory(tmp_path: os.PathLike[str]) -> None:
    env = os.environ.copy()
    env.update(
        {
            "ADMIN_AUTOSEED": "true",
            "ADMIN_USERNAME": "admin",
            "ADMIN_PASSWORD": "admin123",
            "JWT_SECRET": "test-secret",
            "DB_DSN": f"sqlite:///{tmp_path}/test.db",
            "BASE": "http://localhost:8001",
        }
    )
    try:
        res = subprocess.run(
            ["bash", "scripts/bash/smoke_rate_limit.sh"],
            env=env,
            capture_output=True,
            text=True,
            timeout=120,
        )
        assert res.returncode == 0, res.stdout + res.stderr
        assert "Rate limit memory OK" in res.stdout
    finally:
        _pkill_uvicorn()
        time.sleep(1)
