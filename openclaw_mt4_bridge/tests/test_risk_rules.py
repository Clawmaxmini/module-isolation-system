from fastapi.testclient import TestClient

from api.dependencies import get_trading_service
from main import app


class FakeTradingService:
    def get_account(self, account_id: str = "default"):
        return {"login": 111, "balance": 9999.0, "server": "demo"}

    def get_positions(self, account_id: str = "default"):
        return [{"ticket": 1, "symbol": "EURUSD"}]

    def place_order(self, **kwargs):
        return {"retcode": 10009, "order": 12345, "deal": 99999}


app.dependency_overrides[get_trading_service] = lambda: FakeTradingService()
client = TestClient(app)


def test_get_account():
    response = client.get("/account")
    assert response.status_code == 200
    assert response.json()["login"] == 111


def test_get_positions():
    response = client.get("/positions")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_place_order_ok():
    response = client.post(
        "/order",
        json={
            "symbol": "EURUSD",
            "volume": 0.1,
            "side": "BUY",
            "reason_payload": "Signal from OpenClaw strategy alpha-v1",
            "account_id": "default",
        },
    )
    assert response.status_code == 200
    assert response.json()["retcode"] == 10009
