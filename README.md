# Habitat Suitability and Conservation Planning for British Wood Ants

Species distribution modelling and landscape connectivity analysis for two wood ant species (*Formica rufa* and *Formica lugubris*) across England, with a focus on identifying translocation opportunities on Forestry England managed land.

## Overview

This project uses Maxent species distribution models at 30 m resolution to map current habitat suitability for *F. rufa* and *F. lugubris*, and combines model outputs with landscape metrics and dispersal analysis to identify occupied patches, naturally colonisable habitat, and potential translocation sites. A separate set of forecast scripts projects suitability changes under RCP 4.5 and RCP 8.5 climate scenarios for the period 2070–2073. Model outputs are exported to Google Earth Engine for interactive visualisation via a web app.

## Data Availability

This repository contains analysis scripts only. Occurrence records and model outputs are not included due to licensing and data-sharing restrictions. Environmental rasters, forest management boundaries, etc. are not included due to size restructions. The directory paths and filenames referenced in the scripts reflect the original project structure and would need to be adapted to any locally available data.

## Species

*Formica rufa* (southern red wood ant) — predominantly southern England.
*Formica lugubris* (northern hairy wood ant) — predominantly northern England. 

## Data Sources

**Occurrence records** are compiled from multiple sources: BWARS (Bees, Wasps and Ants Recording Society) and additional field surveys. Records are split into "sporadic" (presence-only, used for model fitting) and "exhaustive" (densely sampled sites, used for validation and patch delineation).

**Environmental covariates** include climate variables (rainfall extremes, temperature extremes, dry spell duration, soil temperature bioclimatic variables from SoilTemp), topography (northness, eastness, slope, hillshade — derived from NASA DEM at 30 m), and forest structure (canopy cover, height percentiles, and height variability from Environment Agency 1 m LiDAR VOM data, summarised via PCA).

**Climate data** for the current period (2010–2013) and future projections (2070–2073) are from the CHESS-SCAPE dataset (CEDA archive), using the EC-Earth3 GCM chosen for its strong performance in Europe.

**Forest management boundaries** are Forestry England managed forest polygons.

## Repository Structure

```
Ant_ENM/
├── R/
│   ├── S1_prepare_occurrence_data.R        # Compile and clean occurrence records
│   ├── S2_download_climate_forecasts.R     # Download CHESS-SCAPE climate NetCDFs
│   ├── S3_mask_and_export_daily_climate.R  # Crop, mask, reproject climate rasters
│   ├── S4a_process_climate_local.R         # Derive bioclimatic summary variables
│   ├── S4b_process_forestTopoEffort_local.R# Process forest, topography, effort layers
│   ├── S5_run_forest_PCA_HPC.R            # PCA on forest structure variables
│   ├── S6_Maxent_covariate_prep_HPC.R     # Assemble covariate stack, VIF selection
│   ├── S7_Maxent_prep_HPC.R               # Generate background and validation points
│   ├── S8_MaxEnt_HPC_hinge.R              # Fit Maxent models (with hinge features)
│   ├── S8_MaxEnt_HPC_no_hinge.R           # Fit Maxent models (without hinge features)
│   ├── S9_Maxent_val_HPC.R                # Null model evaluation, Boyce index, ROC
│   ├── S10_make_predictions_HPC.R          # Full 30 m resolution predictions
│   ├── S11_get_patch_distance_HPC.R        # Patch delineation, dispersal & translocation
│   ├── S12_make_final_figures.R            # Publication-ready figures
│   ├── S13_get_summary_values.R            # Summary statistics for report
│   └── S14_reproject_for_GEE.R             # Export rasters for Google Earth Engine
├── forecast_scripts/R/
│   ├── S6_Maxent_preds_prep_HPC.R          # Covariate prep for climate projections
│   ├── S7_MaxEnt_HPC.R                    # Maxent fitting for forecast models
│   ├── S8_Maxent_val_HPC.R                # Forecast model validation
│   └── S9_make_predictions_HPC.R           # Current vs RCP 4.5/8.5 predictions
├── source/
│   ├── misc_functions.R                    # Helper functions (thinning, plotting, CRS)
│   └── lsm_HPC_fix.R                      # Patched landscapemetrics functions for HPC
├── species_data/                           # Occurrence records (raw and processed)
├── covariates/                             # Environmental layers (raw and processed)
├── spatial_other/                          # ROI outlines, FE boundaries
├── model_out/                              # Maxent model objects and predictions
├── model_out_patches/                      # Patch and translocation rasters
├── data/                                   # Intermediate processed data files
└── figures/                                # Output figures
```

## Analytical Workflow

Scripts are numbered sequentially (S1–S14) and are designed to run in order. Many of the computationally intensive scripts (S5–S11) are written for execution on an HPC cluster, with job array indices controlling species/parameter combinations.

### 1. Data Preparation (S1–S4)

Occurrence records from multiple sources are standardised to a common CRS (British National Grid, re-projected to a custom Transverse Mercator in km units), filtered for spatial accuracy (≤ 100 m), and spatially thinned. Climate NetCDFs are downloaded, cropped to the region of interest, and summarised into bioclimatic variables (e.g. 90th percentile total rainfall of the coldest/hottest quarter, longest dry spell duration). Forest structure rasters are derived from 1 m LiDAR VOM data aggregated to 30 m. Topographic layers are computed from the NASA DEM. A sampling effort raster is generated from a log-Gaussian Cox process model at 10 km resolution.

### 2. Covariate Assembly (S5–S6)

Forest structure variables (canopy cover, 90th percentile height, height SD) are reduced via PCA. All covariates are assembled into a single raster stack, log-transformed where appropriate, and checked for multicollinearity using VIF (threshold = 10). The final predictor set includes 14 variables covering climate, soil temperature, topography, and forest structure.

### 3. Model Fitting and Selection (S7–S9)

Maxent models are fitted using `ENMeval` with bias-corrected background points weighted by sampling effort. A grid search tunes regularisation multiplier (1–10, step 0.5) and feature classes (L, Q, LQ, H, QH, LQH, etc.). Model selection is based on a stepwise filter: minimum 10th percentile omission rate → maximum validation AUC → minimum AICc. Models are validated against withheld exhaustive survey data using the Boyce index, and tested against 1000 null models. Both hinge and no-hinge model configurations are compared.

### 4. Prediction and Patch Analysis (S10–S11)

Best models predict suitability at full 30 m resolution across England. Predictions are thresholded to define "likely occupied now" (ON) patches (areas of high suitability within a 50 m buffer of known nest locations), "suitable not occupied" (SNO) patches, and dispersal-accessible habitat (within 100 m of occupied patches). Translocation candidate patches are identified as suitable habitat that is neither currently occupied nor within natural dispersal range, at configurable gap distances (0, 2, 5, 25 km). Landscape metrics (via `landscapemetrics`) characterise patch sizes and connectivity. All analyses are run across a factorial design of threshold and distance parameters.

### 5. Outputs and Visualisation (S12–S14)

Final figures include species-specific suitability maps, variable importance plots, and Forestry England site-level maps (e.g. New Forest, Cropton, Ennerdale). Summary statistics quantify the proportion of Forestry England land that is occupied, suitable, naturally colonisable, and available for translocation. Rasters are reprojected to EPSG:27700 for upload to Google Earth Engine.

### 6. Climate Projections (forecast_scripts/)

Suitability is projected under RCP 4.5 and RCP 8.5 for 2070–2073 by substituting future climate layers while holding forest and topography constant. Spatial difference and ratio maps show where suitability is expected to increase or decrease. Note: The forecast scripts are less actively maintained than the main analysis pipeline and are included here for reference. They may require adaptation to work with the current covariate and model structure.

## Key Parameters

| Parameter | Default | Description |
|---|---|---|
| `point_buffer` | 0.05 km (50 m) | Buffer around nest records to define occupied patches |
| `max_gap_dispersal` | 0.1 km (100 m) | Maximum gap for natural dispersal connectivity |
| `max_gap_translocation` | 0, 2, 5, 25 km | Maximum distance from occupied/colonisable habitat for translocation sites |
| `ON_threshold` | 0.25, 0.5 | Suitability threshold for "occupied now" patches |
| `SNO_threshold` | 0.5, 0.75 | Suitability threshold for "suitable not occupied" patches |

## Dependencies

The project is written in R and relies on the following key packages: `terra`, `raster`, `tidyverse`, `tidyterra`, `dismo`, `ENMeval`, `rJava` (for maxent.jar), `ecospat`, `enmSdmX`, `landscapemetrics`, `usdm`, `data.table`, `viridis`, `ggpubr`, and `patchwork`. Maxent models are run via `ENMeval` with `algorithm = 'maxent.jar'`, which requires a working Java installation and `rJava`. See the [ENMeval vignette](https://jamiemkass.github.io/ENMeval/articles/ENMeval-2.0-vignette.html) for setup details. Several scripts require substantial memory and are designed for HPC environments.

## CRS

All spatial operations use a custom Transverse Mercator projection in kilometre units:

```
+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +units=km +no_defs
```

This is defined as `km_proj` in `source/misc_functions.R`. Rasters exported for Google Earth Engine are reprojected to EPSG:27700 (British National Grid).

## Author

Joris Wiethase
j.wiethase@gmail.com
