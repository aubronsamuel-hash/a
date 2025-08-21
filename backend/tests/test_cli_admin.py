from __future__ import annotations

from app.cli import main as cli_main
from app.config import settings
from app.db import session_scope
from app.main import create_app
from app.repo_users import get_by_username


def _run(args: list[str]) -> tuple[int, dict]:
    code = cli_main(args)
    return code, {}


def test_cli_create_and_promote_and_list(tmp_path):
    settings.ADMIN_AUTOSEED = True
    create_app()

    # create OK
    code, _ = _run(["create", "--username", "alice", "--password", "pw"])
    assert code == 0
    with session_scope() as db:
        u = get_by_username(db, "alice")
        assert u is not None and getattr(u, "role", "user") == "user"

    # promote OK
    code, _ = _run(["promote", "--username", "alice"])
    assert code == 0
    with session_scope() as db:
        u = get_by_username(db, "alice")
        assert u is not None and getattr(u, "role", "user") == "admin"

    # list OK
    code, _ = _run(["list"])
    assert code == 0


def test_cli_create_duplicate_ko(tmp_path):
    settings.ADMIN_AUTOSEED = True
    create_app()
    assert _run(["create", "--username", "bob", "--password", "pw"])[0] == 0
    assert _run(["create", "--username", "bob", "--password", "pw"])[0] == 1
