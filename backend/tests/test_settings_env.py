import importlib
import os
from pathlib import Path


def test_env_chain_loads_env_specific(monkeypatch, tmp_path):
    monkeypatch.delenv("APP_NAME", raising=False)
    # Cree .env et .env.staging avec valeurs differentes
    (tmp_path / ".env").write_text("APP_NAME=DevName\n", encoding="utf-8")
    (tmp_path / ".env.staging").write_text("APP_NAME=StagingName\n", encoding="utf-8")

    # Change cwd vers tmp et force ENV=staging
    monkeypatch.chdir(tmp_path)
    monkeypatch.setenv("ENV", "staging")

    # Import/Reload module config
    m = importlib.import_module("app.core.config")
    importlib.reload(m)
    m.reset_settings_cache()
    s = m.get_settings()
    assert s.ENV == "staging"
    assert s.APP_NAME == "StagingName"


def test_env_chain_defaults_when_no_files(monkeypatch, tmp_path):
    monkeypatch.chdir(tmp_path)
    # Pas de .env ni .env.dev
    monkeypatch.delenv("ENV", raising=False)
    monkeypatch.delenv("APP_NAME", raising=False)
    m = importlib.import_module("app.core.config")
    importlib.reload(m)
    m.reset_settings_cache()
    s = m.get_settings()
    assert s.ENV == "dev"
    assert s.APP_NAME == "CoulissesCrewAPI"
