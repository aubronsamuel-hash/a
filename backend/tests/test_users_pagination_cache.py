from __future__ import annotations

from fastapi.testclient import TestClient

from app.config import settings
from app.main import app

client = TestClient(app)


def _login(u: str, p: str):
    return client.post("/auth/token", json={"username": u, "password": p})


def _adm_token():
    pwd = settings.ADMIN_PASSWORD if settings.ADMIN_PASSWORD else "admin123"
    r = _login(settings.ADMIN_USERNAME, pwd)
    if r.status_code != 200:
        # Possiblement l admin a change son mot de passe a l ETAPE 6 tests -> tenter secretXYZ
        r = _login(settings.ADMIN_USERNAME, "secretXYZ")
    assert r.status_code == 200
    return r.json()["access_token"]


def test_users_pagination_and_meta_and_etag_304():
    t = _adm_token()
    # 1er appel -> 200 + ETag
    r1 = client.get("/users?order=username_asc", headers={"Authorization": f"Bearer {t}"})
    assert r1.status_code == 200
    assert "ETag" in r1.headers
    etag = r1.headers["ETag"]
    j = r1.json()
    assert "meta" in j and "data" in j
    assert j["meta"]["page"] >= 1
    assert j["meta"]["page_size"] >= 1
    assert j["meta"]["etag"] == etag
    # 2nd appel avec If-None-Match -> 304
    r2 = client.get(
        "/users?order=username_asc",
        headers={"Authorization": f"Bearer {t}", "If-None-Match": etag},
    )
    assert r2.status_code == 304


def test_users_sorting_orders():
    t = _adm_token()
    # creer deux utilisateurs pour tester tri
    client.post(
        "/users",
        headers={"Authorization": f"Bearer {t}"},
        json={"username": "aaatest", "password": "x123456"},
    )
    client.post(
        "/users",
        headers={"Authorization": f"Bearer {t}"},
        json={"username": "zzzztest", "password": "x123456"},
    )
    r_asc = client.get(
        "/users?order=username_asc&page_size=1",
        headers={"Authorization": f"Bearer {t}"},
    )
    assert r_asc.status_code == 200
    first_asc = r_asc.json()["data"][0]["username"]
    r_desc = client.get(
        "/users?order=username_desc&page_size=1",
        headers={"Authorization": f"Bearer {t}"},
    )
    assert r_desc.status_code == 200
    first_desc = r_desc.json()["data"][0]["username"]
    assert first_asc <= first_desc
