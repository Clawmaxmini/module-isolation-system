from fastapi.testclient import TestClient

from api.dependencies import get_trading_service
from main import app


class FakeTradingService:
    def get_account(self, account_id: str = "default"):
        return {"login": 1, "server": "demo", "balance": 1000}

    def get_positions(self, account_id: str = "default"):
        return []

    def place_order(self, **kwargs):
        return {"retcode": 10009, "comment": "done"}


app.dependency_overrides[get_trading_service] = lambda: FakeTradingService()
client = TestClient(app)


def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_order_requires_reason_payload():
    payload = {
        "symbol": "EURUSD",
        "volume": 0.1,
        "side": "BUY",
        "account_id": "default",
    }
    response = client.post("/order", json=payload)
    assert response.status_code == 422
