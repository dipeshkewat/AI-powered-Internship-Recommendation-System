"""
scripts/train_on_real_data.py
──────────────────────────────

Trains the Random Forest model using real datasets:
  1. user_training_data.csv — student profiles and their preferred domains
  2. internship_listings_10000.csv — internship data with domains

This creates a proper mapping of student features → domain preferences
instead of using synthetic data.

Run from project root:
    python scripts/train_on_real_data.py
"""

import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import pandas as pd
import numpy as np
import joblib
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score

from app.ml.recommender import (
    ALL_SKILLS,
    ALL_DOMAINS,
    ALL_LOCATIONS,
    ALL_TYPES,
    build_feature_vector,
)

def load_and_prepare_data():
    """Load user and internship data, create training dataset."""
    
    print("=" * 80)
    print("Loading real training datasets...")
    print("=" * 80)
    
    # Load user training data
    user_csv = "user_training_data.csv"
    if not os.path.exists(user_csv):
        print(f"❌ {user_csv} not found!")
        return None, None
    
    users = pd.read_csv(user_csv)
    print(f"✓ Loaded {len(users)} user profiles")
    print(f"  Columns: {users.columns.tolist()}")
    
    # Load internship data
    internship_csv = "internship_listings_10000.csv"
    if not os.path.exists(internship_csv):
        print(f"❌ {internship_csv} not found!")
        return None, None
    
    internships = pd.read_csv(internship_csv)
    print(f"✓ Loaded {len(internships)} internship listings")
    print(f"  Domains: {internships['domain'].unique().tolist()}")
    
    # Create training data: map student features to their preferred/applied domains
    X = []
    y = []
    
    print("\n" + "=" * 80)
    print("Building training dataset from user profiles...")
    print("=" * 80)
    
    for idx, user in users.iterrows():
        try:
            # Extract user features
            skills_str = str(user.get('skills', ''))
            interests_str = str(user.get('interests', ''))
            
            # Parse comma-separated skills and interests
            skills = [s.strip() for s in skills_str.split(',') if s.strip()]
            interests = [i.strip() for i in interests_str.split(',') if i.strip()]
            
            cgpa = float(user.get('cgpa', 7.5)) if pd.notna(user.get('cgpa')) else 7.5
            cgpa = max(0.0, min(10.0, cgpa))  # Clamp to 0-10
            
            location = str(user.get('preferred_location', 'Remote')).strip()
            type_ = str(user.get('preferred_type', 'Hybrid')).strip()
            
            # Infer preferred domain from interests
            # If interests contain a known domain, use it; otherwise pick first interest
            preferred_domain = 'Web'  # Default fallback
            if interests:
                # Check if any interest matches a known domain
                for interest in interests:
                    for domain in ALL_DOMAINS:
                        if domain.lower() in interest.lower() or interest.lower() in domain.lower():
                            preferred_domain = domain
                            break
                    if preferred_domain != 'Web':
                        break
                # If no match found, use first interest as-is
                if preferred_domain == 'Web':
                    preferred_domain = interests[0] if interests else 'Web'
            
            # Strip domain to valid values
            if preferred_domain not in ALL_DOMAINS:
                # Try fuzzy matching
                found = False
                for domain in ALL_DOMAINS:
                    if domain.lower() in preferred_domain.lower():
                        preferred_domain = domain
                        found = True
                        break
                if not found:
                    preferred_domain = 'Web'  # Ultimate fallback
            
            # Build feature vector
            vec = build_feature_vector(skills, cgpa, interests, location, type_)
            
            X.append(vec)
            y.append(preferred_domain)
            
            if (idx + 1) % 100 == 0:
                print(f"  Processed {idx + 1} users...")
                
        except Exception as e:
            print(f"  ⚠ Skipping user {idx}: {e}")
            continue
    
    print(f"\n✓ Created {len(X)} training samples")
    
    if len(X) == 0:
        print("❌ No valid training data created!")
        return None, None
    
    X = np.array(X)
    y = np.array(y)
    
    print(f"  X shape: {X.shape}")
    print(f"  Classes: {np.unique(y)}")
    print(f"  Class distribution: {np.bincount(pd.factorize(y)[0])}")
    
    return X, y

def train_and_save_model(X, y):
    """Train Random Forest and save artifacts."""
    
    if X is None or y is None:
        print("❌ Cannot train without data!")
        return False
    
    print("\n" + "=" * 80)
    print("Training Random Forest Classifier...")
    print("=" * 80)
    
    # Split: 80% train, 20% test
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, 
        test_size=0.2, 
        random_state=42,
        stratify=y if len(np.unique(y)) > 1 else None
    )
    
    print(f"Train set: {X_train.shape[0]} samples")
    print(f"Test set: {X_test.shape[0]} samples")
    
    clf = RandomForestClassifier(
        n_estimators=300,           # More trees for better generalization
        max_depth=25,               # Deeper trees for complex patterns
        min_samples_split=5,        # Require at least 5 samples per split
        min_samples_leaf=2,         # At least 2 samples per leaf
        class_weight='balanced',    # Handle class imbalance
        n_jobs=-1,                  # Use all CPU cores
        random_state=42,
        verbose=1,
    )
    
    clf.fit(X_train, y_train)
    
    # Evaluate
    y_pred_train = clf.predict(X_train)
    y_pred_test = clf.predict(X_test)
    
    train_acc = accuracy_score(y_train, y_pred_train)
    test_acc = accuracy_score(y_test, y_pred_test)
    
    print("\n" + "=" * 80)
    print("Model Performance")
    print("=" * 80)
    print(f"Training Accuracy: {train_acc:.4f} ({100*train_acc:.2f}%)")
    print(f"Test Accuracy: {test_acc:.4f} ({100*test_acc:.2f}%)")
    
    print("\nClassification Report (Test Set):")
    print(classification_report(y_test, y_pred_test, zero_division=0))
    
    print("\nFeature Importances (Top 10):")
    importances = clf.feature_importances_
    top_indices = np.argsort(importances)[-10:][::-1]
    for i, idx in enumerate(top_indices, 1):
        print(f"  {i}. Feature {idx}: {importances[idx]:.4f}")
    
    # Save model
    artifact_dir = Path("app/ml/artifacts")
    artifact_dir.mkdir(parents=True, exist_ok=True)
    
    model_path = artifact_dir / "rf_model.joblib"
    encoder_path = artifact_dir / "encoders.joblib"
    
    joblib.dump(clf, model_path)
    joblib.dump({"domains": ALL_DOMAINS, "skills": ALL_SKILLS}, encoder_path)
    
    print("\n" + "=" * 80)
    print("✅ Model Training Complete!")
    print("=" * 80)
    print(f"Model saved to: {model_path}")
    print(f"Encoders saved to: {encoder_path}")
    print("\nRestart your FastAPI server for changes to take effect.")
    
    return True

def main():
    X, y = load_and_prepare_data()
    if X is None:
        print("\n❌ Failed to load data!")
        return
    
    success = train_and_save_model(X, y)
    if not success:
        print("\n❌ Training failed!")

if __name__ == "__main__":
    main()
