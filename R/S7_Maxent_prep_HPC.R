# HEADER --------------------------------------------
#
# Author: Joris Wiethase
# Email: j.wiethase@gmail.com
# 
# Script Description:  
# Prepare Maxent-specific files: Background and validation points, 

library(terra)
library(raster)
library(tidyverse)
library(tidyterra)
library(data.table)
library(tidyr)
source('Ant_ENM/source/misc_functions.R')

args <- commandArgs(trailingOnly=TRUE)
job <- as.integer(args[1])

species_choices = c("Formica rufa", "Formica lugubris")
n_background_choices = c(10000, 20000, 30000)
seed_choices = c(42, 43, 44)  # Different random seeds for background points
thin_choices = c(0, 100, 1000)

mult_combs <- crossing(species_choices, n_background_choices, thin_choices, seed_choices)
comb_values <- mult_combs[job, ]
print(comb_values)

species_choice = comb_values$species_choices
thin_dist = comb_values$thin_choices 
seed = comb_values$seed_choices 
n_background = comb_values$n_background_choices 

# LOAD DATA FILES ------------------------------------------
# Background points ----
# The effort raster was created as follows, in script S6: 
# Original 10km effort raster --> resample to forest_mask_buff (30m), to keep only those 
# areas where the ant could occur
sporadic <- read.csv('Ant_ENM/data/sporadic_combined.csv') %>%
                  filter(species == species_choice) %>%
                  dplyr::select(x, y)

occs <- sporadic %>%
      vect(geom = c('x', 'y'), crs = crs(km_proj)) %>%
      thin_spatial(., dist_meters = thin_dist, seed = seed) %>%
      as.data.frame(geom = "XY")

effort_rast <- raster('Ant_ENM/data/effort_masked_30m.tif') 

set.seed(seed)  

bg_bias <- dismo::randomPoints(mask = effort_rast, p = occs, n = n_background, prob = TRUE)

write.csv(bg_bias, paste0('Ant_ENM/data/bg_bias_', gsub(" ", "_", species_choice), "_seed", seed, '_n', n_background, '_thin', thin_dist, '.csv'))
print("bg_bias done")

set.seed(seed+100)  
val_bg_bias <- dismo::randomPoints(mask = effort_rast, p = occs, n = n_background, prob = TRUE)

write.csv(val_bg_bias, paste0('Ant_ENM/data/val_bg_bias_', gsub(" ", "_", species_choice), "_seed", seed, '_n', n_background, '_thin', thin_dist, '.csv'))


