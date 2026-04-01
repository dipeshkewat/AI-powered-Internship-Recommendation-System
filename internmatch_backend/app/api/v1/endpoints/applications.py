"""
app/api/v1/endpoints/applications.py
──────────────────────────────────────
PATCH /applications/{id}/status  – update status (0-4)
PATCH /applications/{id}/notes   – update notes
DELETE /applications/{id}        – delete application
"""

from fastapi import APIRouter

from app.core.deps import DB, CurrentUserId
from app.schemas.application import (
    ApplicationResponse,
    ApplicationStatusUpdate,
    ApplicationNotesUpdate,
)
from app.services import application_service

router = APIRouter(prefix="/applications", tags=["applications"])


@router.patch("/{application_id}/status", response_model=ApplicationResponse)
async def update_status(
    application_id: str,
    payload: ApplicationStatusUpdate,
    db: DB,
    current_user: CurrentUserId,
):
    return await application_service.update_application_status(
        db, application_id, current_user, payload
    )


@router.patch("/{application_id}/notes", response_model=ApplicationResponse)
async def update_notes(
    application_id: str,
    payload: ApplicationNotesUpdate,
    db: DB,
    current_user: CurrentUserId,
):
    return await application_service.update_application_notes(
        db, application_id, current_user, payload
    )


@router.delete("/{application_id}")
async def delete_application(
    application_id: str,
    db: DB,
    current_user: CurrentUserId,
):
    return await application_service.delete_application(db, application_id, current_user)
