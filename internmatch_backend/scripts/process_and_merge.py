import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
INTERNSHIP_CSV = BASE_DIR / "internships.csv"
FINAL_TRAINING_CSV = BASE_DIR / "final_training_data.csv"

def process_and_merge():
    print(f"Loading {INTERNSHIP_CSV}...")
    try:
        df_new = pd.read_csv(INTERNSHIP_CSV)
    except Exception as e:
        print(f"Failed to load new csv: {e}")
        return
        
    # 1. Clean the new CSV
    # Add 'type' based on location
    def determine_type(loc):
        loc_lower = str(loc).lower()
        if 'remote' in loc_lower or 'work from home' in loc_lower:
            return 'Remote'
        elif 'hybrid' in loc_lower:
            return 'Hybrid'
        else:
            return 'In-office'
            
    df_new['type'] = df_new['location'].apply(determine_type)
    
    # Reorder columns for standard format
    standard_columns = [
        'category', 'title', 'company', 'location', 'type', 
        'duration', 'stipend', 'skills', 'description', 'detail_url'
    ]
    
    # Only keep the standard columns
    for col in standard_columns:
        if col not in df_new.columns:
            df_new[col] = ''
            
    df_new = df_new[standard_columns]
    
    # Drop rows without a valid title
    df_new = df_new.dropna(subset=['title'])
    df_new = df_new[df_new['title'].astype(str).str.strip() != '']
    
    # Fill specific columns with defaults
    df_new['category'] = df_new['category'].fillna('General')
    df_new['location'] = df_new['location'].fillna('Remote')
    df_new['stipend'] = df_new['stipend'].fillna('Unpaid')
    df_new['duration'] = df_new['duration'].fillna('Not specified')
    df_new['skills'] = df_new['skills'].fillna('Not specified')
    df_new['description'] = df_new['description'].fillna('No description available.')
    df_new['detail_url'] = df_new['detail_url'].fillna('').astype(str)
    df_new['company'] = df_new['company'].fillna('Unknown Company').astype(str)
    df_new['title'] = df_new['title'].astype(str)
    df_new['skills'] = df_new['skills'].astype(str)
    
    # Remove empty skills like ',,'
    df_new['skills'] = df_new['skills'].apply(lambda x: ','.join([s.strip() for s in x.split(',') if s.strip()]))
    
    print(f"New data has {len(df_new)} rows after cleaning.")
    
    # 2. Merge with final_training_data.csv
    print(f"Loading {FINAL_TRAINING_CSV}...")
    try:
        df_final = pd.read_csv(FINAL_TRAINING_CSV)
        print(f"Existing data has {len(df_final)} rows.")
    except Exception as e:
        print(f"Error loading {FINAL_TRAINING_CSV}: {e}")
        df_final = pd.DataFrame(columns=standard_columns)
        
    df_combined = pd.concat([df_final, df_new], ignore_index=True)
    
    # 3. Deduplicate
    df_combined['dedup_key'] = df_combined.apply(
        lambda row: row['detail_url'] if pd.notna(row['detail_url']) and str(row['detail_url']).strip() != '' 
        else f"{str(row['title']).strip().lower()}_{str(row['company']).strip().lower()}", 
        axis=1
    )
    
    df_combined = df_combined.drop_duplicates(subset=['dedup_key'], keep='first')
    df_combined = df_combined.drop(columns=['dedup_key'])
    
    print(f"Total rows after removing duplicates: {len(df_combined)}")
    
    # 4. Save back to final_training_data.csv
    df_combined.to_csv(FINAL_TRAINING_CSV, index=False)
    print(f"Successfully saved merged data to {FINAL_TRAINING_CSV}")

if __name__ == "__main__":
    process_and_merge()
