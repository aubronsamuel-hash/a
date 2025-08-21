from __future__ import annotations

import pathlib
import stat


def test_k6_assets_present():
    for p in ["docker-compose.k6.yml", "load/k6/smoke.js", "scripts/bash/load_k6.sh", "PS1/load_k6.ps1"]:
        f = pathlib.Path(p)
        assert f.exists(), f"{p} manquant"
        if f.suffix in (".sh",):
            assert f.stat().st_mode & stat.S_IXUSR, f"{p} non executable"
