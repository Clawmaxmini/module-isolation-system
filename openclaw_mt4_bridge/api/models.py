"""Pydantic request/response models."""

from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    status: str
    service: str
    env: str


class OrderRequest(BaseModel):
    symbol: str = Field(..., min_length=3, max_length=10, examples=["EURUSD"])
    volume: float = Field(..., gt=0, examples=[0.1])
    side: str = Field(..., pattern="^(BUY|SELL)$", examples=["BUY"])
    reason_payload: str = Field(
        ...,
        min_length=10,
        max_length=1000,
        description="Required reason for trade placement (strategy signal context)",
    )
    account_id: str = Field(default="default", min_length=1, max_length=64)


class APIError(BaseModel):
    detail: str
