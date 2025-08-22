import os
import time
from pathlib import Path

from app.logging_setup import get_logger, setup_logging_from_env


def test_rotation_file_ok(tmp_path, monkeypatch):
    # Force ecriture fichier et petite taille pour rotation
    monkeypatch.setenv("LOG_TO_FILE", "1")
    log_path = tmp_path / "test_app.log"
    monkeypatch.setenv("LOG_FILE_PATH", str(log_path))
    monkeypatch.setenv("LOG_FILE_MAX_BYTES", "1024")
    monkeypatch.setenv("LOG_FILE_BACKUP_COUNT", "2")

    setup_logging_from_env()
    logger = get_logger("t")
    for _ in range(300):
        logger.info("x" * 40)
    # Attendre flush/rotation
    time.sleep(0.1)
    assert log_path.exists()
    # Un fichier .1 doit apparaitre apres rotation
    rotated = Path(str(log_path) + ".1")
    assert rotated.exists()


def test_no_file_when_stdout(monkeypatch, tmp_path):
    monkeypatch.setenv("LOG_TO_FILE", "0")
    monkeypatch.setenv("LOG_FILE_PATH", str(tmp_path / "x.log"))
    setup_logging_from_env()
    logger = get_logger("t2")
    logger.info("hello")
    # Aucun fichier ne doit etre cree
    assert not (tmp_path / "x.log").exists()
