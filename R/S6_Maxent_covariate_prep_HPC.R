# HEADER --------------------------------------------
#
# Author: Joris Wiethase
# Email: j.wiethase@gmail.com
# 
# Script Description:  
# Prepare the covariate layers for Maxent. Check covariate colinearity, and select a final set for use in the Maxent models

library(terra)
library(raster)
library(tidyverse)
library(tidyterra)
library(data.table)
library(tidyr)
source('Ant_ENM/source/misc_functions.R')

# Covariates ------------------------------------------
forest_covariates <- rast("Ant_ENM/data/forest_PCA_30m.tif")

forest_mask_buff <- forest_covariates$forest_mask_buff

climate_current <- rast("Ant_ENM/data/current_clim_stack.tif") %>%
      resample(forest_covariates)

climate_current$current_perc09_total_rain_coldest <- log(climate_current$current_perc09_total_rain_coldest+1)
climate_current$current_perc09_total_rain_hottest <- log(climate_current$current_perc09_total_rain_hottest+1)

soil_temp <- rast('Ant_ENM/data/soil_temp_full.tif') %>%
      terra::project(crs(km_proj)) %>%
      resample(forest_covariates)

print('climate done')
topo_covariates <- rast("Ant_ENM/data/topo_stack_30m.tif") %>%
      resample(forest_covariates)
topo_covariates$slope <- log(topo_covariates$slope+1)

distance_forest <- rast("Ant_ENM/data/distance_forest_30m.tif") %>%
      terra::resample(forest_covariates) + 0.001 %>%
      log()
names(distance_forest) <- "distance_forest"
print('distance_forest done')

covariates_stack <- c(forest_covariates, climate_current, topo_covariates, distance_forest, soil_temp) %>%
      terra::mask(forest_mask_buff)
print('covariates_stack done')
writeRaster(covariates_stack, 'Ant_ENM/data/full_covariates_stack_soilTemp.tif', overwrite = T)
print("Predictors done")

effort_masked_30m <- rast('Ant_ENM/data/effort_rast_lgcp_10km.tif') %>%
      resample(., forest_mask_buff) %>%
      mask(forest_mask_buff)

writeRaster(effort_masked_30m, 'Ant_ENM/data/effort_masked_30m.tif', overwrite = T)


# Check covariate correlation
covariates_stack <- covariates_stack %>%
      select(-distance_forest)

forest_mask_buff <- covariates_stack$forest_mask_buff
keep <- which(values(forest_mask_buff) == 1)

set.seed(1)
cells <- sample(keep, 1000000)
sample_df  <- terra::extract(covariates_stack, cells)  %>%
   select(current_perc09_total_rain_coldest, current_perc09_total_rain_hottest,
   current_perc01_temp_coldest, current_perc09_temp_hottest,
   current_dry_duration_09perc, current_annual_mean_temp,
   current_annual_sd_temp, current_temp_seasonality, northness, eastness,
   hillshade, slope, forest_PC1, forest_PC2,
   distance_forest, SBIO1_Annual_Mean_Temperature, SBIO2_Mean_Diurnal_Range,
   SBIO3_Isothermality, SBIO4_Temperature_Seasonality, SBIO5_Max_Temperature_of_Warmest_Month,
   SBIO6_Min_Temperature_of_Coldest_Month, SBIO7_Temperature_Annual_Range,
   SBIO8_Mean_Temperature_of_Wettest_Quarter, SBIO9_Mean_Temperature_of_Driest_Quarter,
   SBIO10_Mean_Temperature_of_Warmest_Quarter, SBIO11_Mean_Temperature_of_Coldest_Quarter) %>%
   as.data.table() %>%
   drop_na()

cat("Number of complete cases:", nrow(sample_df), "\n")

usdm::vif(sample_df)
print('VIF threshold: 5')
usdm::vifstep(sample_df, th = 5)

print('VIF threshold: 7')
usdm::vifstep(sample_df, th = 7)

print('VIF threshold: 10')
usdm::vifstep(sample_df, th = 10)
cor_matrix <- cor(sample_df, use = "complete.obs")

pdf('Ant_ENM/figures/covariate_correlation_soilTemp.pdf', width = 15, height = 15)
corrplot::corrplot(cor_matrix,
                   method = "circle",
                   type = "upper",
                   order = "original",
                   addCoef.col = "black",
                   number.cex = 0.65,
                   tl.cex = 1,
                   tl.offset = 3,
                   tl.col = "black", tl.srt = 45,
                   diag = FALSE,
                   col = colorRampPalette(c("red", "white", "blue"))(200),
                   na.label = NULL,
                   addgrid.col = "grey")
dev.off()

# Subset covariates. Should ideally be a separate script, since outputs from previous steps are 
# needed to make a selection here. I was just commenting out sections, but should be split into
# separate scripts.
covariates_stack <- rast('Ant_ENM/data/full_covariates_stack_soilTemp.tif')

keep <- c("current_perc09_total_rain_coldest",
          "current_perc09_total_rain_hottest",
          "current_dry_duration_09perc",
          "northness", "eastness", "hillshade", "slope",
          "forest_PC1", "forest_PC2",
          "SBIO3_Isothermality",
          "SBIO4_Temperature_Seasonality",
          "SBIO11_Mean_Temperature_of_Coldest_Quarter",
          "SBIO8_Mean_Temperature_of_Wettest_Quarter",
          "SBIO9_Mean_Temperature_of_Driest_Quarter")
predictors <- terra::subset(covariates_stack, subset = keep)

print(names(predictors))

writeRaster(predictors, 'Ant_ENM/data/predictor_stack_soilTemp_V2.tif', overwrite = T)
print("Predictors done")
