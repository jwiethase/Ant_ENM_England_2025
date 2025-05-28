rm(list = ls())
library(terra)
library(tidyverse)
library(patchwork)
library(raster)
source('Ant_ENM/source/misc_functions.R')

args <- commandArgs(trailingOnly=TRUE)
job <- as.integer(args[1])
species_list <- c("rufa", "lugubris")
species <- species_list[job]

# Load Covariates ------------------------------------------------------
covariates_stack <- rast('Ant_ENM/data/full_covariates_stack.tif')

# Variable Subsets -----------------------------------------------------
keep_vars <- list(
      current = c("current_perc09_total_rain_coldest", "current_perc09_total_rain_hottest",
                  "current_perc01_temp_coldest", "current_dry_duration_09perc",
                  "current_annual_sd_temp", "northness", "eastness", "hillshade", "slope",
                  "distance_forest", "forest_PC1", "forest_PC2"),
      rcp45 = c("rcp45_perc09_total_rain_coldest", "rcp45_perc09_total_rain_hottest",
                 "rcp45_perc01_temp_coldest", "rcp45_dry_duration_09perc", 
                 "rcp45_annual_sd_temp", "northness", "eastness", "hillshade", "slope",
                 "distance_forest", "forest_PC1", "forest_PC2"),
      rcp85 = c("rcp85_perc09_total_rain_coldest", "rcp85_perc09_total_rain_hottest",
                 "rcp85_perc01_temp_coldest", "rcp85_dry_duration_09perc", 
                 "rcp85_annual_sd_temp", "northness", "eastness", "hillshade", "slope",
                 "distance_forest", "forest_PC1", "forest_PC2")
)

# Species Loop ---------------------------------------------------------
if(species == 'rufa'){
      model <- readRDS('Ant_ENM/model_out/Formica_rufa_thin100_All_30m_seed_42_20000.RDS')
}
if(species == 'lugubris'){
      model <- readRDS('Ant_ENM/model_out/Formica_lugubris_thin100_All_30m_seed_44_20000.RDS')
}

predictors_current <- raster::subset(raster::stack(covariates_stack), subset = keep_vars$current)
predictors_rcp45 <- raster::subset(raster::stack(covariates_stack), subset = keep_vars$rcp45)
predictors_rcp85 <- raster::subset(raster::stack(covariates_stack), subset = keep_vars$rcp85)

names(predictors_rcp45) <- names(predictors_current)
names(predictors_rcp85) <- names(predictors_current)

suitability_current <- rast(predict(model, predictors_current, progress = 'text'))
suitability_rcp45 <- rast(predict(model, predictors_rcp45, progress = 'text'))
suitability_rcp85 <- rast(predict(model, predictors_rcp85, progress = 'text'))

writeRaster(suitability_current,
            filename = paste0('Ant_ENM/model_out/Formica_', species, '_current.tif'), overwrite = T)
writeRaster(suitability_rcp45,
            filename = paste0('Ant_ENM/model_out/Formica_', species, '_rcp45.tif'), overwrite = T)
writeRaster(suitability_rcp85,
            filename = paste0('Ant_ENM/model_out/Formica_', species, '_rcp85.tif'), overwrite = T)

suitability_current <- rast(paste0('Ant_ENM/model_out/Formica_', species, '_current.tif')) %>% 
      aggregate(fact = 10)
suitability_rcp45 <- rast(paste0('Ant_ENM/model_out/Formica_', species, '_rcp45.tif')) %>% 
      aggregate(fact = 10) 
suitability_rcp85 <- rast( paste0('Ant_ENM/model_out/Formica_', species, '_rcp85.tif')) %>% 
      aggregate(fact = 10)

prop_change_rcp45 <- sum(values(suitability_rcp45), na.rm = TRUE) / sum(values(suitability_current), na.rm = TRUE)
prop_change_rcp85 <- sum(values(suitability_rcp85), na.rm = TRUE) / sum(values(suitability_current), na.rm = TRUE)

suit_df <- data.frame(
      current = values(suitability_current),
      rcp45 = values(suitability_rcp45),
      rcp85 = values(suitability_rcp85)
)

names(suit_df) <- c('current', 'rcp45', 'rcp85')

suit_df_long <- suit_df %>%
      pivot_longer(cols = everything(), values_to = 'suitability', names_to = 'time')

print(summary(suit_df_long))

# Boxplot
suit_boxplot <- ggplot(suit_df_long, aes(x = as.factor(time), y = suitability)) +
      geom_boxplot() +
      geom_text(data = data.frame(
            time = c('rcp45', 'rcp85'),
            suitability = c(1.05, 1.05),
            label = c(paste0("x", round(prop_change_rcp45, 3)), paste0("x", round(prop_change_rcp85, 3)))
      ), aes(label = label)) +
      theme_bw() +
      xlab(NULL) +
      ggtitle(paste("Suitability Change -", species))

pdf(paste0('Ant_ENM/figures/', species, '_suit_change_combined.pdf'), width = 10, height = 7)
suit_boxplot
dev.off()

print('Finished boxplots')

rcp45_diff_plot <- ggplot() +
      tidyterra::geom_spatraster(data = suitability_rcp45 - suitability_current) +
      scale_fill_gradient2(na.value = 'transparent', low = 'red', high = 'forestgreen', midpoint = 0, name = "Difference") +
      ggtitle(paste("Current vs. 2070-73 rcp45 -", species)) +
      theme_bw()

rcp85_diff_plot <- ggplot() +
      tidyterra::geom_spatraster(data = suitability_rcp85 - suitability_current) +
      scale_fill_gradient2(na.value = 'transparent', low = 'red', high = 'forestgreen', midpoint = 0, name = "Difference") +
      ggtitle(paste("Current vs. 2070-73 rcp85 -", species)) +
      theme_bw()


pdf(paste0('Ant_ENM/figures/', species, '_rcp45_diff_change_combined.pdf'), width = 10, height = 7)
rcp45_diff_plot
dev.off()

pdf(paste0('Ant_ENM/figures/', species, '_rcp85_diff_change_combined.pdf'), width = 10, height = 7)
rcp85_diff_plot
dev.off()

print("Difference plots done")

# Ratio and Difference Plots
rcp45_ratio_plot <- ggplot() +
      tidyterra::geom_spatraster(data = suitability_rcp45 / suitability_current + 1e-6) +
      scale_fill_gradient2(na.value = 'transparent', low = 'red', high = 'forestgreen', midpoint = 1, name = "Change ratio") +
      ggtitle(paste("Current vs. 2070-73 rcp45 -", species)) +
      theme_bw()

rcp85_ratio_plot <- ggplot() +
      tidyterra::geom_spatraster(data = suitability_rcp85 / suitability_current + 1e-6) +
      scale_fill_gradient2(na.value = 'transparent', low = 'red', high = 'forestgreen', midpoint = 1, name = "Change ratio") +
      ggtitle(paste("Current vs. 2070-73 rcp85 -", species)) +
      theme_bw()

pdf(paste0('Ant_ENM/figures/', species, '_rcp45_ratio_change_combined.pdf'), width = 10, height = 7)
rcp45_ratio_plot
dev.off()

pdf(paste0('Ant_ENM/figures/', species, '_rcp85_ratio_change_combined.pdf'), width = 10, height = 7)
rcp85_ratio_plot
dev.off()

print("Ratio plots done")

