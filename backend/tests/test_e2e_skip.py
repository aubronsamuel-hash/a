import subprocess
from pathlib import Path


def test_e2e_run_respects_skip():
    skip_file = Path(".e2e_skip.env")
    skip_file.write_text("E2E_SKIP=1\n")
    try:
        result = subprocess.run(
            ["bash", "scripts/bash/e2e_run.sh"],
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0
        assert "E2E SKIP" in result.stdout
    finally:
        skip_file.unlink(missing_ok=True)
