## Shanghai Housing Listings (Public Data): Reproducible Cleaning + EDA + Spatial Visualization

Weizhen (Alan) Zhou  

### 1. Background & Policy Context

Housing affordability and neighborhood differences are central topics in urban policy. This short note uses a **public Shanghai housing listings dataset** to demonstrate a reproducible workflow that is directly relevant to applied policy research support: **data cleaning, documentation, exploratory analysis, visualization, and (optional) spatial analysis**. The goal is descriptive insight and transparent methods—not causal inference.

**Data source.** A publicly shared Shanghai housing/listings dataset (downloaded from an open repository and stored locally as CSV). The analysis focuses on district-level differences in unit price and basic relationships between price and area.

### 2. Cleaning & Variable Definitions

All steps are implemented in R scripts and separated by stage.

- **Ingestion/Cleaning (`scripts/01_ingest_clean.R`)**: reads `data/shanghai_housing_raw.csv` (or a demo sample), standardizes key fields, removes invalid records (non-positive price/area), computes unit price when missing, and exports `outputs/clean_shanghai_housing.csv`.
- **Documentation**: writes a lightweight data dictionary to `outputs/data_dictionary.csv`.
- **QA checks**: prints row counts, district coverage, and basic ranges for price/area/unit price.

**Core variables.**
- `district`: Shanghai administrative district.
- `price_total_rmb`: total listing price (RMB).
- `area_sqm`: area (sqm).
- `unit_price_rmb_sqm`: unit price (RMB/sqm; computed if missing).
- Optional: `neighborhood`, `build_year`, `lat/lon`, `list_date`.

### 3. Exploratory Findings

**Finding 1 — District differences.** Median unit price varies by district.
- Table: `outputs/summary_by_district.csv`
- Figure: `figures/district_unit_price_bar.png`
- Summary:  Highest district: Huangpu at 125,000 RMB RMB/sqm; Lowest district: Lowest district: Minhang at 45,000 RMB/sqm.

**Finding 2 — Distribution of unit prices.** The overall unit price distribution shows dispersion and potential high-price tail.
- Figure: `figures/unit_price_hist.png`

**Finding 3 — Price–area relationship.** Total price scales with area, with variability across listings.
- Figure: `figures/price_vs_area.png`

**Spatial view.** If latitude/longitude are available, the pipeline produces a binned spatial plot (`figures/spatial_points_or_bins.png`). If district boundaries are provided (GeoJSON), it also produces a district choropleth (`figures/district_choropleth.png`).

### 4. Limitations & Next Steps (short)

- Listings may not represent the full market and can reflect selection/measurement bias.
- District-level aggregation is coarse; a next step is neighborhood-level analysis and adding denominators (population/housing stock).
- For policy analysis, link to additional datasets (e.g., transit access, school quality proxies, or census-like statistics) where appropriate.

---

## Reproducibility

Run from repo root:
```r
source("scripts/01_ingest_clean.R")
source("scripts/02_eda_plots.R")
source("scripts/03_spatial.R")
```

Outputs are saved under `outputs/` and `figures/`.
