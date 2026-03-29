"""OpenClaw ↔ MT5 HTTP bridge starter app."""

import logging
import time
import uuid

from fastapi import FastAPI, Request

from api.routes import router
from config.settings import get_settings
from services.logging_service import setup_logging

settings = get_settings()
setup_logging(settings.log_level)
logger = logging.getLogger("http")

app = FastAPI(title=settings.app_name, version="0.2.0")


@app.middleware("http")
async def request_response_logger(request: Request, call_next):
    request_id = str(uuid.uuid4())
    started = time.perf_counter()
    logger.info(
        "request_received",
        extra={
            "request_id": request_id,
            "method": request.method,
            "path": request.url.path,
            "query": str(request.url.query),
            "client": request.client.host if request.client else None,
        },
    )

    response = await call_next(request)

    elapsed_ms = round((time.perf_counter() - started) * 1000, 2)
    logger.info(
        "response_sent",
        extra={
            "request_id": request_id,
            "status_code": response.status_code,
            "elapsed_ms": elapsed_ms,
            "path": request.url.path,
        },
    )
    response.headers["X-Request-ID"] = request_id
    return response


app.include_router(router)
