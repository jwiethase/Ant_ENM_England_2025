# HEADER --------------------------------------------
#
# Author: Joris Wiethase
# Email: j.wiethase@gmail.com
# 
# Script Description:  
# Extract summary results values for the report


library(tidyverse)
library(terra)
library(landscapemetrics)
source('source/misc_functions.R')

FE_managed <- vect('spatial_other/Forestry_England_managed_forest.shp') %>% 
      project(crs(km_proj))
FE_managed_area <- sum(expanse(FE_managed, unit = "km"))

get_area_proportion <- function(rast, area = FE_managed_area){
      res <- res(rast) 
      cell_area <- res[1] * res[2]
      total_area <- cell_area * sum(!is.na(values(rast)))
      proportion <- total_area/area
      return(proportion)
}

# Proportion of all Forestry England managed land that is defined as 'likely occupied' by each of the 2 species.
ON_rufa <- rast('model_out_patches/Formica_rufa/Formica_rufa_pointBuff_0.05_ON_Thresh0.5_SNO_Thresh0.5_ON_patches_mask.tif') %>% 
      mask(FE_managed)
get_area_proportion(ON_rufa)

ON_lugubris <- rast('model_out_patches/Formica_lugubris/Formica_lugubris_pointBuff_0.05_ON_Thresh0.5_SNO_Thresh0.5_ON_patches_mask.tif') %>% 
      mask(FE_managed)
get_area_proportion(ON_lugubris)

# Proportion of all Forestry England managed land that is defined as 'suitable' for each of the 2 species, assuming a 0.5 suitability threshold
suitable_rufa_0.5 <- rast('model_out/Formica_rufa.tif') %>% 
      clamp(lower = 0.5, values = FALSE) %>% 
      mask(FE_managed)
get_area_proportion(suitable_rufa_0.5)

suitable_lugubris_0.5 <- rast('model_out/Formica_lugubris.tif') %>% 
      clamp(lower = 0.5, values = FALSE) %>% 
      mask(FE_managed)
get_area_proportion(suitable_lugubris_0.5)

# Proportion of all Forestry England managed land that is defined as 'suitable' for each of the 2 species, assuming a 0.75 suitability threshold
suitable_rufa_0.75 <- rast('model_out/Formica_rufa.tif') %>% 
      clamp(lower = 0.75, values = FALSE) %>% 
      mask(FE_managed)
get_area_proportion(suitable_rufa_0.75)

suitable_lugubris_0.75 <- rast('model_out/Formica_lugubris.tif') %>% 
      clamp(lower = 0.75, values = FALSE) %>% 
      mask(FE_managed)
get_area_proportion(suitable_lugubris_0.75)

# Proportion of all Forestry England managed land that is defined as 'suitable' for each of the 2 species, assuming a 0.5 suitability threshold, that are also defined as 'likely occupied' by the matching species.
res_suitable_0.5 <- res(suitable_rufa_0.5) 
cell_area_suitable_0.5 <- res_suitable_0.5[1] * res_suitable_0.5[2]

suitable_rufa_0.5_area <- cell_area_suitable_0.5 * sum(!is.na(values(suitable_rufa_0.5)))
suitable_lugubris_0.5_area <- cell_area_suitable_0.5 * sum(!is.na(values(suitable_lugubris_0.5)))

get_area_proportion(ON_rufa, area = suitable_rufa_0.5_area)
get_area_proportion(ON_lugubris, area = suitable_lugubris_0.5_area)

# Proportion of all Forestry England managed land that is defined as 'suitable' for each of the 2 species, assuming a 0.5 suitability threshold, that is also defined as 'naturally colonisable'.
dispersal_rufa_0.5 <- rast('model_out_patches/Formica_rufa/Formica_rufa_pointBuff_0.05_ON_Thresh0.5_SNO_Thresh0.5_disp_gradient_100m.tif') %>% 
      mask(FE_managed)
get_area_proportion(dispersal_rufa_0.5, area = suitable_rufa_0.5_area)

dispersal_lugubris_0.5 <- rast('model_out_patches/Formica_lugubris/Formica_lugubris_pointBuff_0.05_ON_Thresh0.5_SNO_Thresh0.5_disp_gradient_100m.tif') %>% 
      mask(FE_managed)
get_area_proportion(dispersal_lugubris_0.5, area = suitable_lugubris_0.5_area)

# Proportion of all Forestry England managed land that is defined as 'Likely occupied now' by at least one of the 2 species (this will be very similar to rufa+lugubris for point 1 above, but not the same, 
# because there is a small area where both co-occur)
combined <- ifel(is.na(ON_rufa) & is.na(ON_lugubris), NA, ifel(ON_rufa == 1 | ON_lugubris == 1, 1, NA))
get_area_proportion(combined)

#  Proportion of all Forestry England managed land that is defined as 'suitable' for at least one of the 2 species, assuming a 0.5 suitability threshold, and is neither 'Likely occupied now', nor defined as 
# 'Likely naturally colonised' by either species.
trans_0km_rufa <- rast("model_out_patches/Formica_rufa/maxTransDist_0km/Formica_rufa_pointBuff_0.05_ON_Thresh0.5_SNO_Thresh0.5_transMask_FE_0km.tif")
trans_0km_lugubris <- rast("model_out_patches/Formica_lugubris/maxTransDist_0km/Formica_lugubris_pointBuff_0.05_ON_Thresh0.5_SNO_Thresh0.5_transMask_FE_0km.tif")
combined_trans <- ifel(is.na(trans_0km_rufa) & is.na(trans_0km_lugubris), NA, ifel(trans_0km_rufa == 1 | trans_0km_lugubris == 1, 1, NA))
get_area_proportion(combined_trans)

# Proportion of all Forestry England managed land that is defined as 'suitable' for at least one of the 2 species, assuming a 0.75 suitability threshold, and is neither 'Likely occupied now', nor defined 
# as 'Likely naturally colonised' by either species.
trans_0km_rufa_0.75 <- rast("model_out_patches/Formica_rufa/maxTransDist_0km/Formica_rufa_pointBuff_0.05_ON_Thresh0.5_SNO_Thresh0.75_transMask_FE_0km.tif")
trans_0km_lugubris_0.75 <- rast("model_out_patches/Formica_lugubris/maxTransDist_0km/Formica_lugubris_pointBuff_0.05_ON_Thresh0.5_SNO_Thresh0.75_transMask_FE_0km.tif")
combined_trans_0.75 <- ifel(is.na(trans_0km_rufa_0.75) & is.na(trans_0km_lugubris_0.75), NA, ifel(trans_0km_rufa_0.75 == 1 | trans_0km_lugubris_0.75 == 1, 1, NA))
get_area_proportion(combined_trans_0.75)

# Proportion of all Forestry England managed land that is defined as 'suitable' for each of the 2 species, assuming a 0.75 suitability threshold, that are also defined as 'likely occupied' by the matching species.
res_suitable_0.75 <- res(suitable_rufa_0.75) 
cell_area_suitable_0.75 <- res_suitable_0.75[1] * res_suitable_0.75[2]

suitable_rufa_0.75_area <- cell_area_suitable_0.75 * sum(!is.na(values(suitable_rufa_0.75)))
suitable_lugubris_0.75_area <- cell_area_suitable_0.75 * sum(!is.na(values(suitable_lugubris_0.75)))

get_area_proportion(ON_rufa, area = suitable_rufa_0.75_area)
get_area_proportion(ON_lugubris, area = suitable_lugubris_0.75_area)


#  Proportion of all Forestry England managed land that is defined as 'suitable' for each of the 2 species, assuming a 0.5 suitability threshold, and is neither 'Likely occupied now', nor defined as 
# 'Likely naturally colonised' by either species.
get_area_proportion(trans_0km_rufa)
get_area_proportion(trans_0km_lugubris)


#  Proportion of all Forestry England managed land that is defined as 'suitable' for each of the 2 species, assuming a 0.75 suitability threshold, and is neither 'Likely occupied now', nor defined as 
# 'Likely naturally colonised' by either species.
get_area_proportion(trans_0km_rufa_0.75)
get_area_proportion(trans_0km_lugubris_0.75)
