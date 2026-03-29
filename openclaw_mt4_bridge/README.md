# OpenClaw ↔ MT5 Bridge API (Windows VPS)

Production-style FastAPI starter to connect OpenClaw with a locally running MetaTrader 5 terminal using the official `MetaTrader5` Python package.

## Architecture goals

- Stable single-user operation first.
- Clean, isolated modules.
- Ready path for future multi-account support (`account_id` + adapter registry).
- Request/response structured logging for auditability.

## Folder structure

```text
openclaw_mt4_bridge/
├── api/
│   ├── dependencies.py
│   ├── models.py
│   └── routes.py
├── adapters/
│   ├── base.py
│   └── mt5_adapter.py
├── config/
│   ├── config.example.json
│   └── settings.py
├── logs/
├── services/
│   ├── logging_service.py
│   └── trading_service.py
├── tests/
│   ├── test_api_health.py
│   └── test_risk_rules.py
├── .env.example
├── main.py
└── requirements.txt
```

## API endpoints

- `GET /health`
- `GET /account?account_id=default`
- `GET /positions?account_id=default`
- `POST /order`

### `POST /order` body

```json
{
  "symbol": "EURUSD",
  "volume": 0.1,
  "side": "BUY",
  "reason_payload": "Signal from OpenClaw strategy alpha-v1",
  "account_id": "default"
}
```

> `reason_payload` is required.

## Windows VPS setup

### 1) Install prerequisites

- Python 3.11+
- MetaTrader 5 terminal installed and logged in once manually.

### 2) Configure project

```powershell
cd openclaw_mt4_bridge
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
```

Fill `.env` with your broker credentials:

- `MT5_LOGIN`
- `MT5_PASSWORD`
- `MT5_SERVER`
- `MT5_PATH` (optional but recommended)

### 3) Run API

```powershell
uvicorn main:app --host 0.0.0.0 --port 8080
```

Swagger: `http://localhost:8080/docs`

## Sample curl

```bash
curl http://127.0.0.1:8080/health

curl "http://127.0.0.1:8080/account?account_id=default"

curl "http://127.0.0.1:8080/positions?account_id=default"

curl -X POST http://127.0.0.1:8080/order \
  -H "Content-Type: application/json" \
  -d '{
    "symbol":"EURUSD",
    "volume":0.1,
    "side":"BUY",
    "reason_payload":"Signal from OpenClaw strategy alpha-v1",
    "account_id":"default"
  }'
```

## Notes for future multi-account support

- `TradingService` already routes by `account_id` and caches adapter instances.
- To scale to multiple real accounts:
  1. Use per-account encrypted credentials store.
  2. Build adapter factory by account config.
  3. Add auth + account mapping in API layer.
