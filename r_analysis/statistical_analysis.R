# 🏏 IPL Statistical Analysis & Validation
# R Script for validating business insights
# Updated to work with new optimized datasets: ipl_player_metrics.csv, ipl_ball_enriched.csv

library(ggplot2)
library(dplyr)
library(readr)

# Load Data
player_metrics <- read_csv("../data/processed/ipl_player_metrics.csv")
ball_data <- read_csv("../data/processed/ipl_ball_enriched.csv")

# ======================================================
# 1. HYPOTHESIS TESTING: Consistency vs Performance
# ======================================================
# H0: Consistent players (low Consistency Index) do not have higher averages.
# H1: Consistent players have higher batting averages.
# Note: Low Consistency Index value might mean high consistency if it's Avg/StdDev? 
# In Python script: consistency_index = avg_runs / std_dev. 
# So HIGHER index = Mean is high relative to spread = MORE Consistent (signal-to-noise).

# Categorize based on Consistency Index (Top 25% vs Bottom 25%)
quantiles <- quantile(player_metrics$consistency_index, probs = c(0.25, 0.75), na.rm = TRUE)
player_metrics <- player_metrics %>%
  mutate(consistency_group = case_when(
    consistency_index > quantiles[2] ~ "High Consistency",
    consistency_index < quantiles[1] ~ "Low Consistency",
    TRUE ~ "Average"
  ))

# T-Test on Batting Average
t_test_result <- t.test(batting_average ~ consistency_group, 
                        data = subset(player_metrics, consistency_group %in% c("High Consistency", "Low Consistency")))
print("--- T-Test: Batting Average Difference (High vs Low Consistency) ---")
print(t_test_result)

# ======================================================
# 2. ANOVA: Venue Advantage & Match Intensity
# ======================================================
# We nee Match Intensity per match.
# Formula: Sum(Runs) + Wickets*20 + Boundaries*5
match_intensity <- ball_data %>%
  group_by(match_id, venue, winner) %>%
  summarise(
    total_runs = sum(total_runs, na.rm = TRUE),
    wickets = sum(is_wicket, na.rm = TRUE),
    boundaries = sum(ifelse(batsman_runs %in% c(4, 6), 1, 0), na.rm = TRUE)
  ) %>%
  mutate(intensity_score = total_runs + (wickets * 20) + (boundaries * 5))

# Does the venue significantly affect the match intensity?
anova_model <- aov(intensity_score ~ venue, data = match_intensity)
print("--- ANOVA: Match Intensity by Venue ---")
summary(anova_model)

# ======================================================
# 3. CLUSTERING: Player Segmentation
# ======================================================
# Using K-Means to classify players
set.seed(42)
cluster_data <- player_metrics %>%
  select(avg_runs_per_match, strike_rate, consistency_index) %>%
  na.omit() %>%
  scale()

kmeans_result <- kmeans(cluster_data, centers = 4) # 4 Clusters: Anchors, Finishers, Pinch Hitters, struggling
player_metrics_clean <- player_metrics %>% na.omit() # Align rows
player_metrics_clean$cluster <- as.factor(kmeans_result$cluster)

# Visualize Clusters
png("../r_analysis/player_clusters.png", width = 800, height = 600)
ggplot(player_metrics_clean, aes(x=strike_rate, y=avg_runs_per_match, color=cluster, size=consistency_index)) +
  geom_point(alpha=0.7) +
  labs(title="Player Clusters: Strike Rate vs Avg Runs", subtitle="Size = Consistency Index", x="Strike Rate", y="Avg Runs/Match") +
  theme_minimal()
dev.off()

print("✅ Statistical Analysis Complete. Plots saved.")
