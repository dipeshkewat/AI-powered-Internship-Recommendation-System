"""
app/db/database.py
──────────────────
Async MongoDB connection using Motor.
A single client is created at startup and reused across all requests.
The connection is attempted with retries; a failed connection logs an
error but does NOT crash the server — APIs will return 503 gracefully.
"""

import logging

from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase

from app.core.config import settings

logger = logging.getLogger(__name__)

_client: AsyncIOMotorClient | None = None
_db_available: bool = False


async def connect_db() -> None:
    global _client, _db_available
    try:
        # tlsAllowInvalidCertificates helps with Python 3.14 SSL issues
        _client = AsyncIOMotorClient(
            settings.MONGODB_URL,
            serverSelectionTimeoutMS=5000,
            connectTimeoutMS=5000,
            socketTimeoutMS=10000,
            tlsAllowInvalidCertificates=False,
        )
        # Ping to verify connection on startup
        await _client.admin.command("ping")
        _db_available = True
        logger.info("MongoDB connected successfully.")
    except Exception as e:
        _db_available = False
        logger.error(
            "MongoDB connection failed: %s\n"
            "The server will start without DB. Auth/data endpoints will return 503.",
            str(e),
        )


async def close_db() -> None:
    global _client, _db_available
    if _client:
        _client.close()
        _client = None
    _db_available = False


def get_client() -> AsyncIOMotorClient:
    if _client is None:
        raise RuntimeError("Database not connected.")
    return _client


def is_db_available() -> bool:
    return _db_available


async def get_db() -> AsyncIOMotorDatabase:
    """FastAPI dependency that yields the database handle."""
    return get_client()[settings.MONGODB_DB_NAME]
