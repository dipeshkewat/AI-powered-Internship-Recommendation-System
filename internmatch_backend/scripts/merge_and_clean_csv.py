import pandas as pd
from pathlib import Path
import numpy as np

# Paths
BASE_DIR = Path(__file__).resolve().parent.parent
INTERNSHIP_CSV_1 = BASE_DIR / "internships.csv"
INTERNSHIP_CSV_2 = BASE_DIR / "internships_1777226980.csv"
OUTPUT_CSV = BASE_DIR / "merged_internships.csv"

def merge_and_clean():
    # 1. Load Data
    try:
        df1 = pd.read_csv(INTERNSHIP_CSV_1)
        print(f"Loaded {INTERNSHIP_CSV_1.name} with {len(df1)} rows.")
    except Exception as e:
        print(f"Error loading {INTERNSHIP_CSV_1.name}: {e}")
        df1 = pd.DataFrame()
        
    try:
        df2 = pd.read_csv(INTERNSHIP_CSV_2)
        print(f"Loaded {INTERNSHIP_CSV_2.name} with {len(df2)} rows.")
    except Exception as e:
        print(f"Error loading {INTERNSHIP_CSV_2.name}: {e}")
        df2 = pd.DataFrame()

    # 2. Combine Data
    df = pd.concat([df1, df2], ignore_index=True)
    print(f"Total rows after combining: {len(df)}")
    
    # Drop rows that are completely empty or have no title
    df = df.dropna(subset=['title'])
    # Sometimes title is empty string
    df = df[df['title'].astype(str).str.strip() != '']
    print(f"Total rows after dropping empty titles: {len(df)}")

    # 3. Handle duplicates
    # Merge same internships based on detail_url if available, or title + company
    # First ensure detail_url is string
    if 'detail_url' not in df.columns:
        df['detail_url'] = ''
        
    df['detail_url'] = df['detail_url'].fillna('').astype(str)
    df['company'] = df['company'].fillna('Unknown Company').astype(str)
    df['title'] = df['title'].astype(str)
    
    # Create a deduplication key: detail_url if present, else title_company
    df['dedup_key'] = df.apply(
        lambda row: row['detail_url'] if pd.notna(row['detail_url']) and str(row['detail_url']).strip() != '' 
        else f"{row['title'].strip().lower()}_{row['company'].strip().lower()}", 
        axis=1
    )
    
    # Drop duplicates keeping the first occurrence (which is usually from internships.csv)
    df = df.drop_duplicates(subset=['dedup_key'], keep='first')
    df = df.drop(columns=['dedup_key'])
    print(f"Total rows after removing duplicates: {len(df)}")

    # 4. Fill Empty Spaces and Clean Format
    # Fill specific columns with defaults
    
    if 'category' not in df.columns:
        df['category'] = 'General'
    df['category'] = df['category'].fillna('General')
    
    df['location'] = df['location'].fillna('Remote')
    df['stipend'] = df['stipend'].fillna('Unpaid')
    df['duration'] = df['duration'].fillna('Not specified')
    df['skills'] = df['skills'].fillna('Not specified')
    df['description'] = df['description'].fillna('No description available.')
    
    # Clean location strings to ensure they are string types
    df['location'] = df['location'].astype(str)
    
    # Add an internship "type" based on location
    def determine_type(loc):
        loc_lower = str(loc).lower()
        if 'remote' in loc_lower or 'work from home' in loc_lower:
            return 'Remote'
        elif 'hybrid' in loc_lower:
            return 'Hybrid'
        else:
            return 'In-office'
            
    df['type'] = df['location'].apply(determine_type)
    
    # Ensure all skills are strings
    df['skills'] = df['skills'].astype(str)
    
    # Reorder columns for standard format
    standard_columns = [
        'category', 'title', 'company', 'location', 'type', 
        'duration', 'stipend', 'skills', 'description', 'detail_url'
    ]
    
    # Only keep the standard columns
    for col in standard_columns:
        if col not in df.columns:
            df[col] = ''
            
    df = df[standard_columns]

    # 5. Save the final single CSV
    df.to_csv(OUTPUT_CSV, index=False)
    print(f"Successfully saved merged and cleaned data to {OUTPUT_CSV.name} with {len(df)} rows.")

if __name__ == "__main__":
    merge_and_clean()
