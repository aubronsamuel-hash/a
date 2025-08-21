import os
from functools import lru_cache
from typing import List

try:
    from dotenv import load_dotenv, dotenv_values
except Exception:  # pragma: no cover
    load_dotenv = None  # type: ignore[assignment]
    dotenv_values = None  # type: ignore[assignment]


def _split_csv(value: str) -> List[str]:
    return [x.strip() for x in (value or "").split(",") if x.strip()]


def _load_env_chain() -> None:
    """
    Charge .env (si present), puis .env.{ENV} (si present) sans ecraser des valeurs deja definies dans l environnement.
    Precedence: variables d environnement > .env.{ENV} > .env > valeurs par defaut en code.
    """
    if dotenv_values is None:
        return
    loaded_keys: set[str] = set()
    if os.path.exists(".env"):
        for k, v in dotenv_values(".env").items():
            if k not in os.environ:
                os.environ[k] = v or ""
                loaded_keys.add(k)
    env = os.getenv("ENV", "dev").lower()
    env_file = f".env.{env}"
    if os.path.exists(env_file):
        for k, v in dotenv_values(env_file).items():
            if k not in os.environ or k in loaded_keys:
                os.environ[k] = v or ""


class Settings:
    # App
    APP_NAME: str
    ENV: str
    # CORS
    CORS_ORIGINS: List[str]
    CORS_ALLOW_CREDENTIALS: bool
    CORS_ALLOW_METHODS: List[str]
    CORS_ALLOW_HEADERS: List[str]
    # OAuth Google (optionnel)
    GOOGLE_CLIENT_ID: str
    GOOGLE_CLIENT_SECRET: str
    GOOGLE_REDIRECT_URI: str
    GOOGLE_SCOPES: List[str]
    OAUTH_GOOGLE_TEST_MODE: bool
    STATE_SECRET: str
    # JWT
    JWT_SECRET: str
    JWT_ALGO: str
    JWT_EXPIRE_MINUTES: int
    # Metrics
    METRICS_ENABLED: bool
    METRICS_PATH: str

    def __init__(self) -> None:
        _load_env_chain()
        # App
        self.APP_NAME = os.getenv("APP_NAME", "CoulissesCrewAPI")
        self.ENV = os.getenv("ENV", "dev").lower()
        # CORS
        self.CORS_ORIGINS = _split_csv(os.getenv("CORS_ORIGINS", "http://localhost,http://localhost:5173"))
        self.CORS_ALLOW_CREDENTIALS = os.getenv("CORS_ALLOW_CREDENTIALS", "true").lower() == "true"
        self.CORS_ALLOW_METHODS = _split_csv(os.getenv("CORS_ALLOW_METHODS", "GET,POST,PUT,PATCH,DELETE,OPTIONS"))
        self.CORS_ALLOW_HEADERS = _split_csv(os.getenv("CORS_ALLOW_HEADERS", "Authorization,Content-Type"))
        # OAuth Google
        self.GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID", "")
        self.GOOGLE_CLIENT_SECRET = os.getenv("GOOGLE_CLIENT_SECRET", "")
        self.GOOGLE_REDIRECT_URI = os.getenv("GOOGLE_REDIRECT_URI", "")
        self.GOOGLE_SCOPES = _split_csv(os.getenv("GOOGLE_SCOPES", "openid,email,profile"))
        self.OAUTH_GOOGLE_TEST_MODE = os.getenv("OAUTH_GOOGLE_TEST_MODE", "0").lower() in ("1", "true", "yes")
        self.STATE_SECRET = os.getenv("STATE_SECRET", os.getenv("JWT_SECRET", "change_me"))
        # JWT
        self.JWT_SECRET = os.getenv("JWT_SECRET", "change_me")
        self.JWT_ALGO = os.getenv("JWT_ALGO", "HS256")
        self.JWT_EXPIRE_MINUTES = int(os.getenv("JWT_EXPIRE_MINUTES", "60"))
        # Metrics
        self.METRICS_ENABLED = os.getenv("METRICS_ENABLED", "1").lower() in ("1", "true", "yes")
        self.METRICS_PATH = os.getenv("METRICS_PATH", "/metrics")


@lru_cache
def get_settings() -> 'Settings':
    return Settings()


def reset_settings_cache() -> None:
    try:
        get_settings.cache_clear()
    except Exception:
        pass
