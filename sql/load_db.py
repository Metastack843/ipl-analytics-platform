import duckdb
import os

# Define paths
DB_PATH = "../ipl_analytics.duckdb"
PROCESSED_DATA_PATH = "../data/processed/"

# Check if processed files exist
if not os.path.exists(PROCESSED_DATA_PATH + "ipl_ball_by_ball_enriched.csv"):
    print("❌ Processed data not found. Run notebooks first.")
    exit()

# Connect to DuckDB (creates file if not exists)
con = duckdb.connect(DB_PATH)

print("DATA LOADING START...")

# Create tables from CSVs directly
# 1. Enriched Ball-by-Ball
con.execute(f"CREATE OR REPLACE TABLE ipl_ball_by_ball AS SELECT * FROM read_csv_auto('{PROCESSED_DATA_PATH}ipl_ball_by_ball_enriched.csv')")
print("✅ Loaded ipl_ball_by_ball")

# 2. Player Stats
con.execute(f"CREATE OR REPLACE TABLE player_stats AS SELECT * FROM read_csv_auto('{PROCESSED_DATA_PATH}player_stats.csv')")
print("✅ Loaded player_stats")

# 3. Matches Enriched
con.execute(f"CREATE OR REPLACE TABLE matches_enriched AS SELECT * FROM read_csv_auto('{PROCESSED_DATA_PATH}matches_enriched.csv')")
print("✅ Loaded matches_enriched")

# Verify
print("\n--- TABLE SUMMARY ---")
tables = con.execute("SHOW TABLES").fetchall()
for table in tables:
    count = con.execute(f"SELECT COUNT(*) FROM {table[0]}").fetchone()[0]
    print(f"{table[0]}: {count} rows")

con.close()
print(f"\n✅ Database created at {DB_PATH}")
