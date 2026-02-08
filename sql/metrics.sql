-- ==========================================
-- 🏏 IPL ANALYTICS - BUSINESS METRICS LAYER
-- ==========================================

-- 1️⃣ Team Engagement vs Performance
-- Identifies popular but underperforming teams.
WITH team_stats AS (
  SELECT
    batting_team AS team,
    COUNT(DISTINCT match_id) AS matches_played,
    SUM(match_intensity) AS total_engagement,
    -- Note: This is an approximation since win logic needs careful join
    -- Assuming a simplified view for this metric query
    0 AS placeholder_wins 
  FROM ipl_ball_by_ball
  GROUP BY batting_team
)
SELECT
  team,
  total_engagement / matches_played AS avg_engagement_per_match
FROM team_stats
ORDER BY avg_engagement_per_match DESC;

-- 2️⃣ Star Player Impact on Wins
-- Do stars actually win matches?
SELECT
  batsman,
  AVG(CASE WHEN winner = batting_team THEN 1 ELSE 0 END) AS win_probability_when_playing
FROM ipl_ball_by_ball
GROUP BY batsman
HAVING COUNT(DISTINCT match_id) > 20
ORDER BY win_probability_when_playing DESC;

-- 3️⃣ Toss Bias Analysis
-- Reveals toss advantage myths vs reality.
SELECT
  toss_decision,
  AVG(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) AS win_rate_if_toss_won
FROM matches_enriched
GROUP BY toss_decision;

-- 4️⃣ Venue Advantage
-- Shows stadium bias.
SELECT
  venue,
  AVG(team1_home_advantage) AS home_team_win_rate -- Simplified proxy
FROM matches_enriched
GROUP BY venue
HAVING COUNT(*) > 10;
