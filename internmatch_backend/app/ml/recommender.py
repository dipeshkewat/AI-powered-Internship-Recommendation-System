"""
app/ml/recommender.py
──────────────────────
Random Forest–based recommendation engine.

Training flow  (called once via scripts/train_model.py):
  1. Build a synthetic / real dataset of (profile_features → domain_label).
  2. Fit a RandomForestClassifier.
  3. Persist model + encoders with joblib.

Inference flow (called per /recommendations request):
  1. Encode user features (skills → multi-hot, domain → one-hot, etc.).
  2. Predict class probabilities over all domain labels.
  3. For each internship, look up its domain probability as `match_score`.
  4. Return internships sorted by score desc.
"""

import logging
import os
from pathlib import Path
from typing import Any, Dict, List

import joblib
import numpy as np

from app.core.config import settings

logger = logging.getLogger(__name__)

# ── Canonical feature vocabulary ─────────────────────────────────────────────
ALL_SKILLS = [
    "Flutter", "Dart", "Python", "React", "Node.js", "FastAPI",
    "MongoDB", "Firebase", "ML", "scikit-learn", "PyTorch", "TensorFlow",
    "Java", "Kotlin", "Swift", "SQL", "PostgreSQL", "Docker", "Git",
    "REST APIs", "GraphQL", "TypeScript", "Next.js", "AWS", "GCP",
]

ALL_DOMAINS = [
    "AI/ML", "App Dev", "Blockchain", "Cloud", "Cybersecurity", "Data Science",
    "DevOps", "Game Dev", "UI/UX", "Web",
    "Full Stack Development", "Android Development", "NLP / GenAI", 
    "Embedded Systems / IoT", "Data Engineering", "Web Development", 
    "iOS Development", "Computer Vision", "Machine Learning", "Cloud Computing",
]

ALL_LOCATIONS = ["Remote", "Bangalore, India", "Mumbai, India", "Hyderabad, India", "Other"]
ALL_TYPES = ["Remote", "Hybrid", "On-site", "Any"]


def _multi_hot(values: List[str], vocab: List[str]) -> List[int]:
    return [1 if v in values else 0 for v in vocab]


def _one_hot(value: str, vocab: List[str]) -> List[int]:
    return [1 if v == value else 0 for v in vocab]


def _normalise_cgpa(cgpa: float) -> float:
    return max(0.0, min(10.0, cgpa)) / 10.0


def build_feature_vector(
    skills: List[str],
    cgpa: float,
    interests: List[str],
    preferred_location: str,
    preferred_type: str,
) -> List[float]:
    """Produces the fixed-length feature vector fed to the RF model."""
    vec: List[float] = []
    vec.extend(_multi_hot(skills, ALL_SKILLS))             # 25 dims
    vec.append(_normalise_cgpa(cgpa))                       # 1  dim
    vec.extend(_multi_hot(interests, ALL_DOMAINS))          # 10 dims
    vec.extend(_one_hot(preferred_location, ALL_LOCATIONS)) # 5  dims
    vec.extend(_one_hot(preferred_type, ALL_TYPES))         # 4  dims
    # Total: 45 dims
    return vec


FEATURE_DIM = len(ALL_SKILLS) + 1 + len(ALL_DOMAINS) + len(ALL_LOCATIONS) + len(ALL_TYPES)


class Recommender:
    """
    Wrapper around a scikit-learn RandomForestClassifier.

    predict_domain_probs() returns a dict mapping domain → probability
    for a given student profile.  Callers use this to score each
    internship by its domain and sort descending.
    """

    def __init__(self) -> None:
        self._model: Any = None
        self._encoders: Dict[str, Any] = {}
        self._loaded = False

    def load(self) -> None:
        model_path = Path(settings.MODEL_PATH)
        encoder_path = Path(settings.ENCODER_PATH)

        if model_path.exists() and encoder_path.exists():
            self._model = joblib.load(model_path)
            self._encoders = joblib.load(encoder_path)
            self._loaded = True
            logger.info("ML model loaded from %s", model_path)
        else:
            logger.warning(
                "ML model artifacts not found at %s. "
                "Falling back to heuristic scoring. "
                "Run scripts/train_model.py to generate artifacts.",
                model_path,
            )

    def predict_domain_probs(
        self,
        skills: List[str],
        cgpa: float,
        interests: List[str],
        preferred_location: str,
        preferred_type: str,
    ) -> Dict[str, float]:
        """
        Returns {domain: probability} for all known domains.
        Falls back to heuristic if model not loaded.
        """
        if self._loaded and self._model is not None:
            vec = np.array(
                build_feature_vector(skills, cgpa, interests, preferred_location, preferred_type)
            ).reshape(1, -1)
            probs = self._model.predict_proba(vec)[0]
            classes = self._model.classes_
            return {cls: float(prob) for cls, prob in zip(classes, probs)}

        # ── Heuristic fallback ────────────────────────────────────────────────
        return self._heuristic_scores(skills, interests)

    @staticmethod
    def _heuristic_scores(skills: List[str], interests: List[str]) -> Dict[str, float]:
        """
        Simple rule-based scoring used when the trained model is absent.
        Maps known skill/interest keywords to domain probabilities.
        If no skills/interests provided, returns uniform distribution.
        """
        domain_keywords = {
            "AI/ML":        {"ML", "scikit-learn", "PyTorch", "TensorFlow", "Python", "AI/ML"},
            "App Dev":      {"Flutter", "Dart", "Kotlin", "Swift", "Firebase", "App Dev"},
            "Web":          {"React", "Node.js", "Next.js", "TypeScript", "GraphQL", "Web"},
            "Data Science": {"Python", "SQL", "Pandas", "NumPy", "Data Science"},
            "Cloud":        {"AWS", "GCP", "Docker", "Cloud"},
            "DevOps":       {"Docker", "Git", "DevOps"},
            "Cybersecurity":{"Cybersecurity"},
            "UI/UX":        {"UI/UX"},
            "Blockchain":   {"Blockchain"},
            "Game Dev":     {"Game Dev"},
        }
        combined = set(skills) | set(interests)
        
        # If profile is empty, return uniform distribution across all domains
        if not combined:
            uniform_prob = 1.0 / len(domain_keywords)
            return {d: uniform_prob for d in domain_keywords.keys()}
        
        raw: Dict[str, float] = {}
        for domain, keywords in domain_keywords.items():
            raw[domain] = len(combined & keywords) + (0.3 if domain in interests else 0)

        total = sum(raw.values()) or 1.0
        return {d: v / total for d, v in raw.items()}


# Singleton — loaded once at app startup
recommender = Recommender()
