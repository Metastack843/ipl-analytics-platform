import duckdb
import os

# Define paths based on script location
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, "ipl_analytics.duckdb")
PROCESSED_DATA_PATH = os.path.join(BASE_DIR, "data", "processed")

# Check if processed files exist
required_files = ["ipl_ball_enriched.csv", "ipl_player_metrics.csv", "ipl_team_metrics.csv"]
for f in required_files:
    if not os.path.exists(os.path.join(PROCESSED_DATA_PATH, f)):
        print(f"❌ {f} not found at {PROCESSED_DATA_PATH}. Run notebooks first.")
        exit()

# Connect to DuckDB (creates file if not exists)
con = duckdb.connect(DB_PATH)

print("DATA LOADING START...")

# Create tables from CSVs directly
# 1. Enriched Ball-by-Ball
csv_path = os.path.join(PROCESSED_DATA_PATH, 'ipl_ball_enriched.csv')
con.execute(f"CREATE OR REPLACE TABLE ipl_ball_enriched AS SELECT * FROM read_csv_auto('{csv_path}')")
print("✅ Loaded ipl_ball_enriched")

# 2. Player Metrics
csv_path = os.path.join(PROCESSED_DATA_PATH, 'ipl_player_metrics.csv')
con.execute(f"CREATE OR REPLACE TABLE ipl_player_metrics AS SELECT * FROM read_csv_auto('{csv_path}')")
print("✅ Loaded ipl_player_metrics")

# 3. Team Metrics
csv_path = os.path.join(PROCESSED_DATA_PATH, 'ipl_team_metrics.csv')
con.execute(f"CREATE OR REPLACE TABLE ipl_team_metrics AS SELECT * FROM read_csv_auto('{csv_path}')")
print("✅ Loaded ipl_team_metrics")

# Verify
print("\n--- TABLE SUMMARY ---")
tables = con.execute("SHOW TABLES").fetchall()
for table in tables:
    count = con.execute(f"SELECT COUNT(*) FROM {table[0]}").fetchone()[0]
    print(f"{table[0]}: {count} rows")

con.close()
print(f"\n✅ Database created at {DB_PATH}")
