# 🏏 IPL Statistical Analysis & Validation
# R Script for validating business insights

library(ggplot2)
library(dplyr)
library(readr)

# Load Data
player_stats <- read_csv("../data/processed/player_stats.csv")
matches_enrich <- read_csv("../data/processed/matches_enriched.csv")

# ======================================================
# 1. HYPOTHESIS TESTING: Star Power vs Win Probability
# ======================================================
# H0: Star players (Top 10% salary/boundries) do NOT increase win probability
# H1: Star players significantly increase wins

# Proxy for Star: High Run Scorer (> 3000 runs)
player_stats <- player_stats %>%
  mutate(is_star = ifelse(batsman_runs > 3000, 1, 0))

# T-Test on win rates (assuming we had player-level win rates linked)
# For demo, comparing Strike Rate distributions between Stars and Non-Stars
t_test_result <- t.test(strike_rate ~ is_star, data = player_stats)
print("--- T-Test: Strike Rate Difference (Star vs Non-Star) ---")
print(t_test_result)

# ======================================================
# 2. ANOVA: Venue Advantage
# ======================================================
# Does the venue significantly affect the total runs scored?
anova_model <- aov(match_intensity ~ venue, data = matches_enrich)
print("--- ANOVA: Match Intensity by Venue ---")
summary(anova_model)

# ======================================================
# 3. CLUSTERING: Consistency vs Hype
# ======================================================
# Using K-Means to classify players
set.seed(123)
cluster_data <- player_stats %>%
  select(runs_per_match, consistency_index) %>%
  na.omit() %>%
  scale()

kmeans_result <- kmeans(cluster_data, centers = 3) # 3 Clusters: Consistent, Hype, Average

player_stats$cluster <- as.factor(kmeans_result$cluster)

# Visualize Clusters
png("../r_analysis/player_clusters.png")
ggplot(player_stats, aes(x=runs_per_match, y=consistency_index, color=cluster)) +
  geom_point() +
  labs(title="Player Clusters: Consistency vs Performance", x="Avg Runs", y="Consistency Index")
dev.off()

print("✅ Statistical Analysis Complete. Plots saved.")
