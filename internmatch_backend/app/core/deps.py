"""
app/core/deps.py
────────────────
FastAPI dependency-injection helpers.
"""

from typing import Annotated, Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError

from app.core.security import decode_token
from app.db.database import get_db, is_db_available
from motor.motor_asyncio import AsyncIOMotorDatabase

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")
oauth2_scheme_optional = OAuth2PasswordBearer(
    tokenUrl="/api/v1/auth/login", auto_error=False
)


async def get_db_or_503():
    """Returns the database handle or raises 503 if MongoDB is unavailable."""
    if not is_db_available():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database unavailable. Please check MongoDB connection.",
        )
    return await get_db()


async def get_current_user_id(
    token: Annotated[str, Depends(oauth2_scheme)],
) -> str:
    """
    Extracts and returns the user_id (subject) from a valid Bearer JWT.
    Raises HTTP 401 on any token problem.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = decode_token(token)
        user_id: str = payload.get("sub")
        if not user_id or payload.get("type") != "access":
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    return user_id


async def get_optional_current_user_id(
    token: Annotated[Optional[str], Depends(oauth2_scheme_optional)],
) -> Optional[str]:
    """
    Returns user_id from Bearer JWT when provided, otherwise None.
    Invalid tokens still raise 401 to avoid silently accepting bad auth state.
    """
    if not token:
        return None
    try:
        return await get_current_user_id(token)
    except HTTPException:
        # Public endpoints should continue without user context if token is stale.
        return None


# Convenience type alias
CurrentUserId = Annotated[str, Depends(get_current_user_id)]
OptionalCurrentUserId = Annotated[Optional[str], Depends(get_optional_current_user_id)]
DB = Annotated[AsyncIOMotorDatabase, Depends(get_db_or_503)]
