# HEADER --------------------------------------------
#
# Author: Joris Wiethase
# Email: j.wiethase@gmail.com
# 
# Script Description:  
# Make Maxent predictions on full 30m resolution


options(java.parameters = "-Xmx128g") 
library(terra)
library(tidyverse)
library(patchwork)
source('Ant_ENM/source/misc_functions.R')

args <- commandArgs(trailingOnly=TRUE)
job <- as.integer(args[1])
species_list <- c("rufa", "lugubris")
species <- species_list[job]

# Load Covariates ------------------------------------------------------
predictors <- rast('Ant_ENM/data/predictor_stack_soilTemp_V2.tif')

# Species Loop ---------------------------------------------------------
if(species == 'rufa'){
      model <- readRDS('Ant_ENM/model_out_V2/hinge/Formica_rufa_thin0_All_30m_seed_42_20000.RDS')
}
if(species == 'lugubris'){
      model <- readRDS('Ant_ENM/model_out_V2/hinge/Formica_lugubris_thin1000_All_30m_seed_44_20000.RDS')
}

suitability_rast <- predict(model, predictors, wopt = list(steps = 250, datatype = "FLT4S"), args = c("outputformat=cloglog"))

print(suitability_rast)
print('Raster prediction done')

writeRaster(suitability_rast,
            filename = paste0('Ant_ENM/model_out_V2/Formica_', species, '.tif'), overwrite = T)

