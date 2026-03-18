# HEADER --------------------------------------------
#
# Author: Joris Wiethase
# Email: j.wiethase@gmail.com
# 
# Script Description:  
# Fit Maxent models with parameter tuning on HPC. Allow for hinge features. 
# Run some first visual model checks

library(rJava)
library(ENMeval)
library(terra)
library(raster)
library(tidyverse)
library(tidyterra)
library(dismo)
library(tidyr)
library(ecospat)
library(enmSdmX)
library(viridis)

n_cores = 32

source('Ant_ENM/source/misc_functions.R')

args <- commandArgs(trailingOnly=TRUE)
job <- as.integer(args[1])

n_background_choices = c(10000, 20000, 30000)
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

dir.create("Ant_ENM/model_out_V2/hinge", recursive = T)
dir.create("Ant_ENM/figures_V2/hinge", recursive = T)

# LOAD DATA FILES ------------------------------------------
## Covariates ------------------------------------------
bg_bias <- read.csv(paste0('Ant_ENM/data/bg_bias_', gsub(" ", "_", species_choice), "_seed", seed, '_n', n_background, '_thin', thin_dist, '.csv'), row.names = 1)
predictors <- rast('Ant_ENM/data/predictor_stack_soilTemp_V2.tif')

## Observations ------------------------------------------
sporadic <- read.csv('Ant_ENM/data/sporadic_combined.csv') %>% 
   filter(species == species_choice) %>% 
   dplyr::select(x, y)

occs <- sporadic %>% 
   vect(geom = c('x', 'y'), crs = crs(km_proj)) %>% 
   thin_spatial(., dist_meters = thin_dist, seed = seed)

# unseen_records_vect <- vect('Ant_ENM/data/exhaustive_combined.shp') %>%
#       filter(species == species_choice) 
# 
# unseen_records <- unseen_records_vect %>%
#       as.data.frame(geom = "XY") %>%
#       dplyr::select(x, y) 

occs_pred <- terra::extract(predictors, occs, ID = F)
occs <- cbind(as.data.frame(occs, geom = 'xy'), occs_pred)
bg_bias_pred <- terra::extract(predictors, bg_bias, ID = F)
bg_bias <- cbind(bg_bias, bg_bias_pred) 

gc()

# Background points
set.seed(seed)         

print(paste("Number of occurrence points:", nrow(occs)))
print(paste("Number of background points:", nrow(bg_bias)))

e.mx <- ENMevaluate(occs = occs, bg = bg_bias,
                    algorithm = 'maxent.jar', partitions = 'randomkfold', partition.settings = list(kfolds = 10),
                    tune.args = list(fc = c("L", "Q", "LQ", "H", "QH", "LQH"), rm = seq(1, 10, 0.5)),
                    parallel = T, numCores = n_cores,
                    raster.preds = F,
                    # The following settings are crucial, as otherwise GBs of files will be
                    # written on HPC tmp directory 
                    other.settings = list(path = 'Ant_ENM/tmp_files',
                                          other.args = list(pictures = F, 
                                                            outputdirectory = 'Ant_ENM/tmp_files',
                                                            writeclampgrid = F,
                                                            writemess = F,
                                                            plots = F,
                                                            outputgrids = F,
                                                            visible = F)))
print("Maxent model done")

# Model selection
res <- eval.results(e.mx)

# Using or.100p, CBI and AICc stepwise
opt.mult.step <- res %>%
   dplyr::filter(or.10p.avg == min(or.10p.avg)) %>%
   dplyr::filter(auc.val.avg == max(auc.val.avg)) %>%
   dplyr::filter(AICc == min(AICc))  # Akaike Information Criterion corrected for small sample size

print(opt.mult.step)

if(NROW(opt.mult.step) > 1){
   opt.mult.step <- opt.mult.step[1, ]
}
best_model <- eval.models(e.mx)[[opt.mult.step$tune.args]]

saveRDS(best_model, paste0("Ant_ENM/model_out_V2/hinge/", gsub(" ", "_", species_choice), '_thin', thin_dist, '_All_30m_seed_', seed, '_', n_background, ".RDS"))
saveRDS(e.mx, paste0("Ant_ENM/model_out_V2/hinge/ENMeval_", gsub(" ", "_", species_choice), '_thin', thin_dist, '_All_30m_seed_', seed, '_', n_background, ".RDS"))

var_importance <- data.frame(best_model@results[grep("permutation.importance", rownames(best_model@results)),])
names(var_importance) <- "perm_imp"
print(arrange(var_importance, desc(perm_imp)))
write.csv(var_importance, paste0("Ant_ENM/model_out_V2/hinge/PermVarImp_", gsub(" ", "_", species_choice), '_thin', thin_dist, '_All_30m_seed_', seed, '_', n_background, ".csv"))

labels <- data.frame(original = c("current_perc09_total_rain_coldest",
                                  "current_perc09_total_rain_hottest",
                                  "current_dry_duration_09perc",
                                  "northness", "eastness", "hillshade", "slope",
                                  "forest_PC1", "forest_PC2",
                                  "SBIO3_Isothermality",
                                  "SBIO4_Temperature_Seasonality",
                                  "SBIO11_Mean_Temperature_of_Coldest_Quarter",
                                  "SBIO8_Mean_Temperature_of_Wettest_Quarter",
                                  "SBIO9_Mean_Temperature_of_Driest_Quarter"),
                     new = c("Total rainfall of coldest quarter",
                             "Total rainfall of hottest quarter",
                             "Longest annual dry spell duration",
                             "Northness", "Eastness", "Hillshade", "Slope",
                             "Forest PCA axis 1",
                             "Forest PCA axis 2",
                             "Soil temperature: isothermality",
                             "Soil temperature: seasonality",
                             "Soil temperature: coldest quarter",
                             "Soil temperature: wettest quarter",
                             "Soil temperature: driest quarter"))

pdf(paste0("Ant_ENM/figures_V2/hinge/effectsPartial_", gsub(" ", "_", species_choice), '_thin', thin_dist, '_All_30m_seed_', seed, '_', n_background, ".pdf"), width = 14, height = 14)
par(mfrow = c(1, 1))
plot_maxent_effects(best_model, rename_tab = labels, type = 'partial')
dev.off()

pdf(paste0("Ant_ENM/figures_V2/hinge/effectsMarginal_", gsub(" ", "_", species_choice), '_thin', thin_dist, '_All_30m_seed_', seed, '_', n_background, ".pdf"), width = 14, height = 14)
par(mfrow = c(1, 1))
plot_maxent_effects(best_model, rename_tab = labels, type = 'marginal')
dev.off()

predictors_fine <- terra::aggregate(predictors, fact = 5, na.rm = TRUE)
suitability_preds_fine <- predict(best_model, predictors_fine, wopt = list(steps = 100, datatype = "FLT4S"))

print('Raster prediction done')

pdf(paste0('Ant_ENM/figures_V2/hinge/PredsFine_', gsub(" ", "_", species_choice), '_thin', thin_dist, '_seed', seed, '_', n_background, '.pdf'),
    width = 8, height = 8)
plot(suitability_preds_fine)
dev.off()

FE_managed <- vect('Ant_ENM/data/Forestry_England_managed_forest.shp') %>%
   terra::project(crs(km_proj))

new_forest <- FE_managed %>%
   filter(extent == 'The Open Forest') %>%
   fillHoles()

ennerdale <- FE_managed %>%
   filter(extent == 'Ennerdale') %>%
   fillHoles()

cropton <- FE_managed %>%
   filter(extent == 'Cropton') %>%
   fillHoles()

new_forest_suit_maxent <- suitability_preds_fine %>%
   crop(new_forest) %>%
   mask(new_forest)

ennerdale_suit_maxent <- suitability_preds_fine %>%
   crop(ennerdale) %>%
   mask(ennerdale)

cropton_suit_maxent <- suitability_preds_fine %>%
   crop(cropton) %>%
   mask(cropton)

new_forest_maxent <- ggplot() +
   geom_spatraster(data = new_forest_suit_maxent) +
   geom_spatvector(data = new_forest, fill = 'transparent', col = 'red') +
   theme_minimal() +
   ggtitle('New forest') +
   scale_fill_viridis(na.value = 'transparent', name = 'Suitability')

cropton_maxent <- ggplot() +
   geom_spatraster(data = cropton_suit_maxent) +
   geom_spatvector(data = cropton, fill = 'transparent', col = 'red') +
   theme_minimal() +
   ggtitle('Cropton') +
   scale_fill_viridis(na.value = 'transparent', name = 'Suitability')

ennerdale_maxent <- ggplot() +
   geom_spatraster(data = ennerdale_suit_maxent) +
   geom_spatvector(data = ennerdale, fill = 'transparent', col = 'red') +
   theme_minimal() +
   ggtitle('Ennerdale') +
   scale_fill_viridis(na.value = 'transparent', name = 'Suitability')

combined_maxent <- ggpubr::ggarrange(new_forest_maxent, cropton_maxent, ennerdale_maxent,
                                     common.legend = T, ncol = 3, nrow = 1, legend = 'bottom')

pdf(paste0('Ant_ENM/figures_V2/hinge/FE_examples_', gsub(' ', '_', species_choice), '_thin', thin_dist, '_seed', seed, '_', n_background, '.pdf'),
    width = 8, height = 6)
plot(combined_maxent)
dev.off()

