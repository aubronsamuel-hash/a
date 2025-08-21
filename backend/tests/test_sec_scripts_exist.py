from __future__ import annotations
import stat
import pathlib

def test_sec_scripts_present_and_executable():
    for p in [
        "scripts/bash/sec_pip_audit.sh",
        "scripts/bash/sec_trivy_image.sh",
    ]:
        f = pathlib.Path(p)
        assert f.exists(), f"{p} manquant"
        mode = f.stat().st_mode
        assert mode & stat.S_IXUSR, f"{p} non executable"
