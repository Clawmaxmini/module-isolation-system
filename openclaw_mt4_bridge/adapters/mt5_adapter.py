"""Real MT5 adapter using official MetaTrader5 Python package.

This adapter is for a locally running MT5 terminal on Windows VPS.
"""

from __future__ import annotations

from typing import Any

from adapters.base import MT5Adapter


class MT5BridgeError(RuntimeError):
    """Raised for MT5 initialization/execution errors."""


class MetaTrader5Adapter(MT5Adapter):
    def __init__(
        self,
        login: int,
        password: str,
        server: str,
        path: str | None,
        timeout_ms: int,
        deviation: int,
        magic: int,
    ):
        self.login = login
        self.password = password
        self.server = server
        self.path = path
        self.timeout_ms = timeout_ms
        self.deviation = deviation
        self.magic = magic
        self._mt5: Any | None = None

    def _require_mt5(self):
        if self._mt5 is None:
            try:
                import MetaTrader5 as mt5  # type: ignore
            except ModuleNotFoundError as exc:
                raise MT5BridgeError(
                    "MetaTrader5 package is not installed. Install requirements and run on Windows with MT5 terminal."
                ) from exc
            self._mt5 = mt5
        return self._mt5

    def connect(self) -> None:
        mt5 = self._require_mt5()
        kwargs = {
            "login": self.login,
            "password": self.password,
            "server": self.server,
            "timeout": self.timeout_ms,
        }
        if self.path:
            ok = mt5.initialize(self.path, **kwargs)
        else:
            ok = mt5.initialize(**kwargs)

        if not ok:
            code, message = mt5.last_error()
            raise MT5BridgeError(f"MT5 initialize failed: code={code} message={message}")

    def shutdown(self) -> None:
        mt5 = self._require_mt5()
        mt5.shutdown()

    def get_account(self) -> dict[str, Any]:
        mt5 = self._require_mt5()
        info = mt5.account_info()
        if info is None:
            code, message = mt5.last_error()
            raise MT5BridgeError(f"account_info failed: code={code} message={message}")
        payload = info._asdict()
        return {
            "login": payload.get("login"),
            "name": payload.get("name"),
            "server": payload.get("server"),
            "balance": payload.get("balance"),
            "equity": payload.get("equity"),
            "margin": payload.get("margin"),
            "margin_free": payload.get("margin_free"),
            "currency": payload.get("currency"),
        }

    def get_positions(self) -> list[dict[str, Any]]:
        mt5 = self._require_mt5()
        positions = mt5.positions_get() or []
        return [pos._asdict() for pos in positions]

    def send_market_order(
        self,
        symbol: str,
        volume: float,
        side: str,
        reason_payload: str,
    ) -> dict[str, Any]:
        mt5 = self._require_mt5()

        symbol = symbol.upper()
        if not mt5.symbol_select(symbol, True):
            code, message = mt5.last_error()
            raise MT5BridgeError(f"symbol_select failed for {symbol}: code={code} message={message}")

        tick = mt5.symbol_info_tick(symbol)
        if tick is None:
            code, message = mt5.last_error()
            raise MT5BridgeError(f"symbol_info_tick failed for {symbol}: code={code} message={message}")

        if side == "BUY":
            order_type = mt5.ORDER_TYPE_BUY
            price = tick.ask
        else:
            order_type = mt5.ORDER_TYPE_SELL
            price = tick.bid

        request = {
            "action": mt5.TRADE_ACTION_DEAL,
            "symbol": symbol,
            "volume": float(volume),
            "type": order_type,
            "price": price,
            "deviation": self.deviation,
            "magic": self.magic,
            "comment": f"OpenClaw: {reason_payload[:24]}",
            "type_time": mt5.ORDER_TIME_GTC,
            "type_filling": mt5.ORDER_FILLING_IOC,
        }

        result = mt5.order_send(request)
        if result is None:
            code, message = mt5.last_error()
            raise MT5BridgeError(f"order_send failed: code={code} message={message}")

        result_dict = result._asdict()
        return {
            "request": request,
            "result": result_dict,
            "retcode": result_dict.get("retcode"),
            "order": result_dict.get("order"),
            "deal": result_dict.get("deal"),
            "comment": result_dict.get("comment"),
        }
