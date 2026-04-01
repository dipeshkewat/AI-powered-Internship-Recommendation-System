"""
app/core/deps.py
────────────────
FastAPI dependency-injection helpers.
"""

from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError

from app.core.security import decode_token
from app.db.database import get_db
from motor.motor_asyncio import AsyncIOMotorDatabase

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


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


# Convenience type alias
CurrentUserId = Annotated[str, Depends(get_current_user_id)]
DB = Annotated[AsyncIOMotorDatabase, Depends(get_db)]
