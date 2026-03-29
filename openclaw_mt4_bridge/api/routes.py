"""HTTP routes exposed to OpenClaw and other clients."""

from fastapi import APIRouter, Depends, HTTPException, Query

from adapters.mt5_adapter import MT5BridgeError
from api.dependencies import get_trading_service
from api.models import HealthResponse, OrderRequest
from config.settings import get_settings
from services.trading_service import TradingService

router = APIRouter()
settings = get_settings()


@router.get("/health", response_model=HealthResponse)
def health() -> HealthResponse:
    return HealthResponse(status="ok", service=settings.app_name, env=settings.app_env)


@router.get("/account")
def get_account(
    account_id: str = Query(default="default"),
    service: TradingService = Depends(get_trading_service),
):
    try:
        return service.get_account(account_id=account_id)
    except MT5BridgeError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/positions")
def get_positions(
    account_id: str = Query(default="default"),
    service: TradingService = Depends(get_trading_service),
):
    try:
        return service.get_positions(account_id=account_id)
    except MT5BridgeError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.post("/order")
def place_order(order: OrderRequest, service: TradingService = Depends(get_trading_service)):
    try:
        return service.place_order(
            symbol=order.symbol,
            volume=order.volume,
            side=order.side,
            reason_payload=order.reason_payload,
            account_id=order.account_id,
        )
    except MT5BridgeError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
