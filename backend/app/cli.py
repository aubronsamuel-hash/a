from __future__ import annotations

import argparse
import json
import sys
from typing import Any

from .config import settings  # noqa: F401 - ensure settings are loaded
from .db import session_scope
from .hash import hash_password
from .repo_users import create_user as repo_create_user
from .repo_users import get_by_username
from .repo_users import list_users as repo_list_users

OK = 0
ERR = 1

def _json_out(payload: dict[str, Any]) -> None:
    print(json.dumps(payload, ensure_ascii=True))

def cmd_list(args: argparse.Namespace) -> int:
    with session_scope() as db:
        users = repo_list_users(db, offset=0, limit=10_000)
        items: list[dict[str, Any]] = [
            {"username": u.username, "role": getattr(u, "role", "user")} for u in users
        ]
        _json_out({"items": items})
    return OK

def cmd_create(args: argparse.Namespace) -> int:
    username = args.username
    password = args.password
    role = args.role or "user"
    if not username or not password:
        _json_out({"error": "username/password requis"})
        return ERR
    with session_scope() as db:
        if get_by_username(db, username):
            _json_out({"error": "Utilisateur existe deja", "code": "conflict"})
            return ERR
        u = repo_create_user(db, username, hash_password(password), role=role)
        _json_out({"created": {"username": u.username, "role": u.role}})
    return OK

def cmd_promote(args: argparse.Namespace) -> int:
    username = args.username
    with session_scope() as db:
        u = get_by_username(db, username)
        if not u:
            _json_out({"error": "Utilisateur introuvable"})
            return ERR
        u.role = "admin"  # type: ignore[attr-defined]
        db.add(u)
        _json_out({"promoted": {"username": u.username, "role": "admin"}})
    return OK

def cmd_reset_password(args: argparse.Namespace) -> int:
    username = args.username
    new_pw = args.new_password
    if not new_pw:
        _json_out({"error": "new-password requis"})
        return ERR
    with session_scope() as db:
        u = get_by_username(db, username)
        if not u:
            _json_out({"error": "Utilisateur introuvable"})
            return ERR
        from .hash import hash_password as _hp

        u.password_hash = _hp(new_pw)
        db.add(u)
        _json_out({"password_reset": {"username": u.username}})
    return OK

def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="ccadmin", description="CLI admin utilisateurs")
    sub = p.add_subparsers(dest="cmd", required=True)

    sp_list = sub.add_parser("list", help="Lister les utilisateurs")
    sp_list.set_defaults(func=cmd_list)

    sp_create = sub.add_parser("create", help="Creer un utilisateur")
    sp_create.add_argument("--username", required=True)
    sp_create.add_argument("--password", required=True)
    sp_create.add_argument("--role", choices=["user", "admin"])
    sp_create.set_defaults(func=cmd_create)

    sp_prom = sub.add_parser("promote", help="Promouvoir un utilisateur en admin")
    sp_prom.add_argument("--username", required=True)
    sp_prom.set_defaults(func=cmd_promote)

    sp_reset = sub.add_parser("reset-password", help="Reinitialiser le mot de passe")
    sp_reset.add_argument("--username", required=True)
    sp_reset.add_argument("--new-password", required=True)
    sp_reset.set_defaults(func=cmd_reset_password)

    return p

def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)

if __name__ == "__main__":
    sys.exit(main())
