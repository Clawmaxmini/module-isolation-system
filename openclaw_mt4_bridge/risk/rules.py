"""Risk rules and validations used before order execution."""

from dataclasses import dataclass


@dataclass
class RiskConfig:
    max_lot_size: float
    max_daily_loss: float
    allowed_symbols: list[str]


class RiskViolationError(ValueError):
    """Raised when an order violates risk constraints."""


class RiskEngine:
    def __init__(self, config: RiskConfig):
        self.config = config

    def validate_symbol(self, symbol: str) -> None:
        if symbol.upper() not in self.config.allowed_symbols:
            raise RiskViolationError(f"Symbol '{symbol}' is not allowed")

    def validate_lot_size(self, lot_size: float) -> None:
        if lot_size <= 0:
            raise RiskViolationError("Lot size must be greater than 0")
        if lot_size > self.config.max_lot_size:
            raise RiskViolationError(
                f"Lot size {lot_size} exceeds max allowed {self.config.max_lot_size}"
            )

    def validate_daily_loss(self, daily_pnl: float) -> None:
        """daily_pnl is negative when losing money.

        If daily_pnl <= -max_daily_loss, new positions are blocked.
        """
        if daily_pnl <= -abs(self.config.max_daily_loss):
            raise RiskViolationError(
                f"Daily loss limit breached: pnl={daily_pnl}, limit={-abs(self.config.max_daily_loss)}"
            )

    def validate_order(self, symbol: str, lot_size: float, daily_pnl: float) -> None:
        self.validate_symbol(symbol)
        self.validate_lot_size(lot_size)
        self.validate_daily_loss(daily_pnl)
