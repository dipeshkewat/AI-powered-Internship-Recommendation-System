import pandas as pd

df1 = pd.read_csv("internships.csv")
print("internships.csv columns:", df1.columns.tolist())
print(f"internships.csv shape: {df1.shape}")

df2 = pd.read_csv("internships_1777226980.csv")
print("internships_1777226980.csv columns:", df2.columns.tolist())
print(f"internships_1777226980.csv shape: {df2.shape}")
