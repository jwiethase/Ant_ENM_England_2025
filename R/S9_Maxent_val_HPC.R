# HEADER --------------------------------------------
#
# Author: Joris Wiethase
# Email: j.wiethase@gmail.com
# 
# Script Description:  
# Evaluate Maxent model fit using null models and unobserved data


options(java.parameters = '-Xmx256g') 
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
library(enmSdmX)
library(viridis)

source('Ant_ENM/source/misc_functions.R')
n_cores = 32

args <- commandArgs(trailingOnly=TRUE)
job <- as.integer(args[1])

n_background_choices = c(10000, 20000, 30000)
thin_choices = c(0, 100, 1000)
seed_choices = c(42, 43, 44)
model_types = c('no_hinge', 'hinge')
species_choices = c('Formica rufa', 'Formica lugubris')

mult_combs <- crossing(species_choices, n_background_choices, thin_choices, seed_choices, model_types)
comb_values <- mult_combs[job, ]
print(comb_values)

species_choice = comb_values$species_choices
thin_dist = comb_values$thin_choices 
seed = comb_values$seed_choices 
n_background = comb_values$n_background_choices 
model_type = comb_values$model_types 

# LOAD DATA FILES ------------------------------------------
## Covariates ------------------------------------------
best_model <- readRDS(paste0('Ant_ENM/model_out_V2/', model_type, '/', gsub(' ', '_', species_choice), '_thin', thin_dist, '_All_30m_seed_', seed, '_', n_background, '.RDS'))
e.mx <- readRDS(paste0('Ant_ENM/model_out_V2/', model_type, '/ENMeval_', gsub(' ', '_', species_choice), '_thin', thin_dist, '_All_30m_seed_', seed, '_', n_background, '.RDS'))

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

res <- eval.results(e.mx)
opt.mult.step <- res %>%
  dplyr::filter(or.10p.avg == min(or.10p.avg)) %>%
  dplyr::filter(auc.val.avg == max(auc.val.avg)) %>%
  dplyr::filter(AICc == min(AICc))

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

outfile <- sprintf(
  "Ant_ENM/figures_V2/%s/NULL_mod_performance_%s_thin%s_seed%s_%s.pdf",
  model_type,
  gsub(" ", "_", species_choice),
  thin_dist,
  seed,
  n_background
)

save_null_histogram <- function(mod.null, outfile, width = 8, height = 15) {
  pdf(outfile, width = width, height = height)
  on.exit(dev.off())                      
  
  stats_try <- c("or.10p", "auc.diff", "auc.val", "cbi.val")
  
  ok <- tryCatch({
    evalplot.nulls(mod.null, stats = stats_try, plot.type = "histogram")
    TRUE
  }, error = function(e) {
    message("cbi.val failed → retrying without it\n", e$message)
    FALSE
  })
  if(ok){print(evalplot.nulls(mod.null, stats = stats_try, plot.type = "histogram"))}
  if (!ok) {
    print(evalplot.nulls(mod.null,
                   stats = stats_try[stats_try != "cbi.val"],
                   plot.type = "histogram"))
  }
}

save_null_histogram(mod.null, outfile)
# 
# var_importance <- data.frame(best_model@results[grep('permutation.importance', rownames(best_model@results)),])
# names(var_importance) <- 'perm_imp'
# print(arrange(var_importance, desc(perm_imp)))
# 
# write.csv(var_importance, paste0('Ant_ENM/model_out_V2/', model_type, '/PermVarImp_', gsub(' ', '_', species_choice), '_thin', thin_dist, '_All_30m_seed_', seed, '_', n_background, '.csv'))
# 
# val_bg_bias <- read.csv(paste0('Ant_ENM/data/val_bg_bias_', gsub(' ', '_', species_choice), '_seed', seed, '_n', n_background, '_thin', thin_dist, '.csv'), row.names = 1)
# 
# predictors <- rast('Ant_ENM/data/predictor_stack_soilTemp_V2.tif')
# 
# ## Observations ------------------------------------------
# unseen_records_vect <- vect('Ant_ENM/data/exhaustive_combined.shp') %>%
#       filter(species == species_choice)
# 
# unseen_records <- unseen_records_vect %>%
#       as.data.frame(geom = 'XY') %>%
#       dplyr::select(x, y)
# gc()
# 
# # How well do these models perform against the holdout occurrence samples?
# unseen_presence_env <- terra::extract(predictors, unseen_records, ID = F)
# 
# # Get presence and absence predictions using unseen data,
# set.seed(seed+100)
# unseen_pred <- predictMaxEnt(best_model, unseen_presence_env, type = 'cloglog')
# 
# avtest <- data.frame(terra::extract(predictors, val_bg_bias))
# random_absence_p <- predictMaxEnt(best_model, avtest, type = 'cloglog')
# e_unseen <- evaluate(p = unseen_pred, a = random_absence_p)
# 
# pdf(paste0('Ant_ENM/figures_V2/', model_type, '/Mod_performance_', gsub(' ', '_', species_choice), '_thin', thin_dist, '_seed', seed, '_', n_background, '.pdf'),
#     width = 8, height = 8)
# par(mfrow=c(2, 2))
# hist(unseen_pred, main = 'Raw extracted suitability', xlab = 'Extracted suitability at unseen presences')
# boxplot(unseen_pred, main = paste0('Raw extracted median: ', round(median(unseen_pred, na.rm = T), digits = 2)))
# plot(e_unseen, 'ROC')
# boyce_test <- ecospat::ecospat.boyce(fit = random_absence_p, obs = unseen_pred[!is.na(unseen_pred)])
# title(paste0('Boyce test cor: ', boyce_test$cor))
# par(mfrow = c(1, 1))
# dev.off()
# 
# print('Finished val figures')
# 
# 
