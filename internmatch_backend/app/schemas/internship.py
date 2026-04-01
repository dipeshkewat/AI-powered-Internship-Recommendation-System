"""
app/schemas/internship.py
──────────────────────────
Pydantic schemas for internship CRUD and listing.
Mirrors the Flutter Internship model.
"""

from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field, HttpUrl


class InternshipBase(BaseModel):
    title: str
    company: str
    company_logo: str = ""
    location: str
    type: str  # Remote / Hybrid / On-site
    skills: List[str] = []
    duration: str
    stipend: str
    domain: str
    description: Optional[str] = None
    apply_url: Optional[str] = None
    deadline: Optional[datetime] = None
    posted_at: Optional[datetime] = None


class InternshipCreate(InternshipBase):
    pass


class InternshipResponse(InternshipBase):
    id: str
    match_score: int = 0          # filled by ML engine for recommendations
    is_bookmarked: bool = False
    has_applied: bool = False


class InternshipListResponse(BaseModel):
    results: List[InternshipResponse]
    total: int
    page: int
    limit: int
    pages: int


class RecommendationRequest(BaseModel):
    skills: List[str] = Field(..., min_length=1)
    cgpa: float = Field(..., ge=0.0, le=10.0)
    interests: List[str] = []
    preferred_location: str = ""
    preferred_type: str = "Any"
    top_n: int = Field(default=10, ge=1, le=30)


class RecommendationResponse(BaseModel):
    recommendations: List[InternshipResponse]
