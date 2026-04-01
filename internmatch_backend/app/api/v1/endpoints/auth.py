"""
app/api/v1/endpoints/auth.py
─────────────────────────────
POST /auth/register
POST /auth/login
POST /auth/refresh
"""

from fastapi import APIRouter, Depends
from jose import JWTError

from app.core.deps import DB
from app.core.security import decode_token, create_access_token, create_refresh_token
from app.schemas.auth import RegisterRequest, LoginRequest, TokenResponse, RefreshRequest
from app.services import auth_service
from fastapi import HTTPException, status

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=TokenResponse, status_code=201)
async def register(payload: RegisterRequest, db: DB):
    """Create a new account and return tokens."""
    return await auth_service.register_user(db, payload)


@router.post("/login", response_model=TokenResponse)
async def login(payload: LoginRequest, db: DB):
    """Authenticate with email + password and return tokens."""
    return await auth_service.login_user(db, payload)


@router.post("/refresh", response_model=TokenResponse)
async def refresh(payload: RefreshRequest, db: DB):
    """Exchange a valid refresh token for a new access + refresh token pair."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid or expired refresh token.",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        data = decode_token(payload.refresh_token)
        if data.get("type") != "refresh":
            raise credentials_exception
        user_id: str = data.get("sub")
        if not user_id:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    # Verify user still exists
    from bson import ObjectId
    try:
        oid = ObjectId(user_id)
    except Exception:
        raise credentials_exception

    user = await db.users.find_one({"_id": oid})
    if not user:
        raise credentials_exception

    return TokenResponse(
        access_token=create_access_token(user_id),
        refresh_token=create_refresh_token(user_id),
        user_id=user_id,
        name=user["name"],
        email=user["email"],
    )
