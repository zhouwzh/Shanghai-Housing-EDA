# scripts/01_ingest_clean.R
# Purpose: Read a public Shanghai housing listings CSV, clean + document it, and export analysis-ready outputs.

suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
  library(janitor)
  library(readr)
  library(stringr)
})

dir.create("outputs", showWarnings = FALSE, recursive = TRUE)

raw_path <- file.path("data", "shanghai_housing_raw.csv")
demo_path <- file.path("data", "sample_shanghai_housing.csv")

in_path <- if (file.exists(raw_path)) raw_path else demo_path
message("Input file: ", in_path)

df_raw <- readr::read_csv(in_path, show_col_types = FALSE) %>%
  janitor::clean_names()

# ---- Minimal schema enforcement ----
required <- c("district","price_total_rmb","area_sqm")
missing_required <- setdiff(required, names(df_raw))
if (length(missing_required) > 0) {
  stop("Missing required columns: ", paste(missing_required, collapse = ", "),
       "\nPlease rename your columns to match the expected schema (see README).")
}

df <- df_raw %>%
  mutate(
    district = str_to_title(str_trim(district)),
    neighborhood = if ("neighborhood" %in% names(.)) str_trim(neighborhood) else NA_character_,
    price_total_rmb = as.numeric(price_total_rmb),
    area_sqm = as.numeric(area_sqm),
    unit_price_rmb_sqm = if ("unit_price_rmb_sqm" %in% names(.)) as.numeric(unit_price_rmb_sqm) else NA_real_,
    unit_price_rmb_sqm = if_else(is.na(unit_price_rmb_sqm) & !is.na(price_total_rmb) & !is.na(area_sqm) & area_sqm > 0,
                                 price_total_rmb / area_sqm, unit_price_rmb_sqm),
    build_year = if ("build_year" %in% names(.)) as.integer(build_year) else NA_integer_,
    lat = if ("lat" %in% names(.)) as.numeric(lat) else NA_real_,
    lon = if ("lon" %in% names(.)) as.numeric(lon) else NA_real_,
    list_date = if ("list_date" %in% names(.)) ymd(list_date, quiet = TRUE) else as.Date(NA)
  ) %>%
  # Basic cleaning rules
  filter(
    !is.na(district),
    !is.na(price_total_rmb), price_total_rmb > 0,
    !is.na(area_sqm), area_sqm > 0
  )

# ---- QA checks ----
qa_counts <- df %>% summarise(
  n_rows = n(),
  n_districts = n_distinct(district),
  price_min = min(price_total_rmb, na.rm = TRUE),
  price_max = max(price_total_rmb, na.rm = TRUE),
  area_min = min(area_sqm, na.rm = TRUE),
  area_max = max(area_sqm, na.rm = TRUE),
  unit_price_min = min(unit_price_rmb_sqm, na.rm = TRUE),
  unit_price_max = max(unit_price_rmb_sqm, na.rm = TRUE)
)
message("QA summary:")
print(qa_counts)

district_counts <- df %>% count(district, sort = TRUE)
message("QA district counts (top):")
print(head(district_counts, 10))

# ---- Data dictionary ----
dict <- tibble(
  field = names(df),
  type = map_chr(df, ~ class(.x)[1]),
  description = c(
    "Shanghai administrative district",
    "Neighborhood/community name (optional)",
    "Total listing price in RMB",
    "Area in square meters",
    "Unit price in RMB per square meter (computed if missing)",
    "Build year (optional)",
    "Latitude (optional)",
    "Longitude (optional)",
    "Listing date (optional)"
  )[seq_along(names(df))]
)

write_csv(dict, file.path("outputs","data_dictionary.csv"))

# ---- Save cleaned data ----
out_path <- file.path("outputs", "clean_shanghai_housing.csv")
write_csv(df, out_path)
message("Saved cleaned data to: ", out_path)
