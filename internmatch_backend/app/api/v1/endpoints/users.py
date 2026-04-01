"""
app/api/v1/endpoints/users.py
──────────────────────────────
GET  /users/{user_id}/profile
PUT  /users/{user_id}/profile
POST /users/{user_id}/bookmarks/{internship_id}
DEL  /users/{user_id}/bookmarks/{internship_id}
GET  /users/{user_id}/bookmarks
GET  /users/{user_id}/applications
"""

from fastapi import APIRouter

from app.core.deps import DB, CurrentUserId
from app.schemas.user import ProfileUpdate, ProfileResponse
from app.services import user_service, bookmark_service, application_service

router = APIRouter(prefix="/users", tags=["users"])


# ── Profile ───────────────────────────────────────────────────────────────────

@router.get("/{user_id}/profile", response_model=ProfileResponse)
async def get_profile(user_id: str, db: DB, _: CurrentUserId):
    return await user_service.get_profile(db, user_id)


@router.put("/{user_id}/profile", response_model=ProfileResponse)
async def update_profile(
    user_id: str,
    payload: ProfileUpdate,
    db: DB,
    current_user: CurrentUserId,
):
    return await user_service.update_profile(db, user_id, payload, current_user)


# ── Bookmarks ─────────────────────────────────────────────────────────────────

@router.post("/{user_id}/bookmarks/{internship_id}", status_code=201)
async def add_bookmark(
    user_id: str,
    internship_id: str,
    db: DB,
    current_user: CurrentUserId,
):
    return await bookmark_service.add_bookmark(db, user_id, internship_id, current_user)


@router.delete("/{user_id}/bookmarks/{internship_id}")
async def remove_bookmark(
    user_id: str,
    internship_id: str,
    db: DB,
    current_user: CurrentUserId,
):
    return await bookmark_service.remove_bookmark(db, user_id, internship_id, current_user)


@router.get("/{user_id}/bookmarks")
async def get_bookmarks(user_id: str, db: DB, current_user: CurrentUserId):
    return await bookmark_service.get_bookmarks(db, user_id, current_user)


# ── Applications ──────────────────────────────────────────────────────────────

@router.get("/{user_id}/applications")
async def list_applications(user_id: str, db: DB, current_user: CurrentUserId):
    return await application_service.list_applications(db, user_id, current_user)
