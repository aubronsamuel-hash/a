from __future__ import annotations

import pathlib

import pytest
from alembic import command
from alembic.config import Config

ALEMBIC_INI = str(pathlib.Path("alembic.ini"))


def _cfg(db_url: str) -> Config:
    cfg = Config(ALEMBIC_INI)
    # Forcer le DSN pour ce test
    cfg.set_main_option("sqlalchemy.url", db_url)
    return cfg


def test_alembic_upgrade_head_sqlite_ok(tmp_path):
    db = tmp_path / "test.db"
    cfg = _cfg(f"sqlite:///{db}")
    command.upgrade(cfg, "head")
    # Si on arrive ici sans exception, c est OK
    assert db.exists()


def test_alembic_upgrade_invalid_dsn_ko(monkeypatch):
    cfg = _cfg("invalid:///nowhere")
    with pytest.raises(Exception):  # noqa: B017
        command.upgrade(cfg, "head")
