"""Structured logging setup.

Logs are JSON formatted for easier forwarding to ELK, Splunk, Datadog, etc.
"""

import logging
import sys
from pathlib import Path

from pythonjsonlogger import jsonlogger


def setup_logging(log_level: str = "INFO") -> None:
    log_path = Path("logs")
    log_path.mkdir(parents=True, exist_ok=True)

    logger = logging.getLogger()
    logger.setLevel(log_level.upper())
    logger.handlers.clear()

    formatter = jsonlogger.JsonFormatter(
        "%(asctime)s %(levelname)s %(name)s %(message)s %(pathname)s %(lineno)d"
    )

    stream_handler = logging.StreamHandler(sys.stdout)
    stream_handler.setFormatter(formatter)

    file_handler = logging.FileHandler(log_path / "bridge.log")
    file_handler.setFormatter(formatter)

    logger.addHandler(stream_handler)
    logger.addHandler(file_handler)
