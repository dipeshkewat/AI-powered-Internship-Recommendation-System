import os
import sys
from pathlib import Path
import pandas as pd
import numpy as np
import joblib
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split

# Allow imports from project root
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.ml.recommender import (
    ALL_SKILLS, ALL_DOMAINS, ALL_LOCATIONS, ALL_TYPES,
    build_feature_vector,
)

def main():
    csv_file = "internship_data_training.csv"
    
    if not os.path.exists(csv_file):
        print(f"Error: Could not find '{csv_file}'. Please ensure it is in the internmatch_backend folder.")
        return

    print(f"Loading '{csv_file}'...")
    df = pd.read_csv(csv_file)
    
    X = []
    y = []

    # Process each row
    for index, row in df.iterrows():
        # Using exact columns from user's CSV
        skills_str = str(row.get("required_skills", ""))
        interests_str = str(row.get("domain", "")) # Defaulting interests to domain 
        
        # Split by comma to make Python Lists
        skills = [s.strip() for s in skills_str.split(",")] if skills_str != "nan" and skills_str else []
        interests = [i.strip() for i in interests_str.split(",")] if interests_str != "nan" and interests_str else []
        
        cgpa = float(row.get("min_cgpa_required", 7.5))
        if np.isnan(cgpa):
           cgpa = 7.5
           
        location = str(row.get("location", "Remote"))
        type_ = str(row.get("mode", "Hybrid"))
        
        # The result/answer for the ML
        domain_label = str(row.get("domain", "Unknown"))
        
        # Convert into numbers the ML model understands
        vec = build_feature_vector(skills, cgpa, interests, location, type_)
        
        X.append(vec)
        y.append(domain_label)

    X = np.array(X)
    y = np.array(y)

    print(f"Dataset ready. Total rows: {len(X)}")

    # Split data to test the model's intelligence
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.1, random_state=42
    )

    print("Training Random Forest ML Model...")
    clf = RandomForestClassifier(n_estimators=100, max_depth=15, random_state=42)
    clf.fit(X_train, y_train)

    print("Training complete! Model Score (Accuracy on test data):", clf.score(X_test, y_test))

    # Save the model
    artifact_dir = Path("app/ml/artifacts")
    artifact_dir.mkdir(parents=True, exist_ok=True)
    joblib.dump(clf, artifact_dir / "rf_model.joblib")
    joblib.dump({"domains": ALL_DOMAINS, "skills": ALL_SKILLS}, artifact_dir / "encoders.joblib")

    print("\n✅ SUCCESS: Custom Model saved! Start your FastAPI server to use it.")

if __name__ == "__main__":
    main()
