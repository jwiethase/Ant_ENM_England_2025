options(java.parameters = "-Xmx400g") 
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

n_cores = 32
source('Ant_ENM/source/misc_functions.R')

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

if(exists(paste0("Ant_ENM/model_out/", gsub(" ", "_", species_choice), '_thin', thin_dist, '_All_30m_seed_', seed, '_', n_background, ".RDS"))){
   stop("Model output already exists")
}

# LOAD DATA FILES ------------------------------------------
## Covariates ------------------------------------------
bg_bias <- read.csv(paste0('Ant_ENM/data/bg_bias_', gsub(" ", "_", species_choice), "_seed", seed, '_n', n_background, '_thin', thin_dist, '.csv'), row.names = 1)
covariates_stack <- rast('Ant_ENM/data/full_covariates_stack.tif')

# The resulting dataframe (df) contains only the variables with VIF < 10
keep <- c("current_perc09_total_rain_coldest", 
          "current_perc09_total_rain_hottest", 
          "current_perc01_temp_coldest", 
          "current_dry_duration_09perc",      
          "current_annual_sd_temp",
          "northness", "eastness", "hillshade", "slope", 
          "distance_forest", "forest_PC1", "forest_PC2")

predictors <- raster::subset(raster::stack(covariates_stack), 
                             subset = keep)  
predictors$slope <- log(predictors$slope+1)
predictors$current_perc09_total_rain_coldest <- log(predictors$current_perc09_total_rain_coldest+1)
predictors$current_perc09_total_rain_hottest <- log(predictors$current_perc09_total_rain_hottest+1)
predictors$distance_forest <- log(predictors$distance_forest+1)

print("Predictors done")

## Observations ------------------------------------------
sporadic <- read.csv('Ant_ENM/data/sporadic_combined.csv') %>% 
      filter(species == species_choice) %>% 
      dplyr::select(x, y)

occs <- sporadic %>% 
      vect(geom = c('x', 'y'), crs = crs(km_proj)) %>% 
      thin_spatial(., dist_meters = thin_dist, seed = seed) %>% 
      as.data.frame(geom = "XY")

unseen_records_vect <- vect('Ant_ENM/data/exhaustive_combined.shp') %>%
      filter(species == species_choice) 

unseen_records <- unseen_records_vect %>%
      as.data.frame(geom = "XY") %>%
      dplyr::select(x, y) 
gc()

# Background points
set.seed(seed)         
mem.maxVSize(vsize = 400000)

e.mx <- ENMevaluate(occs = occs, envs = predictors, bg = bg_bias, 
                    algorithm = 'maxent.jar', partitions = 'checkerboard2', partition.settings = list(aggregation.factor = c(333, 333)), 
                    tune.args = list(fc = c("Q", "LQ", "LQP", "LQT", "QH", "LQH"), rm = seq(1, 5, 0.5)),
                    parallel = TRUE, numCores = n_cores)
print("Maxent model done")

# Model selection
res <- eval.results(e.mx)

# Using or.100p, CBI and AICc stepwise
opt.mult.step <- res %>% 
   dplyr::filter(AICc == min(AICc)) %>%  # Akaike Information Criterion corrected for small sample size
   dplyr::filter(or.10p.avg == min(or.10p.avg)) %>% 
   dplyr::filter(auc.val.avg == max(auc.val.avg)) 
  
print(opt.mult.step)

if(NROW(opt.mult.step) > 1){
   opt.mult.step <- opt.mult.step[1, ]
}
best_model <- eval.models(e.mx)[[opt.mult.step$tune.args]]

saveRDS(best_model, paste0("Ant_ENM/model_out/", gsub(" ", "_", species_choice), '_thin', thin_dist, '_All_30m_seed_', seed, '_', n_background, ".RDS"))
saveRDS(e.mx, paste0("Ant_ENM/model_out/ENMeval_", gsub(" ", "_", species_choice), '_thin', thin_dist, '_All_30m_seed_', seed, '_', n_background, ".RDS"))

var_importance <- data.frame(best_model@results[grep("permutation.importance", rownames(best_model@results)),]) 
names(var_importance) <- "perm_imp"
print(arrange(var_importance, desc(perm_imp)))

pdf(paste0("Ant_ENM/figures/effects_", gsub(" ", "_", species_choice), '_thin', thin_dist, '_All_30m_seed_', seed, '_', n_background, ".pdf"), width = 14, height = 14)
par(mfrow = c(1, 1))
plot_maxent_effects(best_model)
dev.off()
