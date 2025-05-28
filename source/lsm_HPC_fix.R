lsm_abbreviations_names_modified <- 
      structure(list(metric = c("area", "cai", "circle", "contig", 
                                "core", "enn", "frac", "gyrate", "ncore", "para", "perim", "shape", 
                                "ai", "area_cv", "area_mn", "area_sd", "ca", "cai_cv", "cai_mn", 
                                "cai_sd", "circle_cv", "circle_mn", "circle_sd", "clumpy", "cohesion", 
                                "contig_cv", "contig_mn", "contig_sd", "core_cv", "core_mn", 
                                "core_sd", "cpland", "dcad", "dcore_cv", "dcore_mn", "dcore_sd", 
                                "division", "ed", "enn_cv", "enn_mn", "enn_sd", "frac_cv", "frac_mn", 
                                "frac_sd", "gyrate_cv", "gyrate_mn", "gyrate_sd", "iji", "lpi", 
                                "lsi", "mesh", "ndca", "nlsi", "np", "pafrac", "para_cv", "para_mn", 
                                "para_sd", "pd", "pladj", "pland", "shape_cv", "shape_mn", "shape_sd", 
                                "split", "tca", "te", "ai", "area_cv", "area_mn", "area_sd", 
                                "cai_cv", "cai_mn", "cai_sd", "circle_cv", "circle_mn", "circle_sd", 
                                "cohesion", "condent", "contag", "contig_cv", "contig_mn", "contig_sd", 
                                "core_cv", "core_mn", "core_sd", "dcad", "dcore_cv", "dcore_mn", 
                                "dcore_sd", "division", "ed", "enn_cv", "enn_mn", "enn_sd", "ent", 
                                "frac_cv", "frac_mn", "frac_sd", "gyrate_cv", "gyrate_mn", "gyrate_sd", 
                                "iji", "joinent", "lpi", "lsi", "mesh", "msidi", "msiei", "mutinf", 
                                "ndca", "np", "pafrac", "para_cv", "para_mn", "para_sd", "pd", 
                                "pladj", "pr", "prd", "relmutinf", "rpr", "shape_cv", "shape_mn", 
                                "shape_sd", "shdi", "shei", "sidi", "siei", "split", "ta", "tca", 
                                "te"), 
                     name = c("patch area", "core area index", "related circumscribing circle", 
                              "contiguity index", "core area", "euclidean nearest neighbor distance", 
                              "fractal dimension index", "radius of gyration", "number of core areas", 
                              "perimeter-area ratio", "patch perimeter", "shape index", "aggregation index", 
                              "patch area", "patch area", "patch area", "total (class) area", 
                              "core area index", "core area index", "core area index", "related circumscribing circle", 
                              "related circumscribing circle", "related circumscribing circle", 
                              "clumpiness index", "patch cohesion index", "contiguity index", 
                              "contiguity index", "contiguity index", "core area", "core area", 
                              "core area", "core area percentage of landscape", "disjunct core area density", 
                              "disjunct core area", "disjunct core area", "disjunct core area", 
                              "division index", "edge density", "euclidean nearest neighbor distance", 
                              "euclidean nearest neighbor distance", "euclidean nearest neighbor distance", 
                              "fractal dimension index", "fractal dimension index", "fractal dimension index", 
                              "radius of gyration", "radius of gyration", "radius of gyration", 
                              "interspersion and juxtaposition index", "largest patch index", 
                              "landscape shape index", "effective mesh size", "number of disjunct core areas", 
                              "normalized landscape shape index", "number of patches", "perimeter-area fractal dimension", 
                              "perimeter-area ratio", "perimeter-area ratio", "perimeter-area ratio", 
                              "patch density", "percentage of like adjacencies", "percentage of landscape", 
                              "shape index", "shape index", "shape index", "splitting index", 
                              "total core area", "total edge", "aggregation index", "patch area", 
                              "patch area", "patch area", "core area index", "core area index", 
                              "core area index", "related circumscribing circle", "related circumscribing circle", 
                              "related circumscribing circle", "patch cohesion index", "conditional entropy", 
                              "connectance", "contiguity index", "contiguity index", "contiguity index", 
                              "core area", "core area", "core area", "disjunct core area density", 
                              "disjunct core area", "disjunct core area", "disjunct core area", 
                              "division index", "edge density", "euclidean nearest neighbor distance", 
                              "euclidean nearest neighbor distance", "euclidean nearest neighbor distance", 
                              "shannon entropy", "fractal dimension index", "fractal dimension index", 
                              "fractal dimension index", "radius of gyration", "radius of gyration", 
                              "radius of gyration", "interspersion and juxtaposition index", 
                              "joint entropy", "largest patch index", "landscape shape index", 
                              "effective mesh size", "modified simpson's diversity index", 
                              "modified simpson's evenness index", "mutual information", "number of disjunct core areas", 
                              "number of patches", "perimeter-area fractal dimension", "perimeter-area ratio", 
                              "perimeter-area ratio", "perimeter-area ratio", "patch density", 
                              "percentage of like adjacencies", "patch richness", "patch richness density", 
                              "relative mutual information", "relative patch richness", "shape index", 
                              "shape index", "shape index", "shannon's diversity index", "shannon's evenness index", 
                              "simpson's diversity index", "simspon's evenness index", "splitting index", 
                              "total area", "total core area", "total edge"), 
                     type = c("area and edge metric", 
                              "core area metric", "shape metric", "shape metric", "core area metric", 
                              "aggregation metric", "shape metric", "area and edge metric", 
                              "core area metric", "shape metric", "area and edge metric", "shape metric", 
                              "aggregation metric", "area and edge metric", "area and edge metric", 
                              "area and edge metric", "area and edge metric", "core area metric", 
                              "core area metric", "core area metric", "shape metric", "shape metric", 
                              "shape metric", "aggregation metric", "aggregation metric", "shape metric", 
                              "shape metric", "shape metric", "core area metric", "core area metric", 
                              "core area metric", "core area metric", "core area metric", "core area metric", 
                              "core area metric", "core area metric", "aggregation metric", 
                              "area and edge metric", "aggregation metric", "aggregation metric", 
                              "aggregation metric", "shape metric", "shape metric", "shape metric", 
                              "area and edge metric", "area and edge metric", "area and edge metric", 
                              "aggregation metric", "area and edge metric", "aggregation metric", 
                              "aggregation metric", "core area metric", "aggregation metric", 
                              "aggregation metric", "shape metric", "shape metric", "shape metric", 
                              "shape metric", "aggregation metric", "aggregation metric", "area and edge metric", 
                              "shape metric", "shape metric", "shape metric", "aggregation metric", 
                              "core area metric", "area and edge metric", "aggregation metric", 
                              "area and edge metric", "area and edge metric", "area and edge metric", 
                              "core area metric", "core area metric", "core area metric", "shape metric", 
                              "shape metric", "shape metric", "aggregation metric", "complexity metric", 
                              "aggregation metric", "shape metric", "shape metric", "shape metric", 
                              "core area metric", "core area metric", "core area metric", "core area metric", 
                              "core area metric", "core area metric", "core area metric", "aggregation metric", 
                              "area and edge metric", "aggregation metric", "aggregation metric", 
                              "aggregation metric", "complexity metric", "shape metric", "shape metric", 
                              "shape metric", "area and edge metric", "area and edge metric", 
                              "area and edge metric", "aggregation metric", "complexity metric", 
                              "area and edge metric", "aggregation metric", "aggregation metric", 
                              "diversity metric", "diversity metric", "complexity metric", 
                              "core area metric", "aggregation metric", "shape metric", "shape metric", 
                              "shape metric", "shape metric", "aggregation metric", "aggregation metric", 
                              "diversity metric", "diversity metric", "complexity metric", 
                              "diversity metric", "shape metric", "shape metric", "shape metric", 
                              "diversity metric", "diversity metric", "diversity metric", "diversity metric", 
                              "aggregation metric", "area and edge metric", "core area metric", 
                              "area and edge metric"), 
                     level = c("patch", "patch", "patch", 
                               "patch", "patch", "patch", "patch", "patch", "patch", "patch", 
                               "patch", "patch", "class", "class", "class", "class", "class", 
                               "class", "class", "class", "class", "class", "class", "class", 
                               "class", "class", "class", "class", "class", "class", "class", 
                               "class", "class", "class", "class", "class", "class", "class", 
                               "class", "class", "class", "class", "class", "class", "class", 
                               "class", "class", "class", "class", "class", "class", "class", 
                               "class", "class", "class", "class", "class", "class", "class", 
                               "class", "class", "class", "class", "class", "class", "class", 
                               "class", "landscape", "landscape", "landscape", "landscape", 
                               "landscape", "landscape", "landscape", "landscape", "landscape", 
                               "landscape", "landscape", "landscape", "landscape", "landscape", 
                               "landscape", "landscape", "landscape", "landscape", "landscape", 
                               "landscape", "landscape", "landscape", "landscape", "landscape", 
                               "landscape", "landscape", "landscape", "landscape", "landscape", 
                               "landscape", "landscape", "landscape", "landscape", "landscape", 
                               "landscape", "landscape", "landscape", "landscape", "landscape", 
                               "landscape", "landscape", "landscape", "landscape", "landscape", 
                               "landscape", "landscape", "landscape", "landscape", "landscape", 
                               "landscape", "landscape", "landscape", "landscape", "landscape", 
                               "landscape", "landscape", "landscape", "landscape", "landscape", 
                               "landscape", "landscape", "landscape", "landscape", "landscape", 
                               "landscape", "landscape"), 
                     function_name = c("lsm_p_area", "lsm_p_cai", 
                                       "lsm_p_circle", "lsm_p_contig", "lsm_p_core", "lsm_p_enn", "lsm_p_frac", 
                                       "lsm_p_gyrate", "lsm_p_ncore", "lsm_p_para", "lsm_p_perim", "lsm_p_shape", 
                                       "lsm_c_ai", "lsm_c_area_cv", "lsm_c_area_mn", "lsm_c_area_sd", 
                                       "lsm_c_ca", "lsm_c_cai_cv", "lsm_c_cai_mn", "lsm_c_cai_sd", "lsm_c_circle_cv", 
                                       "lsm_c_circle_mn", "lsm_c_circle_sd", "lsm_c_clumpy", "lsm_c_cohesion", 
                                       "lsm_c_contig_cv", "lsm_c_contig_mn", "lsm_c_contig_sd", "lsm_c_core_cv", 
                                       "lsm_c_core_mn", "lsm_c_core_sd", "lsm_c_cpland", "lsm_c_dcad", 
                                       "lsm_c_dcore_cv", "lsm_c_dcore_mn", "lsm_c_dcore_sd", "lsm_c_division", 
                                       "lsm_c_ed", "lsm_c_enn_cv", "lsm_c_enn_mn", "lsm_c_enn_sd", "lsm_c_frac_cv", 
                                       "lsm_c_frac_mn", "lsm_c_frac_sd", "lsm_c_gyrate_cv", "lsm_c_gyrate_mn", 
                                       "lsm_c_gyrate_sd", "lsm_c_iji", "lsm_c_lpi", "lsm_c_lsi", "lsm_c_mesh", 
                                       "lsm_c_ndca", "lsm_c_nlsi", "lsm_c_np", "lsm_c_pafrac", "lsm_c_para_cv", 
                                       "lsm_c_para_mn", "lsm_c_para_sd", "lsm_c_pd", "lsm_c_pladj", 
                                       "lsm_c_pland", "lsm_c_shape_cv", "lsm_c_shape_mn", "lsm_c_shape_sd", 
                                       "lsm_c_split", "lsm_c_tca", "lsm_c_te", "lsm_l_ai", "lsm_l_area_cv", 
                                       "lsm_l_area_mn", "lsm_l_area_sd", "lsm_l_cai_cv", "lsm_l_cai_mn", 
                                       "lsm_l_cai_sd", "lsm_l_circle_cv", "lsm_l_circle_mn", "lsm_l_circle_sd", 
                                       "lsm_l_cohesion", "lsm_l_condent", "lsm_l_contag", "lsm_l_contig_cv", 
                                       "lsm_l_contig_mn", "lsm_l_contig_sd", "lsm_l_core_cv", "lsm_l_core_mn", 
                                       "lsm_l_core_sd", "lsm_l_dcad", "lsm_l_dcore_cv", "lsm_l_dcore_mn", 
                                       "lsm_l_dcore_sd", "lsm_l_division", "lsm_l_ed", "lsm_l_enn_cv", 
                                       "lsm_l_enn_mn", "lsm_l_enn_sd", "lsm_l_ent", "lsm_l_frac_cv", 
                                       "lsm_l_frac_mn", "lsm_l_frac_sd", "lsm_l_gyrate_cv", "lsm_l_gyrate_mn", 
                                       "lsm_l_gyrate_sd", "lsm_l_iji", "lsm_l_joinent", "lsm_l_lpi", 
                                       "lsm_l_lsi", "lsm_l_mesh", "lsm_l_msidi", "lsm_l_msiei", "lsm_l_mutinf", 
                                       "lsm_l_ndca", "lsm_l_np", "lsm_l_pafrac", "lsm_l_para_cv", "lsm_l_para_mn", 
                                       "lsm_l_para_sd", "lsm_l_pd", "lsm_l_pladj", "lsm_l_pr", "lsm_l_prd", 
                                       "lsm_l_relmutinf", "lsm_l_rpr", "lsm_l_shape_cv", "lsm_l_shape_mn", 
                                       "lsm_l_shape_sd", "lsm_l_shdi", "lsm_l_shei", "lsm_l_sidi", "lsm_l_siei", 
                                       "lsm_l_split", "lsm_l_ta", "lsm_l_tca", "lsm_l_te")), 
                class = c("tbl_df", "tbl", "data.frame"), row.names = c(NA, -133L))


lsm_abbreviations_names <- lsm_abbreviations_names_modified

list_lsm <- function (level = NULL, metric = NULL, name = NULL, type = NULL, 
                      what = NULL, simplify = FALSE, verbose = TRUE) 
{
      
      lsm_abbreviations_names_modified$metric_new <- vapply(X = strsplit(lsm_abbreviations_names_modified$metric, 
                                                                         split = "_"), FUN = function(x) x[1], FUN.VALUE = character(1))
      if (!is.null(what)) {
            if (any(grepl(pattern = "[-]", x = what))) {
                  stop("Negative strings not allowed for 'what' argument. Please use other arguments for negative subsets.", 
                       call. = FALSE)
            }
            if (!is.null(c(level, metric, name, type))) {
                  level <- NULL
                  metric <- NULL
                  name <- NULL
                  type <- NULL
                  if (verbose) {
                        warning("Only using 'what' argument.", call. = FALSE)
                  }
            }
            if (any(what %in% c("patch", "class", "landscape"))) {
                  level <- what[what %in% c("patch", "class", "landscape")]
                  what <- what[!what %in% c("patch", "class", "landscape")]
            }
            which_rows <- which(lsm_abbreviations_names_modified$function_name %in% 
                                      what | lsm_abbreviations_names_modified$level %in% 
                                      level)
            result <- lsm_abbreviations_names_modified[which_rows, 
            ]
      }
      else {
            if (is.null(level)) {
                  level <- unique(lsm_abbreviations_names_modified$level)
            }
            else {
                  if (any(grepl(pattern = "[-]", x = level))) {
                        if (!all(pattern = grepl("[-]", x = level))) {
                              stop("Mixing of positive and negative strings as subset not allowed for the same argument.")
                        }
                        level_neg <- gsub(pattern = "[-]", replacement = "", 
                                          x = level)
                        level_neg_i <- which(lsm_abbreviations_names_modified$level %in% 
                                                   level_neg)
                        lsm_abbreviations_names_modified <- lsm_abbreviations_names_modified[-level_neg_i, 
                        ]
                        level <- unique(lsm_abbreviations_names_modified$level)
                        level_i <- which(!(level %in% level_neg))
                        level <- level[level_i]
                  }
            }
            if (is.null(metric)) {
                  metric <- unique(lsm_abbreviations_names_modified$metric_new)
            }
            else {
                  if (any(grepl(pattern = "[-]", x = metric))) {
                        if (!all(pattern = grepl("[-]", x = metric))) {
                              stop("Mixing of positive and negative strings as subset not allowed for the same argument.")
                        }
                        metric_neg <- gsub(pattern = "[-]", replacement = "", 
                                           x = metric)
                        metric_neg_i <- which(lsm_abbreviations_names_modified$metric_new %in% 
                                                    metric_neg)
                        lsm_abbreviations_names_modified <- lsm_abbreviations_names_modified[-metric_neg_i, 
                        ]
                        metric <- unique(lsm_abbreviations_names_modified$metric_new)
                        metric_i <- which(!(metric %in% metric_neg))
                        metric <- metric[metric_i]
                  }
            }
            if (is.null(name)) {
                  name <- unique(lsm_abbreviations_names_modified$name)
            }
            else {
                  if (any(grepl(pattern = "[-]", x = name))) {
                        if (!all(pattern = grepl("[-]", x = name))) {
                              stop("Mixing of positive and negative strings as subset not allowed for the same argument.")
                        }
                        name_neg <- gsub(pattern = "[-]", replacement = "", 
                                         x = name)
                        name_neg_i <- which(lsm_abbreviations_names_modified$name %in% 
                                                  name_neg)
                        lsm_abbreviations_names_modified <- lsm_abbreviations_names_modified[-name_neg_i, 
                        ]
                        name <- unique(lsm_abbreviations_names_modified$name)
                        name_i <- which(!(name %in% name_neg))
                        name <- name[name_i]
                  }
            }
            if (is.null(type)) {
                  type <- unique(lsm_abbreviations_names_modified$type)
            }
            else {
                  if (any(grepl(pattern = "[-]", x = type))) {
                        if (!all(pattern = grepl("[-]", x = type))) {
                              stop("Mixing of positive and negative strings as subset not allowed for the same argument.")
                        }
                        type_neg <- gsub(pattern = "[-]", replacement = "", 
                                         x = type)
                        type_neg_i <- which(lsm_abbreviations_names_modified$type %in% 
                                                  type_neg)
                        lsm_abbreviations_names_modified <- lsm_abbreviations_names_modified[-type_neg_i, 
                        ]
                        type <- unique(lsm_abbreviations_names_modified$type)
                        type_i <- which(!(type %in% type_neg))
                        type <- type[type_i]
                  }
            }
            which_rows <- which(lsm_abbreviations_names_modified$level %in% 
                                      level & lsm_abbreviations_names_modified$metric_new %in% 
                                      metric & lsm_abbreviations_names_modified$name %in% 
                                      name & lsm_abbreviations_names_modified$type %in% 
                                      type)
            result <- lsm_abbreviations_names_modified[which_rows, 
            ]
      }
      result <- result[, -6]
      if (nrow(result) == 0) {
            stop("Selected metrics do not exist. Please use 'list_lsm()' to see all available metrics.", 
                 call. = FALSE)
      }
      if (simplify) {
            result <- result$function_name
      }
      return(result)
}

spatialize_lsm <- function (landscape, level = "patch", metric = NULL, name = NULL, 
                            type = NULL, what = NULL, directions = 8, progress = FALSE, 
                            to_disk = getOption("to_disk", default = FALSE), ...) 
{
      landscape <- landscape_as_list(landscape)
      result <- lapply(X = seq_along(landscape), FUN = function(x) {
            if (progress) {
                  cat("\r> Progress nlayers: ", x, "/", length(landscape))
            }
            spatialize_lsm_internal(landscape = landscape[[x]], 
                                    level = level, metric = metric, name = name, type = type, 
                                    what = what, directions = directions, progress = FALSE, 
                                    to_disk = to_disk, ...)
      })
      if (progress) {
            cat("\n")
      }
      names(result) <- paste0("layer_", 1:length(result))
      return(result)
}

spatialize_lsm_internal <- function (landscape, level, metric, name, type, what, directions, 
                                     progress, to_disk, ...) 
{
      metrics <- list_lsm(level = level, metric = metric, name = name, 
                          type = type, what = what, simplify = TRUE, verbose = FALSE)
      number_metrics <- length(metrics)
      if (!all(metrics %in% list_lsm(level = "patch", simplify = TRUE))) {
            stop("'spatialize_lsm()' only takes patch level metrics.", 
                 call. = FALSE)
      }
      crs_input <- terra::crs(landscape)
      landscape_labeled <- get_patches(landscape, class = "all", 
                                       directions = directions, to_disk = to_disk, return_raster = TRUE)[[1]]
      patches_tibble <- terra::as.data.frame(sum(terra::rast(landscape_labeled), 
                                                 na.rm = TRUE), xy = TRUE)
      names(patches_tibble) <- c("x", "y", "id")
      patches_tibble$id <- replace(patches_tibble$id, patches_tibble$id == 
                                         0, NA)
      warning_messages <- character(0)
      result <- withCallingHandlers(expr = {
            lapply(seq_along(metrics), function(x) {
                  if (progress) {
                        cat("\r> Progress metrics: ", x, "/", number_metrics)
                  }
                  fill_value <- calculate_lsm(landscape, what = metrics[[x]], 
                                              directions = directions, progress = FALSE, ...)
                  fill_value <- merge(x = patches_tibble, y = fill_value, 
                                      by = "id", all.x = TRUE)
                  if (to_disk) {
                        index <- order(fill_value$x)
                        fill_value <- fill_value[index, ]
                        fill_value <- rev(split(x = fill_value, f = fill_value$y))
                        out <- terra::rast(landscape)
                        blks <- terra::writeStart(x = out, filename = paste0(tempfile(), 
                                                                             ".tif"), overwrite = TRUE)
                        for (i in 1:blks$n) {
                              start_row <- blks$row[i]
                              end_row <- blks$row[i] + (blks$nrows[i] - 
                                                              1)
                              values_temp <- do.call("rbind", fill_value[start_row:end_row])
                              terra::writeValues(out, values_temp$value, 
                                                 blks$row[i], blks$nrows[i])
                        }
                        terra::writeStop(out)
                        return(out)
                  }
                  else {
                        out <- terra::rast(fill_value[, c(2, 3, 8)], 
                                           crs = crs_input)
                        return(out)
                  }
            })
      }, warning = function(cond) {
            warning_messages <<- c(warning_messages, conditionMessage(cond))
            invokeRestart("muffleWarning")
      })
      names(result) <- metrics
      if (progress) {
            cat("\n")
      }
      if (length(warning_messages) > 0) {
            warning_messages <- unique(warning_messages)
            lapply(warning_messages, function(x) {
                  warning(x, call. = FALSE)
            })
      }
      return(result)
}

calculate_lsm <- function (landscape, level = NULL, metric = NULL, name = NULL, 
                           type = NULL, what = NULL, directions = 8, count_boundary = FALSE, 
                           consider_boundary = FALSE, edge_depth = 1, cell_center = FALSE, 
                           classes_max = NULL, neighbourhood = 4, ordered = TRUE, base = "log2", 
                           full_name = FALSE, verbose = TRUE, progress = FALSE) 
{
      landscape <- landscape_as_list(landscape)
      result <- lapply(X = seq_along(landscape), FUN = function(x) {
            if (progress) {
                  cat("\r> Progress nlayers: ", x, "/", length(landscape))
            }
            calculate_lsm_internal(landscape = landscape[[x]], level = level, 
                                   metric = metric, name = name, type = type, what = what, 
                                   directions = directions, count_boundary = count_boundary, 
                                   consider_boundary = consider_boundary, edge_depth = edge_depth, 
                                   cell_center = cell_center, classes_max = classes_max, 
                                   neighbourhood = neighbourhood, ordered = ordered, 
                                   base = base, full_name = full_name, verbose = verbose, 
                                   progress = FALSE)
      })
      layer <- rep(seq_along(result), vapply(result, nrow, FUN.VALUE = integer(1)))
      result <- do.call(rbind, result)
      result <- result[with(result, order(layer, level, metric, 
                                          class, id)), ]
      if (progress) {
            cat("\n")
      }
      tibble::add_column(result, layer, .before = TRUE)
}

rcpp_get_unique_values <- function(x, na_omit = TRUE) {
      .Call('_landscapemetrics_rcpp_get_unique_values', PACKAGE = 'landscapemetrics', x, na_omit)
}

get_unique_values_int <- function(landscape, verbose = FALSE) {
      
      if (inherits(x = landscape, what = "SpatRaster")) {
            
            landscape <- terra::as.matrix(landscape, wide = TRUE)
            
      } else if (!inherits(x = landscape, what = "matrix") &&
                 !inherits(x = landscape, what = "integer") &&
                 !inherits(x = landscape, what = "numeric")) {
            
            stop("Input must be vector, matrix, raster, stars, or terra object or list of previous.",
                 call. = FALSE)
            
      }
      
      if (typeof(landscape) != "integer" && verbose) {
            
            warning("Double values will be converted to integer.", call. = FALSE)
            
      }
      
      sort(rcpp_get_unique_values(landscape))
}

prepare_extras <- function (metrics, landscape_mat, directions, neighbourhood, 
                            ordered, base, resolution) 
{
      
      extras <- list()
      
      extras$classes <- get_unique_values_int(landscape_mat, 
                                              verbose = FALSE)
      
      extras$class_patches <- get_class_patches(landscape_mat, 
                                                extras$classes, directions)
      
      extras$area_patches <- get_area_patches(extras$class_patches, 
                                              extras$classes, resolution)
      return(extras)
}

lsm_p_area_calc <- function(landscape, directions, resolution, extras = NULL){
      
      if (missing(resolution)) resolution <- terra::res(landscape)
      
      if (is.null(extras)){
            metrics <- "lsm_p_area"
            landscape <- terra::as.matrix(landscape, wide = TRUE)
            extras <- prepare_extras(metrics, landscape_mat = landscape,
                                     directions = directions, resolution = resolution)
      }
      
      # all values NA
      if (all(is.na(landscape))) {
            return(tibble::new_tibble(list(level = "patch",
                                           class = as.integer(NA),
                                           id = as.integer(NA),
                                           metric = "area",
                                           value = as.double(NA))))
      }
      
      # get unique class id
      classes <- extras$classes
      class_patches <- extras$class_patches
      area_patches <- extras$area_patches
      
      area_patch <- do.call(rbind,
                            lapply(classes, function(patches_class){
                                  
                                  # get connected patches
                                  landscape_labeled <- class_patches[[as.character(patches_class)]]
                                  
                                  # multiply number of cells within each patch with hectar factor
                                  area_patch_ij <- area_patches[[as.character(patches_class)]]
                                  
                                  tibble::new_tibble(list(
                                        class = rep(as.integer(patches_class), length(area_patch_ij)),
                                        value = area_patch_ij))
                            })
      )
      return(tibble::new_tibble(list(
            level = rep("patch", nrow(area_patch)),
            class = as.integer(area_patch$class),
            id = as.integer(seq_len(nrow(area_patch))),
            metric = rep("area", nrow(area_patch)),
            value = as.double(area_patch$value)
      )))
}

calculate_lsm_internal <- function (landscape, level, metric, name, type, what, directions, 
                                    count_boundary, consider_boundary, edge_depth, cell_center, 
                                    classes_max, neighbourhood, ordered, base, full_name, verbose, 
                                    progress) 
{
      if (verbose) {
            check <- check_landscape(landscape, verbose = FALSE)
            if (check$OK != cli::symbol$tick) {
                  warning("Please use 'check_landscape()' to ensure the input data is valid.", 
                          call. = FALSE)
            }
      }
      landscape <- terra::as.int(landscape)
      metrics <- list_lsm(level = level, metric = metric, name = name, 
                          type = type, what = what, simplify = TRUE, verbose = verbose)
      metrics_calc <- paste0(metrics, "_calc")
      number_metrics <- length(metrics_calc)
      resolution <- terra::res(landscape)
      landscape <- terra::as.matrix(landscape, wide = TRUE)
      extras <- prepare_extras(metrics, landscape, directions, 
                               neighbourhood, ordered, base, resolution)
      result <- do.call(rbind, lapply(seq_along(metrics_calc), 
                                      FUN = function(current_metric) {
                                            if (progress) {
                                                  cat("\r> Progress metrics: ", current_metric, 
                                                      "/", number_metrics)
                                            }
                                            foo <- get(metrics_calc[[current_metric]], mode = "function")
                                            arguments <- names(formals(foo))
                                            resultint <- tryCatch(do.call(what = foo, args = mget(arguments, 
                                                                                                  envir = parent.env(environment()))), error = function(e) {
                                                                                                        message("")
                                                                                                        stop(e)
                                                                                                  })
                                            resultint
                                      }))
      if (full_name == TRUE) {
            col_ordering <- c("level", "class", "id", "metric", 
                              "value", "name", "type", "function_name")
            result <- merge(x = result, y = lsm_abbreviations_names, 
                            by = c("level", "metric"), all.x = TRUE, sort = FALSE, 
                            suffixes = c("", ""))
            result <- tibble::as_tibble(result[, col_ordering])
      }
      if (progress) {
            cat("\n")
      }
      return(result)
}
