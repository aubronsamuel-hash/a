import os
from functools import lru_cache
from typing import List

try:
    from dotenv import load_dotenv  # type: ignore
    load_dotenv()
except Exception:
    pass


def _split_csv(value: str) -> List[str]:
    return [x.strip() for x in value.split(",") if x.strip()]


class Settings:
    def __init__(self) -> None:
        self.APP_NAME: str = os.getenv("APP_NAME", "CoulissesCrewAPI")
        self.ENV: str = os.getenv("ENV", "dev")
        # CORS
        self.CORS_ORIGINS: List[str] = _split_csv(
            os.getenv("CORS_ORIGINS", "http://localhost,http://localhost:5173")
        )
        self.CORS_ALLOW_CREDENTIALS: bool = (
            os.getenv("CORS_ALLOW_CREDENTIALS", "true").lower() == "true"
        )
        self.CORS_ALLOW_METHODS: List[str] = _split_csv(
            os.getenv("CORS_ALLOW_METHODS", "GET,POST,PUT,PATCH,DELETE,OPTIONS")
        )
        self.CORS_ALLOW_HEADERS: List[str] = _split_csv(
            os.getenv("CORS_ALLOW_HEADERS", "Authorization,Content-Type")
        )
        # OAuth Google
        self.GOOGLE_CLIENT_ID: str = os.getenv("GOOGLE_CLIENT_ID", "")
        self.GOOGLE_CLIENT_SECRET: str = os.getenv("GOOGLE_CLIENT_SECRET", "")
        self.GOOGLE_REDIRECT_URI: str = os.getenv("GOOGLE_REDIRECT_URI", "")
        self.GOOGLE_SCOPES: List[str] = _split_csv(
            os.getenv("GOOGLE_SCOPES", "openid,email,profile")
        )
        self.OAUTH_GOOGLE_TEST_MODE: bool = os.getenv(
            "OAUTH_GOOGLE_TEST_MODE", "0"
        ).lower() in ("1", "true", "yes")
        self.STATE_SECRET: str = os.getenv(
            "STATE_SECRET", os.getenv("JWT_SECRET", "change_me")
        )
        # JWT app
        self.JWT_SECRET: str = os.getenv("JWT_SECRET", "change_me")
        self.JWT_ALGO: str = os.getenv("JWT_ALGO", "HS256")
        self.JWT_EXPIRE_MINUTES: int = int(os.getenv("JWT_EXPIRE_MINUTES", "60"))


@lru_cache
def get_settings() -> Settings:
    return Settings()
