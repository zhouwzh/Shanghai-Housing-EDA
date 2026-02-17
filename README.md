# Shanghai Housing Listings — Reproducible R Cleaning + EDA + Spatial Visualization (Public Data)

This mini-project is designed as a **policy-style data work sample** (cleaning, documentation, EDA, visualization, and optional GIS) using a **public Shanghai housing listings dataset**.

It is intentionally structured like applied research support work:
- clear inputs/outputs
- explicit cleaning rules + QA checks
- simple, stakeholder-ready tables and figures
- optional spatial visualization if latitude/longitude (and/or district boundaries) are available

## Data
Use any public Shanghai housing/listings dataset that includes (at minimum) a district field and price/area fields.
Examples of public sources include datasets shared on Kaggle / open repositories (download separately and place in `data/`).

### Expected columns (recommended)
| column | meaning |
|---|---|
| district | administrative district in Shanghai (e.g., Pudong, Minhang) |
| neighborhood | neighborhood / community name (optional) |
| price_total_rmb | total price (RMB) |
| area_sqm | area in square meters |
| unit_price_rmb_sqm | unit price (RMB per sqm). If missing, it will be computed. |
| build_year | build year (optional) |
| lat, lon | latitude/longitude (optional, enables spatial plots) |
| list_date | listing date (optional) |

Place your raw file at:
- `data/shanghai_housing_raw.csv`

If you don't have the raw file yet, you can still run the pipeline using the included **synthetic sample**:
- `data/sample_shanghai_housing.csv` (fake demo data; replace with real public data for your submission)

## Folder structure
```
scripts/
  01_ingest_clean.R
  02_eda_plots.R
  03_spatial.R
data/
  shanghai_housing_raw.csv        # (you provide)
  sample_shanghai_housing.csv     # (included demo)
outputs/
figures/
```

## Requirements
R >= 4.2 recommended.

Install packages:
```r
install.packages(c("tidyverse","lubridate","janitor","readr","stringr","scales","sf"))
```

## How to run
From repo root:
```r
source("scripts/01_ingest_clean.R")
source("scripts/02_eda_plots.R")
source("scripts/03_spatial.R")  # optional
```

## Outputs
- Cleaned dataset: `outputs/clean_shanghai_housing.csv`
- Data dictionary: `outputs/data_dictionary.csv`
- Summary tables: `outputs/summary_by_district.csv`
- Figures:
  - `figures/district_unit_price_bar.png`
  - `figures/unit_price_hist.png`
  - `figures/price_vs_area.png`
  - `figures/spatial_points_or_bins.png` (if lat/lon exist)
  - Optional choropleth if you provide district boundaries GeoJSON:
    - Put a file at `data/shanghai_districts.geojson` with a `district` field
    - Output: `figures/district_choropleth.png`

## Notes for a Furman-style code sample
- Keep the raw download step separate; focus on **cleaning rules, documentation, and reproducibility**.
- Use `writing_sample.docx` to summarize your workflow and 2–3 descriptive findings.
