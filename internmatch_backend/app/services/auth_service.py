"""
app/services/auth_service.py
──────────────────────────────
Business logic for registration and login.
"""

from datetime import datetime, timezone

from fastapi import HTTPException, status
from motor.motor_asyncio import AsyncIOMotorDatabase

from app.core.security import hash_password, verify_password, create_access_token, create_refresh_token
from app.schemas.auth import RegisterRequest, LoginRequest, TokenResponse


async def register_user(db: AsyncIOMotorDatabase, payload: RegisterRequest) -> TokenResponse:
    existing = await db.users.find_one({"email": payload.email})
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email already exists.",
        )

    doc = {
        "name": payload.name,
        "email": payload.email,
        "password_hash": hash_password(payload.password),
        "skills": [],
        "cgpa": 7.0,
        "interests": [],
        "preferred_location": "",
        "preferred_type": "Any",
        "college": None,
        "graduation_year": None,
        "avatar_url": None,
        "resume_url": None,
        "created_at": datetime.now(timezone.utc),
    }
    result = await db.users.insert_one(doc)
    user_id = str(result.inserted_id)

    return TokenResponse(
        access_token=create_access_token(user_id),
        refresh_token=create_refresh_token(user_id),
        user_id=user_id,
        name=payload.name,
        email=payload.email,
    )


async def login_user(db: AsyncIOMotorDatabase, payload: LoginRequest) -> TokenResponse:
    user = await db.users.find_one({"email": payload.email})
    if not user or not verify_password(payload.password, user["password_hash"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
        )

    user_id = str(user["_id"])
    return TokenResponse(
        access_token=create_access_token(user_id),
        refresh_token=create_refresh_token(user_id),
        user_id=user_id,
        name=user["name"],
        email=user["email"],
    )
