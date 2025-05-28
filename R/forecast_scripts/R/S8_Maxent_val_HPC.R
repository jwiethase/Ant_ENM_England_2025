options(java.parameters = "-Xmx128g") 
library(rJava)
library(ENMeval)
library(terra)
library(raster)
library(tidyverse)
library(tidyterra)
library(data.table)
library(dismo)
library(tidyr)
library(parallel)
library(ecospat)

source('Ant_ENM/source/misc_functions.R')
n_cores = 32

args <- commandArgs(trailingOnly=TRUE)
job <- as.integer(args[1])

n_background_choices = c(10000, 20000)
thin_choices = c(0, 100, 1000)
seed_choices = c(42, 43, 44)
species_choices = c("Formica rufa", "Formica lugubris")

mult_combs <- crossing(species_choices, n_background_choices, thin_choices, seed_choices) # 54
comb_values <- mult_combs[job, ]
print(comb_values)

species_choice = comb_values$species_choices
thin_dist = comb_values$thin_choices 
seed = comb_values$seed_choices 
n_background = comb_values$n_background_choices 

# LOAD DATA FILES ------------------------------------------
## Covariates ------------------------------------------
best_model <- readRDS(paste0("Ant_ENM/model_out_soilTemp/", gsub(" ", "_", species_choice), '_thin', thin_dist, '_All_30m_seed_', seed, '_', n_background, ".RDS"))
e.mx <- readRDS(paste0("Ant_ENM/model_out_soilTemp/ENMeval_", gsub(" ", "_", species_choice), '_thin', thin_dist, '_All_30m_seed_', seed, '_', n_background, ".RDS"))

res <- eval.results(e.mx)
opt.mult.step <- res %>% 
  dplyr::filter(AICc == min(AICc)) %>%  # Akaike Information Criterion corrected for small sample size
  dplyr::filter(or.10p.avg == min(or.10p.avg)) %>% 
  dplyr::filter(auc.val.avg == max(auc.val.avg)) 

if(NROW(opt.mult.step) > 1){
      opt.mult.step <- opt.mult.step[1, ]
}

print('Starting Null model')
mod.null <- ENMnulls(e = e.mx,
                     mod.settings = list(fc = as.character(opt.mult.step[['fc']]), 
                                         rm = as.numeric(as.character(opt.mult.step[['rm']]))),
                     no.iter = 1000,
                     parallel = T, numCores = n_cores)

print(null.emp.results(mod.null))

pdf(paste0('Ant_ENM/figures_V2/NULL_mod_performance_', gsub(" ", "_", species_choice), '_thin', thin_dist, '_seed', seed, '_', n_background, '.pdf'),
    width = 8, height = 15)
evalplot.nulls(mod.null, stats = c("or.10p", "auc.diff", "auc.val", 'cbi.val'), plot.type = "histogram")
dev.off()

var_importance <- data.frame(best_model@results[grep("permutation.importance", rownames(best_model@results)),])
names(var_importance) <- "perm_imp"
print(arrange(var_importance, desc(perm_imp)))

write.csv(var_importance, paste0("Ant_ENM/model_out_soilTemp/PermVarImp_", gsub(" ", "_", species_choice), '_thin', thin_dist, '_All_30m_seed_', seed, '_', n_background, ".csv"))

val_bg_bias <- read.csv(paste0('Ant_ENM/data/val_bg_bias_', gsub(" ", "_", species_choice), "_seed", seed, '_n', n_background, '_thin', thin_dist, '.csv'), row.names = 1)

predictors <- rast('Ant_ENM/data/predictor_stack_soilTemp.tif')

names(predictors) <- c("current_perc09_total_rain_coldest", 
                       "current_perc09_total_rain_hottest",  
                       "current_dry_duration_09perc",      
                       "northness", "eastness", "hillshade", "slope", 
                       "distance_forest", "forest_PC1", "forest_PC2",
                       "SBIO3_Isothermality", 
                       "SBIO4_Temperature_Seasonality",
                       "SBIO8_Mean_Temperature_of_Wettest_Quarter",
                       "SBIO9_Mean_Temperature_of_Driest_Quarter",
                       "SBIO11_Mean_Temperature_of_Coldest_Quarter")

## Observations ------------------------------------------
unseen_records_vect <- vect('Ant_ENM/data/exhaustive_combined.shp') %>%
      filter(species == species_choice)

unseen_records <- unseen_records_vect %>%
      as.data.frame(geom = "XY") %>%
      dplyr::select(x, y)
gc()

# How well do these models perform against the holdout occurrence samples?
unseen_presence_env <- terra::extract(predictors, unseen_records, ID = F)

# Get presence and absence predictions using unseen data,
set.seed(seed+100)
unseen_pred <- predict(best_model, unseen_presence_env)

avtest <- data.frame(terra::extract(predictors, val_bg_bias))
random_absence_p <- predict(best_model, avtest)
e_unseen <- evaluate(p = unseen_pred, a = random_absence_p)

pdf(paste0('Ant_ENM/figures_V2/Mod_performance_', gsub(" ", "_", species_choice), '_thin', thin_dist, '_seed', seed, '_', n_background, '.pdf'),
    width = 8, height = 8)
par(mfrow=c(2, 2))
hist(unseen_pred, main = "Raw extracted suitability", xlab = "Extracted suitability at unseen presences")
boxplot(unseen_pred, main = paste0("Raw extracted median: ", round(median(unseen_pred, na.rm = T), digits = 2)))
plot(e_unseen, 'ROC')
boyce_test <- ecospat::ecospat.boyce(fit = random_absence_p, obs = unseen_pred[!is.na(unseen_pred)])
title(paste0("Boyce test cor: ", boyce_test$cor))
par(mfrow = c(1, 1))
dev.off()

print('Finished val figures')


predictors_coarse <- terra::aggregate(predictors, fact = 33, na.rm=TRUE)
suitability_preds <- terra::predict(best_model, predictors_coarse, wopt = list(steps = 100, datatype = "FLT4S"))

print(suitability_preds)
print('Raster prediction done')

pdf(paste0('Ant_ENM/figures_V2/PredsCoarse_', gsub(" ", "_", species_choice), '_thin', thin_dist, '_seed', seed, '_', n_background, '.pdf'),
    width = 8, height = 8)
plot(suitability_preds)
dev.off()

predictors_fine <- terra::aggregate(predictors, fact = 5, na.rm=TRUE)
suitability_preds_fine <- terra::predict(best_model, predictors_fine, wopt = list(steps = 100, datatype = "FLT4S"))

print(suitability_preds_fine)
print('Raster prediction done')

pdf(paste0('Ant_ENM/figures_V2/PredsFine_', gsub(" ", "_", species_choice), '_thin', thin_dist, '_seed', seed, '_', n_background, '.pdf'),
    width = 8, height = 8)
plot(suitability_preds_fine)
dev.off()








