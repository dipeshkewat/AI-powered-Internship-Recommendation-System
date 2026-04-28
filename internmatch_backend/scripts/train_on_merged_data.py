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
    # STEP 1: Point to the new merged data file
    csv_file = "final_training_data.csv"
    
    if not os.path.exists(csv_file):
        print(f"Error: Could not find '{csv_file}'. Please ensure it is in the internmatch_backend folder.")
        return

    print(f"Loading '{csv_file}'...")
    df = pd.read_csv(csv_file)
    
    X = []
    y = []

    # STEP 2: Process each row to extract features (X) and the target label (y)
    for index, row in df.iterrows():
        # Get the skills string and convert to a Python list
        skills_str = str(row.get("skills", ""))
        skills = [s.strip() for s in skills_str.split(",")] if skills_str != "nan" and skills_str else []
        
        # We assume the ideal candidate is interested in the category of the internship
        category = str(row.get("category", "General"))
        interests = [category]
        
        # Default CGPA since companies don't specify it in this dataset
        cgpa = 7.5
           
        location = str(row.get("location", "Remote"))
        type_ = str(row.get("type", "Remote"))
        
        # The result/answer we want the ML to predict is the category/domain
        domain_label = category
        
        # STEP 3: Convert textual data into numbers (vectors) the ML model understands
        vec = build_feature_vector(skills, cgpa, interests, location, type_)
        
        X.append(vec)
        y.append(domain_label)

    X = np.array(X)
    y = np.array(y)

    print(f"Dataset ready. Total rows: {len(X)}")

    # STEP 4: Split data into training and testing sets (10% used for testing)
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.1, random_state=42
    )

    # STEP 5: Train the Random Forest ML Model
    print("Training Random Forest ML Model...")
    clf = RandomForestClassifier(n_estimators=100, max_depth=15, random_state=42)
    clf.fit(X_train, y_train)

    print("Training complete! Model Score (Accuracy on test data):", clf.score(X_test, y_test))

    # STEP 6: Save the trained model to artifacts folder
    artifact_dir = Path("app/ml/artifacts")
    artifact_dir.mkdir(parents=True, exist_ok=True)
    
    joblib.dump(clf, artifact_dir / "rf_model.joblib")
    joblib.dump({"domains": ALL_DOMAINS, "skills": ALL_SKILLS}, artifact_dir / "encoders.joblib")

    print("\n✅ SUCCESS: Custom Model saved! Start your FastAPI server to use it.")

if __name__ == "__main__":
    main()
