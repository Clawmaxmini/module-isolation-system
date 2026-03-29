"""Service orchestration for MT5 account and order operations.

Single-user stable by default via `default` account slot, while shape supports
future multi-account expansion by passing `account_id`.
"""

from __future__ import annotations

from collections.abc import Callable

from adapters.base import MT5Adapter


class TradingService:
    def __init__(self, adapter_factory: Callable[[], MT5Adapter]):
        self._adapter_factory = adapter_factory
        self._adapters: dict[str, MT5Adapter] = {}

    def _adapter_for(self, account_id: str = "default") -> MT5Adapter:
        if account_id not in self._adapters:
            adapter = self._adapter_factory()
            adapter.connect()
            self._adapters[account_id] = adapter
        return self._adapters[account_id]

    def get_account(self, account_id: str = "default") -> dict:
        return self._adapter_for(account_id).get_account()

    def get_positions(self, account_id: str = "default") -> list[dict]:
        return self._adapter_for(account_id).get_positions()

    def place_order(
        self,
        symbol: str,
        volume: float,
        side: str,
        reason_payload: str,
        account_id: str = "default",
    ) -> dict:
        return self._adapter_for(account_id).send_market_order(
            symbol=symbol,
            volume=volume,
            side=side,
            reason_payload=reason_payload,
        )
