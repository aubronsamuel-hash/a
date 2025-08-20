$ErrorActionPreference = "Stop"
..venv\Scripts\python.exe -m ruff check backend
..venv\Scripts\python.exe -m mypy backend
