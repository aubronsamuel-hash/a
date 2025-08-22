import os
import subprocess
import sys


def test_cli_prints_ok():
    out = subprocess.check_output(["python","-c","print('coulisses-cli: OK')"]).decode()
    assert "coulisses-cli: OK" in out
