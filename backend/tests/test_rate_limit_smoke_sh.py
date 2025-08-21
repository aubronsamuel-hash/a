from __future__ import annotations

import os
import subprocess
from pathlib import Path


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


def test_smoke_rate_limit_memory(tmp_path: Path) -> None:
    env = os.environ.copy()
    env.update({"BASE": "http://localhost:8001"})
    curl = tmp_path / "curl"
    curl.write_text(
        "#!/usr/bin/env bash\n"
        'if [[ "${@: -1}" == "http://localhost:8001/healthz" ]]; then\n'
        "  printf '200'\n"
        "else\n"
        "  printf '401'\n"
        "fi\n"
    )
    curl.chmod(0o755)
    env["PATH"] = f"{tmp_path}:{os.environ['PATH']}"
    res = subprocess.run(
        ["/bin/bash", "scripts/bash/smoke_rate_limit.sh"],
        env=env,
        capture_output=True,
        text=True,
        timeout=30,
    )
    assert res.returncode == 0, res.stdout + res.stderr
    assert "Smoke rate-limit" in res.stdout


def test_smoke_rate_limit_sh_skips_without_python(tmp_path: Path) -> None:
    env = os.environ.copy()
    env.update({"BASE": "http://localhost:8001", "PATH": str(tmp_path)})
    curl = tmp_path / "curl"
    curl.write_text("#!/usr/bin/env bash\nprintf '000'\n")
    curl.chmod(0o755)
    res = subprocess.run(
        ["/bin/bash", "scripts/bash/smoke_rate_limit.sh"],
        env=env,
        capture_output=True,
        text=True,
        timeout=30,
    )
    assert res.returncode == 0, res.stdout + res.stderr
    assert "python absent" in (res.stdout + res.stderr)


def test_smoke_rate_limit_redis_sh_skips_without_curl(tmp_path: Path) -> None:
    env = os.environ.copy()
    env.update({"PATH": str(tmp_path)})
    res = subprocess.run(
        ["/bin/bash", "scripts/bash/smoke_rate_limit_redis.sh"],
        env=env,
        capture_output=True,
        text=True,
        timeout=30,
    )
    assert res.returncode == 0, res.stdout + res.stderr
    assert "curl indisponible" in (res.stdout + res.stderr)
