import pandas as pd
from pathlib import Path
import numpy as np

# Paths
BASE_DIR = Path(__file__).resolve().parent.parent

# List of all CSV files to combine
CSV_FILES = [
    "internshala.csv",
    "internshala (1).csv",
    "internshala (2).csv",
    "internshala (3).csv",
    "internshala (4).csv",
    "merged_internships.csv"
]

OUTPUT_CSV = BASE_DIR / "final_training_data.csv"

def merge_all_csvs():
    all_dfs = []
    
    # 1. Load Data and Standardize Columns Before Merging
    for filename in CSV_FILES:
        filepath = BASE_DIR / filename
        try:
            df = pd.read_csv(filepath)
            
            # Rename columns if it's one of the new scraped files
            if 'job-title-href' in df.columns:
                rename_map = {
                    'job-title-href': 'title',
                    'job-title-href href': 'detail_url',
                    'company-name': 'company',
                    'stipend': 'stipend',
                    'text': 'description'
                }
                
                # The location and duration columns sometimes vary ('row-1-item', 'row-1-item 2')
                # Usually row-1-item is location, row-1-item 2 is duration
                if 'row-1-item' in df.columns:
                    rename_map['row-1-item'] = 'location'
                if 'row-1-item 2' in df.columns:
                    if 'location' not in rename_map.values():
                         rename_map['row-1-item 2'] = 'location'
                    else:
                         rename_map['row-1-item 2'] = 'duration'
                         
                if 'row-1-item 3' in df.columns:
                    rename_map['row-1-item 3'] = 'duration'
                
                df = df.rename(columns=rename_map)
                
                # Combine all skill columns into one comma-separated 'skills' column
                skill_cols = [col for col in df.columns if col.startswith('job_skill')]
                if skill_cols:
                    # Collect non-null skills
                    df['skills'] = df[skill_cols].apply(
                        lambda row: ','.join(row.dropna().astype(str)), axis=1
                    )
                    df = df.drop(columns=skill_cols)
                    
            print(f"Loaded {filename} with {len(df)} rows.")
            all_dfs.append(df)
        except Exception as e:
            print(f"Error loading {filename}: {e}")

    if not all_dfs:
        print("No data loaded.")
        return

    # 2. Combine Data
    df = pd.concat(all_dfs, ignore_index=True)
    print(f"Total rows after combining all files: {len(df)}")
    
    # Drop rows that are completely empty or have no title
    if 'title' in df.columns:
        df = df.dropna(subset=['title'])
        df = df[df['title'].astype(str).str.strip() != '']
    print(f"Total rows after dropping empty titles: {len(df)}")

    # 3. Handle duplicates
    for col in ['detail_url', 'company', 'title']:
        if col not in df.columns:
            df[col] = ''
            
    df['detail_url'] = df['detail_url'].fillna('').astype(str)
    df['company'] = df['company'].fillna('Unknown Company').astype(str)
    df['title'] = df['title'].astype(str)
    
    # Create a deduplication key: detail_url if present, else title_company
    df['dedup_key'] = df.apply(
        lambda row: row['detail_url'] if pd.notna(row['detail_url']) and str(row['detail_url']).strip() != '' 
        else f"{row['title'].strip().lower()}_{row['company'].strip().lower()}", 
        axis=1
    )
    
    # Drop duplicates keeping the first occurrence
    df = df.drop_duplicates(subset=['dedup_key'], keep='first')
    df = df.drop(columns=['dedup_key'])
    print(f"Total rows after removing duplicates: {len(df)}")

    # 4. Fill Empty Spaces and Clean Format
    if 'category' not in df.columns:
        df['category'] = 'General'
    df['category'] = df['category'].fillna('General')
    
    if 'location' not in df.columns:
        df['location'] = 'Remote'
    df['location'] = df['location'].fillna('Remote')
    
    if 'stipend' not in df.columns:
        df['stipend'] = 'Unpaid'
    df['stipend'] = df['stipend'].fillna('Unpaid')
    
    if 'duration' not in df.columns:
        df['duration'] = 'Not specified'
    df['duration'] = df['duration'].fillna('Not specified')
    
    if 'skills' not in df.columns:
        df['skills'] = 'Not specified'
    df['skills'] = df['skills'].fillna('Not specified')
    
    if 'description' not in df.columns:
        df['description'] = 'No description available.'
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
    
    # Remove empty skills like ',,'
    df['skills'] = df['skills'].apply(lambda x: ','.join([s.strip() for s in x.split(',') if s.strip()]))
    
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

    # Clean up any remaining NaN values that might have snuck through
    df = df.fillna({
        'category': 'General',
        'title': 'Unknown Title',
        'company': 'Unknown Company',
        'location': 'Remote',
        'type': 'Remote',
        'duration': 'Not specified',
        'stipend': 'Unpaid',
        'skills': 'Not specified',
        'description': 'No description available.',
        'detail_url': ''
    })

    # 5. Save the final single CSV
    df.to_csv(OUTPUT_CSV, index=False)
    print(f"Successfully saved merged and cleaned data to {OUTPUT_CSV.name} with {len(df)} rows.")

if __name__ == "__main__":
    merge_all_csvs()
