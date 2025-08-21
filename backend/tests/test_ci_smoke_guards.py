from __future__ import annotations

import pathlib


def test_ci_scripts_exist_for_observability_and_cli() -> None:
    for p in [
        ".github/workflows/cli_docker.yml",
        ".github/workflows/observability.yml",
        "docker-compose.observability.yml",
    ]:
        assert pathlib.Path(p).exists()
