# HEADER --------------------------------------------
#
# Author: Joris Wiethase
# Email: j.wiethase@gmail.com
# 
# Script Description:  
# Prepare raster files so that they match the Google Earth Engine background layer, in the web app


library(terra)
library(tidyverse)

file_list <- c('maxTransDist_2km/Formica_lugubris_pointBuff_0.05_ON_Thresh0.5_SNO_Thresh0.5_transGradient_FE_2km.tif',
               'maxTransDist_5km/Formica_lugubris_pointBuff_0.05_ON_Thresh0.5_SNO_Thresh0.5_transGradient_FE_5km.tif',
               'Formica_lugubris_pointBuff_0.05_ON_Thresh0.5_SNO_Thresh0.5_disp_gradient_100m.tif',
               'Formica_lugubris_pointBuff_0.05_ON_Thresh0.5_SNO_Thresh0.5_ON_patches_mask.tif',
               'maxTransDist_2km/Formica_rufa_pointBuff_0.05_ON_Thresh0.5_SNO_Thresh0.5_transGradient_FE_2km.tif',
               'maxTransDist_5km/Formica_rufa_pointBuff_0.05_ON_Thresh0.5_SNO_Thresh0.5_transGradient_FE_5km.tif',
               'Formica_rufa_pointBuff_0.05_ON_Thresh0.5_SNO_Thresh0.5_disp_gradient_100m.tif',
               'Formica_rufa_pointBuff_0.05_ON_Thresh0.5_SNO_Thresh0.5_ON_patches_mask.tif')

dir.create('model_out_patches/for_GEE', showWarnings = F)

for(i in file_list){
      name <- gsub('\\.tif$', '', basename(i))
      img <- rast(paste0('model_out_patches/Formica_', str_split(name, "_")[[1]][2], '/', i)) 
      img <- img %>% 
            project(crs('EPSG:27700'))
      writeRaster(img, paste0('model_out_patches/for_GEE/', gsub('\\.', '', name), '_27700.tif'), overwrite = TRUE) 
      # Once exported add to GEE as image, alignment will be okay
}

