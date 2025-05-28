# HEADER --------------------------------------------
#
# Author: Joris Wiethase
# Email: j.wiethase@gmail.com
# 
# Script Description:  
# Create finak figures for the report


library(terra)
library(tidyterra)
library(tidyverse)
library(viridis)
library(ggpubr)
source('source/misc_functions.R')
theme_set(theme_bw())

# Load data ---------------------------------------
model_rufa <- readRDS('model_out/Formica_rufa_thin0_All_30m_seed_42_20000.RDS')
model_lugubris <- readRDS('model_out/Formica_lugubris_thin1000_All_30m_seed_44_20000.RDS')

var_imp_rufa <- read.csv('model_out/PermVarImp_Formica_rufa_thin0_All_30m_seed_42_20000.csv')
var_imp_lugubris <- read.csv('model_out/PermVarImp_Formica_lugubris_thin1000_All_30m_seed_44_20000.csv')

preds_rufa <- rast('model_out/Formica_rufa.tif')
preds_lugubris <- rast('model_out/Formica_lugubris.tif')

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
                             # "Lowest temperature of coldest quarter",
                             "Longest annual dry spell duration",  
                             "Northness", "Eastness", "Hillshade", "Slope",  
                             "Forest PCA axis 1", 
                             "Forest PCA axis 2",
                             # "Distance to forest patch",
                             "Soil temperature: isothermality",
                             "Soil temperature: seasonality",
                             "Soil temperature: coldest quarter",
                             "Soil temperature: wettest quarter",
                             "Soil temperature: driest quarter"))
replacements <- setNames(labels$new, paste0(labels$original, '.permutation.importance'))


FE_managed <- vect('spatial_other/Forestry_England_managed_forest.shp') %>% 
   terra::project(crs(km_proj))

# Change labels
var_imp_rufa <- var_imp_rufa %>%
      mutate(
            X = recode(X, !!!replacements),
            X = fct_reorder(X, perm_imp, .fun = max, .desc = FALSE)
      )

var_imp_lugubris <- var_imp_lugubris %>%
      mutate(
            X = recode(X, !!!replacements),
            X = fct_reorder(X, perm_imp, .fun = max, .desc = FALSE)
      )

# Figure 2  ---------------------------------------
var_plot_rufa <- ggplot(var_imp_rufa, aes(x = perm_imp, y = X)) +
      geom_col() +
      labs(
            x = 'Permutated variable importance [%]',
            y = NULL,
            title = "Formica rufa"
      ) +
      theme(plot.title = element_text(hjust = 0.5))

map_rufa <- ggplot() +
      geom_spatraster(data = preds_rufa) +
      scale_fill_terrain_c(
            na.value = "transparent",
            name     = 'Suitability'
      ) +
      theme(plot.margin = unit(c(1.5, 0, 1.5, 0), "lines"))

var_plot_lugubris <- ggplot(var_imp_lugubris, aes(x = perm_imp, y = X)) +
      geom_col() +
      labs(
            x = 'Permutated variable importance [%]',
            y = NULL,
            title = "Formica lugubris"
      ) +
      theme(plot.title = element_text(hjust = 0.5))

map_lugubris <- ggplot() +
      geom_spatraster(data = preds_lugubris) +
      scale_fill_terrain_c(
            na.value = "transparent",
            name     = 'Suitability'
      ) +
      theme(plot.margin = unit(c(1.5, 0, 1.5, 0), "lines"))

rufa_combined <- ggarrange(var_plot_rufa, map_rufa, nrow = 1,
                           widths = c(0.7, 1))
lugubris_combined <- ggarrange(var_plot_lugubris, map_lugubris, nrow = 1,
                               widths = c(0.7, 1))

fig_2 <- ggarrange(
      lugubris_combined, 
      rufa_combined,
      labels = c("A)", "B)"),
      nrow = 2
)

ggsave(
      filename = 'report_figures/fig_2.jpg',
      plot = fig_2,
      width = 22, height = 20, units = "cm", dpi = 300
)


# Figure 3 & 4 ---------------------------------------
fig_3 <- plot_maxent_effects(model_lugubris, rename_tab = labels, type = 'partial')
fig_4 <- plot_maxent_effects(model_rufa, rename_tab = labels, type = 'partial')

ggsave(
   filename = 'report_figures/fig_3_lugubris.jpg',
   plot = fig_3,
   width = 25, height = 25, units = "cm", dpi = 300
)

ggsave(
   filename = 'report_figures/fig_4_rufa.jpg',
   plot = fig_4,
   width = 25, height = 25, units = "cm", dpi = 300
)


# Figure 5 ---------------------------------------
new_forest <- FE_managed %>% 
   filter(extent == "The Open Forest") %>% 
   fillHoles

ennerdale <- FE_managed %>% 
   filter(extent == "Ennerdale") %>% 
   fillHoles

cropton <- FE_managed %>% 
   filter(extent == "Cropton") %>% 
   fillHoles

for(i in c("Formica rufa", "Formica lugubris")){
   if(i == "Formica rufa"){
      maxent_result = preds_rufa
   } else {
      maxent_result = preds_lugubris
   }
   
   new_forest_suit_maxent <- maxent_result %>%
      crop(new_forest) %>%
      mask(new_forest)
   
   ennerdale_suit_maxent <- maxent_result %>%
      crop(ennerdale) %>%
      mask(ennerdale)
   
   cropton_suit_maxent <- maxent_result %>%
      crop(cropton) %>%
      mask(cropton) 
   
   new_forest_maxent <- ggplot() +
      geom_spatraster(data = new_forest_suit_maxent) +
      geom_spatvector(data = new_forest, fill = "transparent", col = "red") +
      theme_minimal() +
      ggtitle("New forest") +
      scale_fill_viridis(na.value = "transparent", name = "Suitability") +
      theme(plot.margin = unit(c(1.5, 0, 0, 0), "lines"))
   
   cropton_maxent <- ggplot() +
      geom_spatraster(data = cropton_suit_maxent) +
      geom_spatvector(data = cropton, fill = "transparent", col = "red") +
      theme_minimal() +
      ggtitle("Cropton") +
      scale_fill_viridis(na.value = "transparent", name = "Suitability") +
      theme(plot.margin = unit(c(1.5, 0, 0, 0), "lines"))
   
   ennerdale_maxent <- ggplot() +
      geom_spatraster(data = ennerdale_suit_maxent) +
      geom_spatvector(data = ennerdale, fill = "transparent", col = "red") +
      theme_minimal() +
      ggtitle("Ennerdale") +
      scale_fill_viridis(na.value = "transparent", name = "Suitability") +
      theme(plot.margin = unit(c(1.5, 0, 0, 0), "lines"))
   
   if(i == 'Formica lugubris'){
      combined_maxent <- ggpubr::ggarrange(new_forest_maxent, cropton_maxent, ennerdale_maxent,
                                           common.legend = T, ncol = 3, nrow = 1, legend = "none")
   } else {
      combined_maxent <- ggpubr::ggarrange(new_forest_maxent, cropton_maxent, ennerdale_maxent,
                                           common.legend = T, ncol = 3, nrow = 1, legend = "bottom")
   }
   
   assign(paste0('combined_maxent_', gsub(' ', '_', i)), combined_maxent, envir = .GlobalEnv)
}

# Wrap each species row with a top title
panel_a <- ggpubr::annotate_figure(
   combined_maxent_Formica_lugubris,
   top = ggpubr::text_grob("Formica lugubris", face = "italic", size = 12)
)

panel_b <- ggpubr::annotate_figure(
   combined_maxent_Formica_rufa,
   top = ggpubr::text_grob("Formica rufa", face = "italic", size = 12)
)

# Combine both panels vertically and add A) and B) labels
fig_5 <- ggpubr::ggarrange(
   panel_a,
   panel_b,
   nrow = 2,
   labels = c("A)", "B)"),
   label.x = 0
)

ggsave(
   filename = 'report_figures/fig_5.jpg',
   plot = fig_5,
   width = 20, height = 15, units = "cm", dpi = 300
)







