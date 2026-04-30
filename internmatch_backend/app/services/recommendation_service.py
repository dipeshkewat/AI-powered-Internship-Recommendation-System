"""
app/services/recommendation_service.py
────────────────────────────────────────
Orchestrates the ML engine + DB lookup to produce ranked recommendations.

Flow:
  1. Ask Recommender for domain → probability map.
  2. Fetch all internships from MongoDB.
  3. Score each internship by its domain probability.
  4. Apply location / type preference boost.
  5. Sort descending, return top_n as InternshipResponse list.
  6. If profile is empty (no skills/interests), return random top N with 60-80% match score.
"""

import math
import random
from typing import List, Optional

from motor.motor_asyncio import AsyncIOMotorDatabase

from app.ml.recommender import recommender
from app.schemas.internship import InternshipResponse, RecommendationRequest
from app.services.internship_service import _doc_to_response, _user_meta


def _compute_score(
    domain_probs: dict,
    internship_domain: str,
    internship_location: str,
    internship_type: str,
    preferred_location: str,
    preferred_type: str,
) -> int:
    """
    Convert a raw domain probability (0–1) into a 0–100 match score,
    with small bonuses for location / type alignment.
    """
    base = domain_probs.get(internship_domain, 0.0) * 100

    # Location boost (+5)
    if preferred_location and preferred_location.lower() in internship_location.lower():
        base += 5
    elif preferred_location == "Remote" and internship_type == "Remote":
        base += 5

    # Type boost (+5)
    if preferred_type != "Any" and preferred_type == internship_type:
        base += 5

    return min(100, math.floor(base))


def _is_empty_profile(skills: List[str], interests: List[str]) -> bool:
    """Check if user profile is empty (no skills or interests provided)."""
    return (not skills or len(skills) == 0) and (not interests or len(interests) == 0)


def _generate_random_match_score() -> int:
    """Generate a random match score between 60 and 80."""
    return random.randint(60, 80)


async def get_recommendations(
    db: AsyncIOMotorDatabase,
    user_id: Optional[str],
    payload: RecommendationRequest,
) -> List[InternshipResponse]:
    # Fetch internships from db to rank them
    cursor = db.internships.find({})
    internships_raw = [doc async for doc in cursor]

    if not internships_raw:
        return []

    # 1. Check if profile is empty
    if _is_empty_profile(payload.skills, payload.interests):
        # Empty profile: return random top N with 60-80% match score
        random_internships = random.sample(
            internships_raw,
            min(payload.top_n, len(internships_raw))
        )

        bookmarked, applied = await _user_meta(db, user_id) if user_id else (set(), set())

        return [
            _doc_to_response(
                doc,
                match_score=_generate_random_match_score(),
                bookmarked_ids=bookmarked,
                applied_ids=applied,
            )
            for doc in random_internships
        ]

    # 2. Get domain probabilities from ML model for non-empty profile
    domain_probs = recommender.predict_domain_probs(
        skills=payload.skills,
        cgpa=payload.cgpa,
        interests=payload.interests,
        preferred_location=payload.preferred_location,
        preferred_type=payload.preferred_type,
    )

    # 3. Score each internship
    scored = []
    for doc in internships_raw:
        score = _compute_score(
            domain_probs=domain_probs,
            internship_domain=doc.get("domain", ""),
            internship_location=doc.get("location", ""),
            internship_type=doc.get("type", ""),
            preferred_location=payload.preferred_location,
            preferred_type=payload.preferred_type,
        )
        scored.append((score, doc))

    # 4. Sort descending by score
    scored.sort(key=lambda x: x[0], reverse=True)
    top = scored[: payload.top_n]

    # 5. Enrich with bookmark / applied meta
    bookmarked, applied = await _user_meta(db, user_id) if user_id else (set(), set())

    return [
        _doc_to_response(
            doc,
            match_score=score,
            bookmarked_ids=bookmarked,
            applied_ids=applied,
        )
        for score, doc in top
    ]
