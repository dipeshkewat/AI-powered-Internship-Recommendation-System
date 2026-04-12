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
    import asyncio
    
    mongo_url = settings.MONGODB_URL
    if "mongodb+srv" in mongo_url and "tlsInsecure" not in mongo_url:
        separator = "&" if "?" in mongo_url else "?"
        mongo_url = mongo_url + separator + "tlsInsecure=true"

    max_retries = 3
    for attempt in range(1, max_retries + 1):
        try:
            _client = AsyncIOMotorClient(
                mongo_url,
                serverSelectionTimeoutMS=8000,
                connectTimeoutMS=8000,
                socketTimeoutMS=15000,
            )
            # Ping to verify connection on startup
            await _client.admin.command("ping")
            _db_available = True
            logger.info(f"MongoDB connected successfully on attempt {attempt}.")
            return
        except Exception as e:
            logger.warning(f"MongoDB connection attempt {attempt} failed: {e}")
            if attempt < max_retries:
                await asyncio.sleep(2)
            else:
                _db_available = False
                logger.error(
                    "MongoDB connection failed after retries.\n"
                    "The server will start without DB. Auth/data endpoints will return 503."
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
