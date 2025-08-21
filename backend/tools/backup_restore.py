from __future__ import annotations

import os
import shutil
import sqlite3
import subprocess
from pathlib import Path
from typing import Optional


def _resolve_dsn(dsn: Optional[str]) -> str:
    return dsn if dsn is not None else os.getenv("DB_DSN", "sqlite:///./cc.db")


def _is_sqlite(dsn: str) -> bool:
    return dsn.startswith("sqlite:///")


def _sqlite_path(dsn: str) -> Path:
    p = dsn.removeprefix("sqlite:///")
    return Path(p).resolve()


def backup(dsn: Optional[str], out_file: Path) -> None:
    """
    Sauvegarde la base au chemin out_file.
    - SQLite: utilise backup API atomique.
    - Postgres: utilise pg_dump si dispo.
    """
    dsnv = _resolve_dsn(dsn)
    out_file = out_file.resolve()
    out_file.parent.mkdir(parents=True, exist_ok=True)

    if _is_sqlite(dsnv):
        db_path = _sqlite_path(dsnv)
        if not db_path.exists():
            raise FileNotFoundError(f"Base SQLite introuvable: {db_path}")
        with sqlite3.connect(db_path) as src, sqlite3.connect(str(out_file)) as dst:
            src.backup(dst)
        return

    if dsnv.startswith("postgresql"):
        if shutil.which("pg_dump") is None:
            raise RuntimeError(
                "pg_dump non trouve dans le PATH. Installez les outils Postgres pour utiliser le backup Postgres."
            )
        dsn_pg = dsnv.replace("+psycopg", "")
        cmd = ["pg_dump", dsn_pg, "-Fc", "-f", str(out_file)]
        subprocess.run(cmd, check=True)
        return

    raise ValueError(f"DSN non supporte: {dsnv}")


def restore(dsn: Optional[str], dump_file: Path, overwrite: bool = False) -> None:
    """
    Restore la base depuis dump_file.
    - SQLite: ecrase le fichier cible (avec option overwrite).
    - Postgres: via psql/pg_restore si dispo.
    """
    dsnv = _resolve_dsn(dsn)
    dump_file = dump_file.resolve()
    if not dump_file.exists():
        raise FileNotFoundError(f"Dump introuvable: {dump_file}")

    if _is_sqlite(dsnv):
        db_path = _sqlite_path(dsnv)
        if db_path.exists() and not overwrite:
            raise FileExistsError(
                f"Base cible existe deja: {db_path}. Utilisez overwrite=True pour ecraser."
            )
        with open(dump_file, "rb") as fh:
            header = fh.read(16)
        if header != b"SQLite format 3\x00":
            raise ValueError(f"Dump SQLite invalide: {dump_file}")
        shutil.copy2(dump_file, db_path)
        return

    if dsnv.startswith("postgresql"):
        if shutil.which("pg_restore") is None or shutil.which("psql") is None:
            raise RuntimeError(
                "pg_restore/psql non trouves dans le PATH. Installez les outils Postgres pour utiliser le restore Postgres."
            )
        dsn_pg = dsnv.replace("+psycopg", "")
        subprocess.run(
            [
                "psql",
                dsn_pg,
                "-c",
                "DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;",
            ],
            check=True,
        )
        subprocess.run(["pg_restore", "-d", dsn_pg, str(dump_file)], check=True)
        return

    raise ValueError(f"DSN non supporte: {dsnv}")


def main(argv: list[str] | None = None) -> int:
    import argparse

    p = argparse.ArgumentParser(
        prog="ccdb", description="Sauvegarde/Restore DB (SQLite natif; Postgres optionnel)"
    )
    sub = p.add_subparsers(dest="cmd", required=True)

    b = sub.add_parser("backup", help="Creer un dump")
    b.add_argument("--dsn", default=None, help="DB_DSN; par defaut $DB_DSN ou sqlite:///./cc.db")
    b.add_argument("--out", required=True, help="Chemin du fichier dump (sera cree)")

    r = sub.add_parser("restore", help="Restaurer depuis un dump")
    r.add_argument("--dsn", default=None)
    r.add_argument("--in", dest="in_file", required=True, help="Chemin du dump a restaurer")
    r.add_argument("--overwrite", action="store_true", help="Ecraser la base cible si elle existe (SQLite)")

    args = p.parse_args(argv)
    try:
        if args.cmd == "backup":
            backup(args.dsn, Path(args.out))
        elif args.cmd == "restore":
            restore(args.dsn, Path(args.in_file), overwrite=args.overwrite)
        print("OK")
        return 0
    except Exception as e:
        print(f"ERREUR: {e}")
        return 1


if __name__ == "__main__":
    import sys

    raise SystemExit(main(sys.argv[1:]))
