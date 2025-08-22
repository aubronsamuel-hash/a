import logging
import logging.handlers
import os
from pathlib import Path


def setup_logging_from_env() -> None:
    """Configure logging selon variables env.
    LOG_TO_FILE=1 -> RotatingFileHandler, sinon stdout.
    """
    root = logging.getLogger()
    root.handlers.clear()
    level_name = os.getenv("LOG_LEVEL", "INFO").upper()
    level = getattr(logging, level_name, logging.INFO)
    root.setLevel(level)
    handler: logging.Handler
    if os.getenv("LOG_TO_FILE", "0").lower() in ("1", "true", "yes"):
        path = Path(os.getenv("LOG_FILE_PATH", "logs/app.log"))
        path.parent.mkdir(parents=True, exist_ok=True)
        handler = logging.handlers.RotatingFileHandler(
            filename=str(path),
            maxBytes=int(os.getenv("LOG_FILE_MAX_BYTES", "10485760")),
            backupCount=int(os.getenv("LOG_FILE_BACKUP_COUNT", "5")),
            encoding="utf-8",
        )
        fmt = logging.Formatter(
            fmt="%(asctime)s %(levelname)s %(name)s %(message)s",
            datefmt="%Y-%m-%dT%H:%M:%S"
        )
        handler.setFormatter(fmt)
        root.addHandler(handler)
    else:
        handler = logging.StreamHandler()
        fmt = logging.Formatter("%(asctime)s %(levelname)s %(name)s %(message)s")
        handler.setFormatter(fmt)
        root.addHandler(handler)

def get_logger(name: str) -> logging.Logger:
    return logging.getLogger(name)
