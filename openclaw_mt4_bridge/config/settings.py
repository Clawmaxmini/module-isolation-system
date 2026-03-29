"""Centralized application settings."""

from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = Field(default="OpenClaw-MT5-Bridge", alias="APP_NAME")
    app_env: str = Field(default="dev", alias="APP_ENV")
    app_host: str = Field(default="0.0.0.0", alias="APP_HOST")
    app_port: int = Field(default=8080, alias="APP_PORT")
    log_level: str = Field(default="INFO", alias="LOG_LEVEL")

    mt5_login: int = Field(alias="MT5_LOGIN")
    mt5_password: str = Field(alias="MT5_PASSWORD")
    mt5_server: str = Field(alias="MT5_SERVER")
    mt5_path: str | None = Field(default=None, alias="MT5_PATH")
    mt5_timeout_ms: int = Field(default=10000, alias="MT5_TIMEOUT_MS")
    mt5_deviation: int = Field(default=20, alias="MT5_DEVIATION")
    mt5_magic: int = Field(default=910001, alias="MT5_MAGIC")

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")


@lru_cache
def get_settings() -> Settings:
    return Settings()
