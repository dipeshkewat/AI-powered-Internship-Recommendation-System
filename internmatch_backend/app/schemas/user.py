"""
app/schemas/user.py
────────────────────
Pydantic schemas for user profile operations.
Mirrors the Flutter UserProfile model exactly.
"""

from typing import List, Optional
from pydantic import BaseModel, Field


class ProfileUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=100)
    skills: Optional[List[str]] = Field(None, max_length=20)
    cgpa: Optional[float] = Field(None, ge=0.0, le=10.0)
    interests: Optional[List[str]] = None
    preferred_location: Optional[str] = None
    preferred_type: Optional[str] = None  # Remote / Hybrid / On-site / Any
    college: Optional[str] = None
    graduation_year: Optional[int] = Field(None, ge=2000, le=2035)
    avatar_url: Optional[str] = None
    resume_url: Optional[str] = None


class ProfileResponse(BaseModel):
    id: str
    name: str
    email: str
    skills: List[str] = []
    cgpa: float = 7.0
    interests: List[str] = []
    preferred_location: str = ""
    preferred_type: str = "Any"
    avatar_url: Optional[str] = None
    college: Optional[str] = None
    graduation_year: Optional[int] = None
    resume_url: Optional[str] = None
