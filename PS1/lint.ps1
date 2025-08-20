$ErrorActionPreference = "Stop"
.\.venv\Scripts\python.exe -m ruff backend
.\.venv\Scripts\python.exe -m mypy backend
