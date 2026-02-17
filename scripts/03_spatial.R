# scripts/03_spatial.R
# Purpose: Spatial visualization.
# - If lat/lon exist: produce a point/bin plot (no boundary files needed).
# - If you provide data/shanghai_districts.geojson with a `district` field:
#   produce a district choropleth of median unit price.

suppressPackageStartupMessages({
  library(tidyverse)
  library(sf)
  library(janitor)
  library(scales)
})

dir.create("figures", showWarnings = FALSE, recursive = TRUE)

in_path <- file.path("outputs", "clean_shanghai_housing.csv")
stopifnot(file.exists(in_path))

df <- readr::read_csv(in_path, show_col_types = FALSE) %>% janitor::clean_names()

has_latlon <- all(c("lat","lon") %in% names(df)) && any(!is.na(df$lat)) && any(!is.na(df$lon))

# ---- Plot A: point/bin map ----
if (has_latlon) {
  p <- ggplot(df, aes(x = lon, y = lat)) +
    geom_bin2d(bins = 40) +
    labs(
      title = "Shanghai Housing Listings — Spatial Distribution (Binned)",
      x = "Longitude", y = "Latitude", fill = "Listings"
    ) +
    theme_minimal()

  ggsave(file.path("figures","spatial_points_or_bins.png"), p, width = 7, height = 5, dpi = 200)
  message("Saved: figures/spatial_points_or_bins.png")
} else {
  message("No lat/lon found. Skipping point/bin spatial plot.")
}

# ---- Plot B: choropleth (optional) ----
geo_path <- file.path("data","shanghai_districts.geojson")
if (file.exists(geo_path)) {
  shp <- sf::st_read(geo_path, quiet = TRUE) %>%
    janitor::clean_names()

  if (!("district" %in% names(shp))) {
    stop("GeoJSON must include a `district` field matching the cleaned data's district names.")
  }

  by_district <- df %>%
    group_by(district) %>%
    summarise(median_unit_price = median(unit_price_rmb_sqm, na.rm = TRUE), .groups = "drop")

  shp2 <- shp %>% left_join(by_district, by = "district")

  p2 <- ggplot(shp2) +
    geom_sf(aes(fill = median_unit_price), color = "white", linewidth = 0.2) +
    labs(
      title = "Shanghai — Median Unit Price by District",
      fill = "RMB / sqm"
    ) +
    scale_fill_continuous(labels = comma) +
    theme_minimal()

  ggsave(file.path("figures","district_choropleth.png"), p2, width = 7, height = 5, dpi = 200)
  message("Saved: figures/district_choropleth.png")
} else {
  message("No data/shanghai_districts.geojson provided. Skipping choropleth.")
}
