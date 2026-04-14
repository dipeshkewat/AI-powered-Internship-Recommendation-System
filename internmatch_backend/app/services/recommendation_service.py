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
"""

import math
from typing import List

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


async def get_recommendations(
    db: AsyncIOMotorDatabase,
    user_id: str,
    payload: RecommendationRequest,
) -> List[InternshipResponse]:
    # 1. Get domain probabilities from ML model
    domain_probs = recommender.predict_domain_probs(
        skills=payload.skills,
        cgpa=payload.cgpa,
        interests=payload.interests,
        preferred_location=payload.preferred_location,
        preferred_type=payload.preferred_type,
    )

    # 2. Fetch internships from db to rank them
    # Removed .limit(500) so it can score from the full 10,000 pool instead of always the same 500 docs.
    cursor = db.internships.find({})
    internships_raw = [doc async for doc in cursor]

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
    bookmarked, applied = await _user_meta(db, user_id)

    return [
        _doc_to_response(
            doc,
            match_score=score,
            bookmarked_ids=bookmarked,
            applied_ids=applied,
        )
        for score, doc in top
    ]
