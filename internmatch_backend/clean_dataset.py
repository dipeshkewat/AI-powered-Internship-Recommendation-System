import pandas as pd

# 1. Load your raw dataset
# Replace "my_raw_file.csv" with the actual name of your file
df = pd.read_csv("internship_data_training.csv")

print("Original columns:", df.columns.tolist())

# # ---------------------------------------------------------
# # STEP 1: DELETE COLUMNS YOU DON'T WANT
# # ---------------------------------------------------------
# # Put the names of the columns you want to delete inside this list.
# # For example, if your CSV has columns named "Timestamp" and "Student Name" which you don't need:
# columns_to_delete = ["SalaryPeriod", "SalaryAvg","SalaryMax","SalaryMin"]




# # ---------------------------------------------------------
# # STEP 2: ADD NEW COLUMNS WITH AN AVERAGE OR DEFAULT VALUE
# # ---------------------------------------------------------
# # Let's say your dataset is entirely missing the "cgpa" column, but the ML model NEEDS it.
# # We will create a brand new "cgpa" column, and set every single person's CGPA to 7.5 (the average).
# df["cgpa"] = 7.5

# # Let's say your dataset is missing "location". We can add it and set everyone to "Remote".
# df["skills"] = "Python" + "," + "Machine Learning" + "," + "Data Science"

# # Let's say your dataset is missing "type". We can add it and set everyone to "Hybrid".
# df["interests"] = "Web Development" + "," + "Machine Learning" + "," + "Data Science"

print("Modified columns:", df.columns.tolist())

# ---------------------------------------------------------
# STEP 3: SAVE THE READY-TO-USE FILE
# ---------------------------------------------------------
# Save this fixed data into a brand new file called "ready_for_training.csv"
df.to_csv("ready_for_training.csv", index=False)
print("Saved successfully! Your new file is 'ready_for_training.csv'.")
