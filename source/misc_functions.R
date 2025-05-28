get_OR.10p <- function(suit_raster, pres_df, perc = 0.1){
      obs <- terra::extract(suit_raster, cbind(pres_df$x, pres_df$y)) %>% 
            drop_na()
      threshold_10th_percentile <- quantile(values(suit_raster), probs = perc, na.rm = TRUE)
      omission_rate <- mean(obs < threshold_10th_percentile, na.rm = TRUE)
      omission_rate
}

crop_and_export <- function(filepath, dest_folder){
      target_crs <- "+proj=longlat +datum=WGS84 +lon_wrap=180"
      
      extent_1 <- ext(350, 360, 45, 65) 
      extent_2 <- ext(-100, 5, 45, 65)
      
      img_1 <- rast(filepath) %>% 
            crop(extent_1) 
      ext(img_1) <- c(-10, 0, 45, 65)
      
      img_2 <- rast(filepath) %>% 
            crop(extent_2) 
      
      img <- merge(img_1, img_2) %>% 
            crop(ROI) %>% 
            mask(ROI) %>% 
            project(crs(km_proj))

      writeRaster(img,
                  paste0(dest_folder, '/',
                         basename(filepath),
                         ".tif"),
                  overwrite = T)
}

km_proj <- "+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +units=km +no_defs"

determine_accuracy <- function(grid_ref) {
      accuracy_map <- c('2' = 10000, '4' = 1000, '6' = 100, '8' = 10, '10' = 1)
      num_part <- gsub("[^0-9]", "", grid_ref)
      num_length <- as.character(nchar(num_part))
      return(accuracy_map[num_length])
}

read_and_select <- function(df, cols, type = "csv"){
      require(tidyverse)
      if(type == "csv"){
            df <- read.csv(df) %>% 
                  dplyr::select(cols)
            return(df)
      }
      if(type == "xls"){
            require(readxl)
            df <- read_excel(df) %>% 
                  dplyr::select(cols)
            return(df)
      }
}

thin_spatial <- function(points, dist_meters, seed = NULL){
      if(!is.null(seed)){set.seed(seed)}
      shuffle_order <- sample(NROW(points))
      points_shuffled <- points[shuffle_order, ]
      
      keep_indices <- rep(TRUE, NROW(points_shuffled))
      
      for (i in 1:NROW(points_shuffled)) {
            if (keep_indices[i]) {
                  # Calculate distances from the current point to all others
                  distances <- terra::distance(points_shuffled[i, ], points_shuffled)
                  
                  # Mark points within distance for removal, except the current one
                  within_dist <- distances <= dist_meters
                  keep_indices[within_dist] <- FALSE
                  keep_indices[i] <- TRUE  # Ensure the current point is kept
            }
      }
      points_thinned <- points_shuffled[keep_indices, ]
      
      cat(paste0("Spatial thinning removed ",  NROW(points) - NROW(points_thinned), " points"))
      
      return(points_shuffled[keep_indices, ])
}

group_thin_spatial <- function(points, dist_meters, seed = NULL, group_var, crs_spec = NULL){
      if("SpatVector" %in% class(points)){
            points_df = as.data.frame(points, geom = 'XY')
      } else {
            points_df = points
      }
      
      if(is.null(crs)){
            crs_p = crs(points)
      } else {
            crs_p = crs_spec
      }
      
      points_thinned_list <- points_df %>%
            group_by(get(group_var)) %>% 
            group_modify(~ {
                  group_points <- vect(data.frame(.x), geom=c("x", "y"), crs = crs(crs_p))
                  thinned_group_points <- thin_spatial(group_points, dist_meters, seed)
                  as.data.frame(thinned_group_points, geom = 'XY')
            }) %>% 
            ungroup()
      
      return(bind_rows(points_thinned_list))
}

rsq <- function (x, y) cor(x, y) ^ 2

normalise_raster <- function(spatRaster){
      nx <- minmax(spatRaster)
      rn <- (spatRaster - nx[1,]) / (nx[2,] - nx[1,])
      return(rn)
} 

prepareMGCVsplines <- function(df, colname, n_knots = 3, smooth = 'tp'){
      #' Function based on discussions in: https://groups.google.com/g/r-inla-discussion-group/c/CiA4l9zhCMw
      #' See ?smooth.terms for a list of available spline functions
      #' fx=FALSE: Penalized regression splines
      require(mgcv)
            expr_str <- paste0("smoothCon(s(", colname, ", bs = '", smooth, "', k = ", n_knots, ", fx = FALSE), data = df, absorb.cons = TRUE)[[1]]$X")
            base_functions <- eval(parse(text = expr_str))
            
            num_columns <- if (n_knots > 2) { n_knots - 1 } else { n_knots }
            
            for(i in 1:num_columns){
                  df[, paste0(colname, "_spline", i)] <- base_functions[, i]
            }
      return(df)
}

range01 <- function(x){(x - min(x, na.rm = T))/(max(x, na.rm = T) - min(x, na.rm = T))}

calc_quantiles <- function(x, probs = 0.9) {
      return(stats::quantile(x, probs = probs, na.rm = TRUE))
}

calculate_cover <- function(x, threshold = 2) {
      valid_pixels <- !is.na(x)
      cover <- sum(x[valid_pixels] > threshold, na.rm = TRUE) / sum(valid_pixels)
      return(cover)
}

mean_fun <- function(x) mean(x, na.rm = TRUE)
sd_fun <- function(x) sd(x, na.rm = TRUE)

make_formula_terms <- function(rasterstack, name_leading, n_splines){
      extracted_names <- gsub(paste0("^(", name_leading, "\\d).*$"), "\\1", names(rasterstack))
      unique_vars <- unique(grep(paste0("^", name_leading, "[0-9].*"), extracted_names, value = TRUE))
      unique_vars_num <- as.numeric(gsub("\\D", "", unique_vars))
      spline_terms <- paste0(name_leading, 
                             rep(unique_vars_num, each = n_splines), "_spline", rep(1:n_splines, times = length(unique_vars)), 
                             "(main = ", deparse(substitute(rasterstack)), "$", name_leading, "", rep(unique_vars_num, each = n_splines), "_spline", rep(1:n_splines, times = length(unique_vars)), 
                             ", model = 'linear')")
      return(spline_terms)
}

disagg_to_target <- function(coarse, fine, resample = FALSE, method_disagg = "bilinear"){
      factor <- round(res(coarse)[1]/res(fine)[1])
      print(paste0("Disaggregating by factor of ", factor, "..."))
      out_rast <- terra::disagg(coarse, fact = factor, method = method_disagg)
      if(resample){
            out_rast <- out_rast %>% terra::resample(fine, threads = T, method = "bilinear")  
      }
      return(out_rast)
}

custom_scientific <- function(x) {
      formatted <- formatC(x, format = "e", digits = 1) %>%
            gsub("e\\+0*", "e", .) %>%
            gsub("e\\-", "e-", .)
      formatted <- gsub("\\.0", "", formatted)
      return(formatted)
}

rast_yeo_johnson <- function(rasterlayer, plot = FALSE){
      require(bestNormalize)
      yj_obj <- bestNormalize::yeojohnson(values(rasterlayer), standardize = T)
      transformed_lyr <- rasterlayer
      values(transformed_lyr) <- predict(yj_obj)
      if(plot){
            par(mfrow = c(2, 1))
            hist(values(rasterlayer, na.rm = T), main = "Original density distr.")
            hist(values(transformed_lyr, na.rm = T), main = "Transformed density distr.")
            par(mfrow = c(1, 1))
      }
      return(transformed_lyr)
}

scale_spline_pairs <- function(r, spline_pair) {
      vals <- c(values(r[[spline_pair[1]]]), values(r[[spline_pair[2]]]))
      scaled_vals <- scale(vals)
      half <- length(scaled_vals) / 2
      values(r[[spline_pair[1]]]) <- scaled_vals[1:half]
      values(r[[spline_pair[2]]]) <- scaled_vals[(half + 1):length(scaled_vals)]
      return(r)
}

plot_maxent_effects <- function(maxent_model, rename_tab = NULL, type = NULL, n_partial = 10){
   require(ggplot2)
   require(ggpubr)
   require(dismo)
   require(enmSdmX)
   
   out_plot_list <- list()
   # var_name = 'eastness'
   for(var_name in colnames(maxent_model@presence)){
      
      df_presence <- maxent_model@presence 
      df_background <- maxent_model@absence
      all_training <- rbind(df_presence, df_background)

      density_presence <- density(df_presence[, var_name], cut = 0)
      density_background <- density(df_background[, var_name], cut = 0)
      
      if(class(maxent_model)[1] == "MaxEnt"){
         pdf(NULL) 
         response_data <- data.frame(response(maxent_model, var = var_name, expand = 0, at = NULL))
         dev.off()  
         
         response_data <- data.frame(
            x = response_data[, 1],
            y = response_data[, 2]
         )
      }
      
      if(class(maxent_model)[1] == "MaxEnt_model"){
         
         var_min <- min(c(min(df_presence[, var_name]), min(df_background[, var_name])))
         var_max <- max(c(max(df_presence[, var_name]), max(df_background[, var_name])))
         var_values <- seq(from = var_min, to = var_max, length.out = 100)
         
         if(type == 'marginal'){
            pred_data <- df_background %>% 
               summarise(across(everything(), median, na.rm = TRUE)) %>% 
               slice(rep(1, 100)) 
            
            pred_data[[var_name]] <- var_values
            
            response_data <- data.frame(x = var_values,
                                        y = predictMaxEnt(maxent_model, pred_data, type = "cloglog"))
         }
         
         if(type == 'partial'){
            n_row <- nrow(df_background)
            
            var_min <- min(df_background[[var_name]]) 
            var_max <- max(df_background[[var_name]]) 
            var_values <- seq(from = var_min,
                     to = var_max,
                     length.out = n_partial)
            
            # Replicate the entire data.frame for each grid value
            mm <- df_background[rep(seq_len(n_row), times = length(var_values)), ]
            
            # Assign the focal var to each block of n_row rows
            mm[[var_name]] <- rep(var_values, each = n_row)
            
            # Predict once on the big matrix, then reshape & average per grid
            p_all <- predictMaxEnt(maxent_model, mm, type = "cloglog")
            
            # Make matrix with n_row rows, one column per var_values
            p_mat <- matrix(p_all, nrow = n_row, byrow = FALSE)
            marginal_y <- colMeans(p_mat, na.rm = TRUE)
            
            response_data <- data.frame(
               x = var_values,
               y = marginal_y
            )
         }
         
         if(type == 'total'){
            pred_data <- data.frame(var_values)
            names(pred_data) <- var_name
            
            for(cov in setdiff(names(all_training), var_name)){
               v.focal = all_training[[var_name]]
               v.non.focal = all_training[, cov]
               
               fm <- lm(v.non.focal ~ v.focal, data = all_training)
               pred_data[[cov]] <- predict(fm, newdata = data.frame(v.focal = var_values))
            }
            
            response_data <- data.frame(x = var_values,
                                        y = predictMaxEnt(maxent_model, pred_data, type = "cloglog"))
         }
      }
      
      max_density <- max(density_presence$y, density_background$y)
      
      # Create new data frames with normalized densities
      density_presence_norm <- data.frame(
         x = density_presence$x,
         y = density_presence$y / max_density
      )
      
      density_background_norm <- data.frame(
         x = density_background$x,
         y = density_background$y / max_density
      )
      
      out_plot <- ggplot() +
         # Background area
         geom_area(
            data = density_background_norm,
            aes(x = x, y = y, fill = "Background"),
            color = "black", alpha = 0.5
         ) +
         # Presence area
         geom_area(
            data = density_presence_norm,
            aes(x = x, y = y, fill = "Presence"),
            color = "black", alpha = 0.5
         ) +
         # Response curve: scaled to match normalized densities
         geom_line(
            data = response_data,
            aes(x = x, y = y), 
            color = "#E41A1C", linewidth = 1.5
         ) +
         # Axes
         scale_y_continuous(
            name = "Normalized Density", 
            limits = c(0, 1),
            sec.axis = sec_axis(
               ~ .,  
               name = "Estimated suitability"
            )
         ) +
         scale_fill_manual(
            values = c('#56B4E9','#E69F00'),
            name = element_blank()
         ) +
         xlab(var_name) +
         theme_bw() +
         theme(
            axis.title.y.right = element_text(color = "#E41A1C"), 
            axis.text.y.right  = element_text(color = "#E41A1C")
         ) 
      
      if(!is.null(rename_tab)){
         out_plot <- out_plot + 
            xlab(rename_tab$new[grep(var_name, rename_tab$original)])
      }
      
      out_plot
      out_plot_list[[var_name]] <- out_plot
   }
   
   combined_plot <- ggpubr::ggarrange(plotlist = out_plot_list, common.legend = TRUE, legend = 'bottom')
   return(combined_plot)
}


