import os
from pathlib import Path

version = "0.1.0"
try:
    vfile = Path(__file__).resolve().parent.parent.parent / "VERSION"
    if vfile.exists():
        version = vfile.read_text(encoding="utf-8").strip()
except Exception:
    pass

__all__ = ["create_app", "version"]
