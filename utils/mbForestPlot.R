# ======================================================================
# small function that selects top N features of a diff. abund or pooled meta-analysis
# the analyses should be coming from biobakeryUtils functions, 
# or from pre-relabeled results
# ======================================================================

#' Get top features from results
#' 
#' The function extracts N features as requested, but only even numbers are 
#' allowed. If an odd number is provided, the function will extract one sample
#' less.
#' 
#' @param res \code{data.frame} 
#' @param topN_feat \code{integer} number of top features to extract. It is 
#' permissive and will do a sanity check on the input. Eg: if 19 is provided, 18 
#' features are extracted. if 19.99 is provided, 18 are extracted anyway.
#' @param P_adj_thr \code{double}. The P-value threshold to filter results with
#' and return the `topN_feat` features
#'
#' @export
#' @returns \code{data.frame} with up to topN_feat/2 negatively and topN_feat/2
#' positively associated features. If less than topN_feat/2, all are returned.
#' 
get_res_topN_features <- function(res, topN_feat = 20, P_adj_thr = 0.1) {
  
  if (topN_feat %% 2 != 0) {
    topN_feat <- (topN_feat %/% 2) * 2
    warning("topN_feat provided is not an even integer, value coerced to ", topN_feat)
  }
  
  Beta_col <- grep("Beta", colnames(res), value = TRUE, ignore.case = TRUE)
  Pval_col <- grep("value.adj", colnames(res), value = TRUE, ignore.case = TRUE)
  
  top_pos <- res %>%
    filter(!!sym(Pval_col) < P_adj_thr) %>%
    slice_max(order_by = !!sym(Beta_col), n = topN_feat / 2)
  
  top_neg <- res %>%
    filter(!!sym(Pval_col) < P_adj_thr) %>%
    slice_min(order_by = !!sym(Beta_col), n = topN_feat / 2)
  
  return(bind_rows(top_pos, top_neg))
}

#----------------------

#' Generate features columns for pretty plot
#' 
#' function that returns a formatted column for plotting by guessing the 
#' biobakery data type
#' 
#' @param meta_df \code{data.frame} of meta-analysis results
#'
#' @returns \code{data.frame} with an extra column named "featuresCol"
#' @export
#'
#' @examples
prepare_featuresCol <- function(meta_df){
  
  featureID <- colnames(meta_df)[grep("StudiesTested", colnames(meta_df)) -1]
  
  if(featureID == "SGB"){
    meta_df <- meta_df %>% 
      # create a features column
      mutate(
        featuresCol = sprintf("%s [%s]", gsub("s__|g__", "", Species), gsub("t__", "", SGB))
      )
  }
  
  if(featureID == "description"){
    meta_df <- meta_df %>% 
      # create a Pathways features column
      mutate(
        featuresCol = sprintf("%s [%s]", description, metacyc_code)
      )
  }
  
  # assign this vector beyond this function
  featuresCol_transl_vec <- meta_df$featuresCol
  names(featuresCol_transl_vec) <- meta_df[[featureID]]
  
  return(list(meta_df, featuresCol_transl_vec))
}

# ==========================================================================
# Forest plot function compatible with metaAnalyze function in biobakeryUtils
ForestPlot_biobakery <- function(
    res.list,
    topN_feat    = 20,
    P_adj_thr = 0.2,
    decreasing = TRUE
) {
  
  tmp <- res.list$MetaAnalysis %>%
    filter(P.Value.adj < P_adj_thr) %>%
    prepare_featuresCol()
  
  meta_df                <- tmp[[1]]
  featuresCol_transl_vec <- tmp[[2]]
  
  # get top N results — now correctly uses its own `res` arg
  topN_df <- get_res_topN_features(
    res       = res.list$MetaAnalysis,
    topN_feat = topN_feat,
    P_adj_thr = P_adj_thr
  )
  
  # attach featuresCol on the topN data frame
  featureID_col <- colnames(res.list$MetaAnalysis)[
    grep("StudiesTested", colnames(res.list$MetaAnalysis)) - 1
  ]
  
  topN_df <- topN_df %>%
    mutate(featuresCol = featuresCol_transl_vec[.data[[featureID_col]]])
  
  # order vector of features based on the `decreasing` parameter
  selected_features_ordered <- topN_df$featuresCol[order(topN_df$Beta.pool)]
  
  # order reverse in case of decreasing
  if(!decreasing) {
    selected_features_ordered <- rev(selected_features_ordered)
    }
  
  topN_df$featuresCol <- factor(topN_df$featuresCol, levels = selected_features_ordered)
  
  # ── 3. Read Tab 1 (Beta_matrix) ───────────────────────────────────────────
  #   Row 1 = feature IDs (column headers)
  #   Rows 2..n = one row per study, no row-label column
  # beta_raw: columns are features, rows are studies
  beta_raw <- res.list$Beta_matrix
  study_labels <- beta_raw$Dataset
  n_studies <- nrow(beta_raw)
  beta_raw$Dataset <- NULL
  colnames(beta_raw) <- featuresCol_transl_vec[colnames(beta_raw)]
  
  # Keep only selected features; handle '#N/A' strings → real NA
  beta_long <- beta_raw[,selected_features_ordered] %>% 
    mutate(study_label = study_labels,
           study_rank  = factor(seq_len(n_studies))) %>%
    pivot_longer(
      cols      = -c("study_label", "study_rank"),
      names_to  = "featuresCol",
      values_to = "Beta.pool"
    )
  
  # ── 4. Build forest plot ───────────────────────────────────────────────────
  forest_plot <- ggplot() +
    geom_vline(xintercept = 0, linetype = "dashed", colour = "grey50") +
    
    # Per-study points (jittered text labels showing study rank)
    geom_text(
      data    = beta_long,
      mapping = aes(
        x = Beta.pool,
        y = featuresCol,
        label = study_rank
      ),
      color = "gray70",
      position = position_jitter(height = 0.3),
      size  = 3
    ) +
    
    # Pooled effect error bars (±1 SE)
    geom_errorbar(
      data    = topN_df,
      mapping = aes(
        x    = Beta.pool,
        y    = featuresCol,
        xmin = CI.L,
        xmax = CI.R
      ),
      width  = 0.1,
      linewidth = 0.5
    ) +
    
    # Pooled effect point
    geom_point(
      data    = topN_df,
      mapping = aes(
        x = Beta.pool,
        y = featuresCol
      ),
      size   = 3,
      shape  = 18          # diamond — classic forest-plot symbol
    ) +
    
    labs(
      x       = "Pooled Effect Size",
      y       = "Feature",
      caption = paste0(
        "Numbered labels = individual study effects (Study 1\u2013", n_studies, ").\n",
        "Diamond = pooled random-effects estimate. Error bars: 95% CI of pooled Beta",
        "Heterogeneity is not considered when making the selection of features to plot")
      ) +
    theme(
      axis.text.y  = element_text(size = 9),
      plot.caption = element_text(size = 7, colour = "grey40", hjust = 0)
    )
  
  return(list(plot = forest_plot, label_ranks = beta_long %>% select(study_rank, study_label) %>% distinct()))
}

# =============================================================================
# Not complete, but concept is: from a ggplot y label, return a better looking microbiome label
# =============================================================================

enrich_y_taxonomy_label <- function(taxFP, taxonomy.df) {
  genus_piece      <- gsub("g__", "", taxonomy.df$Genus)
  Vgsub            <- Vectorize(gsub)
  Species_formatted <- paste(
    genus_piece,
    Vgsub(paste0("s__", genus_piece, "_"), "", taxonomy.df$Species, fixed = TRUE)
  )
  Species_formatted <- gsub("s__", "", Species_formatted)
  AltName.chr       <- paste0(Species_formatted, " [", gsub("t__", "", taxonomy.df$SGB), "]")
  names(AltName.chr) <- taxonomy.df$SGB
  
  taxFP +
    scale_y_discrete(
      labels = function(y) {
        AltNameBasic <- AltName.chr[y]
        AltNameItalics <- strsplit(AltNameBasic, "\\ ") %>%
          lapply(function(x)
            ifelse(
              !("_" %in% x) &
                str_ends(x, "cter|culum|terium|cter|monas|us|ctor|ella|asma|soma|spira|cola|des|is|aecis|ia|cus|ans|spora|ina|zii|pri"),
              paste0("*", x, "*"),
              x
            )
          ) %>%
          purrr::map_chr(.f = function(x) paste(x, collapse = " "))
        return(AltNameItalics)
      }
    ) +
    theme(axis.text.y.left = element_markdown())
}

