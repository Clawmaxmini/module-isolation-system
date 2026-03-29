"""Abstract adapter interface for MT5 account operations."""

from abc import ABC, abstractmethod
from typing import Any


class MT5Adapter(ABC):
    @abstractmethod
    def connect(self) -> None:
        ...

    @abstractmethod
    def shutdown(self) -> None:
        ...

    @abstractmethod
    def get_account(self) -> dict[str, Any]:
        ...

    @abstractmethod
    def get_positions(self) -> list[dict[str, Any]]:
        ...

    @abstractmethod
    def send_market_order(
        self,
        symbol: str,
        volume: float,
        side: str,
        reason_payload: str,
    ) -> dict[str, Any]:
        ...
