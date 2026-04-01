"""
app/db/database.py
──────────────────
Async MongoDB connection using Motor.
A single client is created at startup and reused across all requests.
"""

from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase

from app.core.config import settings

_client: AsyncIOMotorClient | None = None


async def connect_db() -> None:
    global _client
    _client = AsyncIOMotorClient(settings.MONGODB_URL)
    # Ping to verify connection on startup
    await _client.admin.command("ping")


async def close_db() -> None:
    global _client
    if _client:
        _client.close()
        _client = None


def get_client() -> AsyncIOMotorClient:
    if _client is None:
        raise RuntimeError("Database not connected. Call connect_db() first.")
    return _client


async def get_db() -> AsyncIOMotorDatabase:
    """FastAPI dependency that yields the database handle."""
    return get_client()[settings.MONGODB_DB_NAME]
