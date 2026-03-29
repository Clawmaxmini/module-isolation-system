"""Dependency wiring for FastAPI routes."""

from adapters.mt5_adapter import MetaTrader5Adapter
from config.settings import get_settings
from services.trading_service import TradingService

settings = get_settings()


def _adapter_factory() -> MetaTrader5Adapter:
    return MetaTrader5Adapter(
        login=settings.mt5_login,
        password=settings.mt5_password,
        server=settings.mt5_server,
        path=settings.mt5_path,
        timeout_ms=settings.mt5_timeout_ms,
        deviation=settings.mt5_deviation,
        magic=settings.mt5_magic,
    )


trading_service = TradingService(adapter_factory=_adapter_factory)


def get_trading_service() -> TradingService:
    return trading_service
