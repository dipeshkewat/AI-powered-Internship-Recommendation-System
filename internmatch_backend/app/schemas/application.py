"""
app/schemas/application.py
───────────────────────────
Schemas for internship application tracking.
"""

from datetime import datetime
from typing import Optional
from pydantic import BaseModel


class ApplicationCreate(BaseModel):
    internship_id: str
    notes: Optional[str] = None


class ApplicationStatusUpdate(BaseModel):
    # 0=applied 1=inReview 2=shortlisted 3=rejected 4=offered
    status: int


class ApplicationNotesUpdate(BaseModel):
    notes: str


class ApplicationResponse(BaseModel):
    id: str
    internship_id: str
    internship_title: str
    company: str
    company_logo: str
    status: int
    applied_at: datetime
    updated_at: Optional[datetime] = None
    notes: Optional[str] = None


class ApplicationListResponse(BaseModel):
    applications: list[ApplicationResponse]
    total: int
