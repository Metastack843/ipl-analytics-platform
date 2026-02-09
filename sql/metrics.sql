-- ==========================================
-- 🏏 IPL ANALYTICS - BUSINESS METRICS LAYER
-- ==========================================

-- 1️⃣ Team Engagement vs Performance (Strategic High-Level)
-- Uses the pre-aggregated Team Metrics table.
SELECT
  team,
  season,
  avg_match_intensity AS fan_engagement_score,
  win_rate,
  -- Strategy Quadrant:
  CASE 
    WHEN avg_match_intensity > 700 AND win_rate > 50 THEN 'Box Office Kings'
    WHEN avg_match_intensity < 700 AND win_rate > 50 THEN 'Efficient but Boring'
    WHEN avg_match_intensity > 700 AND win_rate < 50 THEN 'Entertainers (Losers)'
    ELSE 'Needs Rebrand'
  END AS strategy_quadrant
FROM ipl_team_metrics
ORDER BY avg_match_intensity DESC;

-- 2️⃣ Player Efficiency & ROI (Consistency)
-- Identifies reliable players over "One Hit Wonders"
SELECT
  batsman AS player_name,
  SUM(total_runs) AS career_runs,
  AVG(consistency_index) AS avg_consistency,
  AVG(strike_rate) AS career_strike_rate
FROM ipl_player_metrics
GROUP BY batsman
HAVING SUM(matches_played) > 30
ORDER BY avg_consistency DESC
LIMIT 20;

-- 3️⃣ Toss Bias Analysis (Ball Level Validity)
-- "Win Toss, Win Match?"
WITH match_level AS (
  SELECT DISTINCT
    match_id,
    toss_winner,
    toss_decision,
    winner
  FROM ipl_ball_enriched
)
SELECT
  toss_decision,
  COUNT(*) AS total_matches,
  AVG(CASE WHEN toss_winner = winner THEN 100.0 ELSE 0 END) AS win_pct_if_toss_won
FROM match_level
GROUP BY toss_decision;

-- 4️⃣ Venue / Home Advantage Validation
-- Does playing at home actually help? (Data from Team Metrics)
SELECT
  team,
  AVG(home_win_percentage) AS avg_home_win_pct,
  AVG(away_win_percentage) AS avg_away_win_pct,
  (AVG(home_win_percentage) - AVG(away_win_percentage)) AS home_advantage_gap
FROM ipl_team_metrics
GROUP BY team
ORDER BY home_advantage_gap DESC;
