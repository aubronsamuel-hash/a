import os

import pytest
from fastapi.testclient import TestClient

from app.config import settings
from app.db import session_scope
from app.main import create_app
from app.repo_users import get_by_username

POSTGRES_DSN_ENV = "PG_TEST_DSN"

@pytest.mark.skipif(
    POSTGRES_DSN_ENV not in os.environ,
    reason="PG tests desactives (PG_TEST_DSN absent)",
)
def test_pg_create_user_and_duplicate_ok_ko(monkeypatch):
    dsn = os.environ[POSTGRES_DSN_ENV]
    monkeypatch.setenv("DB_DSN", dsn)
    settings.DB_DSN = dsn
    settings.ADMIN_AUTOSEED = True
    app = create_app()
    c = TestClient(app)
    assert c.get("/healthz").status_code == 200
    # create via repo layer (simule CLI)
    with session_scope() as db:
        from app.hash import hash_password
        from app.repo_users import create_user

        u = get_by_username(db, "ciuser")
        if not u:
            create_user(db, "ciuser", hash_password("pw"), role="user")
    # duplicate KO via repo (contrainte unique)
    with session_scope() as db:
        from app.hash import hash_password
        from app.repo_users import create_user

        with pytest.raises(Exception):  # noqa: B017
            create_user(db, "ciuser", hash_password("pw"), role="user")
