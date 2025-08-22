from __future__ import annotations

import sqlite3
from pathlib import Path

import pytest
from tools.backup_restore import backup, restore


def _prepare_sqlite_db(tmp_path: Path) -> str:
    db = tmp_path / "db.sqlite"
    dsn = f"sqlite:///{db}"
    with sqlite3.connect(db) as conn:
        conn.execute("CREATE TABLE t (id INTEGER PRIMARY KEY, name TEXT)")
        conn.execute("INSERT INTO t (name) VALUES ('alice'), ('bob')")
        conn.commit()
    return dsn


def test_backup_and_restore_sqlite_ok(tmp_path: Path) -> None:
    dsn = _prepare_sqlite_db(tmp_path)
    dump = tmp_path / "dump.sqlite"
    backup(dsn, dump)
    assert dump.exists() and dump.stat().st_size > 0
    dsn_target = f"sqlite:///{tmp_path/'db_restored.sqlite'}"
    restore(dsn_target, dump, overwrite=True)
    with sqlite3.connect(tmp_path / "db_restored.sqlite") as conn:
        rows = list(conn.execute("SELECT COUNT(*) FROM t"))
        assert rows[0][0] == 2


def test_restore_sqlite_invalid_dump_ko(tmp_path: Path) -> None:
    dsn = _prepare_sqlite_db(tmp_path)
    bad = tmp_path / "bad.dump"
    bad.write_text("NOT A SQLITE FILE", encoding="utf-8")
    with pytest.raises(Exception):
        restore(dsn, bad, overwrite=True)
