"""
scripts/train_model.py
───────────────────────
Trains the Random Forest classifier and saves model artifacts.

Run from the project root:
    python scripts/train_model.py

The script generates a synthetic dataset that maps student profiles
(skills, CGPA, interests, location, type) to internship domains.
In production, replace the synthetic rows with real application data
exported from MongoDB.

Outputs:
    app/ml/artifacts/rf_model.joblib
    app/ml/artifacts/encoders.joblib   (metadata / label list)
"""

import os
import sys
from pathlib import Path

# Allow imports from project root
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import joblib
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report

from app.ml.recommender import (
    ALL_SKILLS,
    ALL_DOMAINS,
    ALL_LOCATIONS,
    ALL_TYPES,
    build_feature_vector,
    FEATURE_DIM,
)

# ── Synthetic dataset construction ────────────────────────────────────────────
# Each row: (skills, cgpa, interests, location, type) → domain label

DOMAIN_PROFILES = {
    "AI/ML": {
        "skills": ["Python", "ML", "scikit-learn", "PyTorch", "TensorFlow"],
        "interests": ["AI/ML", "Data Science"],
    },
    "App Dev": {
        "skills": ["Flutter", "Dart", "Firebase", "Kotlin", "Swift"],
        "interests": ["App Dev"],
    },
    "Web": {
        "skills": ["React", "Node.js", "TypeScript", "Next.js", "GraphQL"],
        "interests": ["Web"],
    },
    "Data Science": {
        "skills": ["Python", "SQL", "Pandas", "NumPy"],
        "interests": ["Data Science", "AI/ML"],
    },
    "Cloud": {
        "skills": ["AWS", "GCP", "Docker"],
        "interests": ["Cloud", "DevOps"],
    },
    "DevOps": {
        "skills": ["Docker", "Git", "AWS"],
        "interests": ["DevOps", "Cloud"],
    },
    "Cybersecurity": {
        "skills": ["Python", "REST APIs"],
        "interests": ["Cybersecurity"],
    },
    "UI/UX": {
        "skills": ["Flutter", "React"],
        "interests": ["UI/UX"],
    },
    "Blockchain": {
        "skills": ["Python", "Node.js"],
        "interests": ["Blockchain"],
    },
    "Game Dev": {
        "skills": ["Python", "TypeScript"],
        "interests": ["Game Dev"],
    },
}

LOCATIONS = ["Remote", "Bangalore, India", "Mumbai, India", "Hyderabad, India", "Other"]
TYPES = ["Remote", "Hybrid", "On-site"]

rng = np.random.default_rng(42)


def random_profile(domain: str):
    profile = DOMAIN_PROFILES[domain]
    # Pick 2-5 skills from the domain's skill list, plus 0-2 random extra skills
    core_skills = rng.choice(profile["skills"], size=min(3, len(profile["skills"])), replace=False).tolist()
    extra = rng.choice(ALL_SKILLS, size=rng.integers(0, 3), replace=False).tolist()
    skills = list(set(core_skills + extra))

    interests = list(set(profile["interests"] + rng.choice(ALL_DOMAINS, size=rng.integers(0, 2), replace=False).tolist()))
    cgpa = float(rng.uniform(5.5, 10.0))
    location = rng.choice(LOCATIONS)
    type_ = rng.choice(TYPES)
    return skills, cgpa, interests, location, type_


def build_dataset(samples_per_domain: int = 200):
    X, y = [], []
    for domain in ALL_DOMAINS:
        for _ in range(samples_per_domain):
            skills, cgpa, interests, location, type_ = random_profile(domain)
            vec = build_feature_vector(skills, cgpa, interests, location, type_)
            X.append(vec)
            y.append(domain)
    return np.array(X), np.array(y)


def main():
    print("Building synthetic training dataset…")
    X, y = build_dataset(samples_per_domain=300)
    print(f"  Dataset shape: {X.shape}  |  Classes: {np.unique(y)}")

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    print("Training Random Forest classifier…")
    clf = RandomForestClassifier(
        n_estimators=200,
        max_depth=20,
        min_samples_split=4,
        class_weight="balanced",
        n_jobs=-1,
        random_state=42,
    )
    clf.fit(X_train, y_train)

    y_pred = clf.predict(X_test)
    print("\nClassification report on hold-out test set:")
    print(classification_report(y_test, y_pred))

    artifact_dir = Path("app/ml/artifacts")
    artifact_dir.mkdir(parents=True, exist_ok=True)

    model_path = artifact_dir / "rf_model.joblib"
    encoder_path = artifact_dir / "encoders.joblib"

    joblib.dump(clf, model_path)
    joblib.dump({"domains": ALL_DOMAINS, "skills": ALL_SKILLS}, encoder_path)

    print(f"\n✅ Model saved → {model_path}")
    print(f"✅ Encoders saved → {encoder_path}")


if __name__ == "__main__":
    main()
