# scripts/02_eda_plots.R
# Purpose: Produce EDA tables + figures for Shanghai housing listings.

suppressPackageStartupMessages({
  library(tidyverse)
  library(janitor)
  library(scales)
})

dir.create("outputs", showWarnings = FALSE, recursive = TRUE)
dir.create("figures", showWarnings = FALSE, recursive = TRUE)

in_path <- file.path("outputs", "clean_shanghai_housing.csv")
stopifnot(file.exists(in_path))

df <- readr::read_csv(in_path, show_col_types = FALSE) %>% janitor::clean_names()

# ---- Summary by district ----
by_district <- df %>%
  group_by(district) %>%
  summarise(
    n_listings = n(),
    median_unit_price = median(unit_price_rmb_sqm, na.rm = TRUE),
    median_total_price = median(price_total_rmb, na.rm = TRUE),
    median_area = median(area_sqm, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(median_unit_price))

write_csv(by_district, file.path("outputs","summary_by_district.csv"))

# ---- Figure 1: district median unit price ----
p1 <- ggplot(by_district, aes(x = reorder(district, median_unit_price), y = median_unit_price)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Shanghai Housing Listings — Median Unit Price by District",
    x = NULL, y = "Median unit price (RMB / sqm)"
  ) +
  scale_y_continuous(labels = comma)

ggsave(file.path("figures","district_unit_price_bar.png"), p1, width = 8, height = 4, dpi = 200)

# ---- Figure 2: unit price distribution ----
p2 <- ggplot(df, aes(x = unit_price_rmb_sqm)) +
  geom_histogram(bins = 30) +
  labs(
    title = "Distribution of Unit Price",
    x = "Unit price (RMB / sqm)", y = "Count"
  ) +
  scale_x_continuous(labels = comma)

ggsave(file.path("figures","unit_price_hist.png"), p2, width = 8, height = 4, dpi = 200)

# ---- Figure 3: price vs area ----
p3 <- ggplot(df, aes(x = area_sqm, y = price_total_rmb)) +
  geom_point(alpha = 0.5) +
  labs(
    title = "Total Price vs Area",
    x = "Area (sqm)", y = "Total price (RMB)"
  ) +
  scale_y_continuous(labels = comma)

ggsave(file.path("figures","price_vs_area.png"), p3, width = 8, height = 4, dpi = 200)

message("Saved tables: outputs/summary_by_district.csv")
message("Saved figures: figures/district_unit_price_bar.png, figures/unit_price_hist.png, figures/price_vs_area.png")
