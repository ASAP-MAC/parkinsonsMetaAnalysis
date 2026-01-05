biobakeryForestPlot <- function(meta_input, StdEffSizes, studies_Stats.df, topN_feat = 20, featuresCol = "FeatureID"){
  
  top_pos <- meta_input %>%
    filter(RE_het_P.value > 0.05) %>%
    slice_max(order_by = RE_Eff.Size, n = topN_feat/2)
  
  top_neg <- meta_input %>%
    filter(RE_het_P.value > 0.05) %>%
    slice_min(order_by = RE_Eff.Size, n = topN_feat/2)
  
  topN_bottomN_All.df <- bind_rows(top_pos, top_neg) %>% 
    arrange(desc(RE_Eff.Size))
  topN_bottomN_All.df[[featuresCol]] <- factor(topN_bottomN_All.df[[featuresCol]], levels = topN_bottomN_All.df[[featuresCol]][order(topN_bottomN_All.df$RE_Eff.Size)])
  
  cohenD_df_longer <- StdEffSizes %>%
    as.data.frame() %>% 
    rownames_to_column(featuresCol) %>% 
    reshape2::melt(value.name = "CohenD") %>% 
    mutate(study_name = str_remove(variable, ".*__"),
           variable = NULL,
           study_name = factor(study_name, levels = studies_Stats.df$study_name), 
           study_rank = factor(as.integer(study_name))
    ) %>% 
    filter(
      !!sym(featuresCol) %in% topN_bottomN_All.df[[featuresCol]]
    ) %>% 
    mutate(
      !!sym(featuresCol) := factor(!!sym(featuresCol), levels = levels(topN_bottomN_All.df[[featuresCol]]))
    ) %>% 
    suppressMessages()
  
  forest_plot <- ggplot() +
    geom_vline(xintercept = 0, lty = "dashed") + 
    geom_errorbar(data = topN_bottomN_All.df, mapping = aes(x = RE_Eff.Size, y = !!sym(featuresCol), xmin = RE_Eff.Size - RE_SE, xmax = RE_Eff.Size + RE_SE), color = "#cf2fb3", width = 0.1) +
    geom_point(data = topN_bottomN_All.df, mapping = aes(x = RE_Eff.Size, y = !!sym(featuresCol)), size = 4, color = "#cf2fb3") +
    geom_text(data = cohenD_df_longer, mapping = aes(x = CohenD, y = !!sym(featuresCol), label = study_rank), alpha = 0.8) +
    #theme(axis.text.y = element_text(face = "italic")) + 
    labs(
      x = "Standardized Effect Size (Cohen D)", 
      y = "Species"
    )
  
  return(forest_plot)
}

enrich_y_taxonomy_label <- function(taxFP, taxonomy.df){
  genus_piece <- gsub("g__", "", taxonomy.df$Genus)
  Vgsub <- Vectorize(gsub)
  Species_formatted <- paste(genus_piece, Vgsub(paste0("s__", genus_piece, "_"), "", taxonomy.df$Species, fixed = TRUE))
  Species_formatted <- gsub("s__", "", Species_formatted)
  AltName.chr <- paste0(Species_formatted, " [", gsub("t__", "", taxonomy.df$SGB), "]")
  
  names(AltName.chr) <- taxonomy.df$SGB
  
  taxFP +
    scale_y_discrete(
    labels = function(y) {
      AltNameBasic <- AltName.chr[y]
      AltNameItalics <- strsplit(AltNameBasic, "\\ ") %>% lapply(function(x) 
        ifelse(!("_" %in% x) & str_ends(x, "cter|culum|terium|cter|monas|us|ctor|ella|asma|soma|spira|cola|des|is|aecis|ia|cus|ans|spora|ina|zii|pri"), paste0("*", x, "*"), x)) %>% 
        purrr::map_chr(.f = function(x) paste(x, collapse = " "))
      return(AltNameItalics)
    }
  ) +
    theme(axis.text.y.left = element_markdown())
}

enrich_y_pathway_label <- function(pathFP, pathway_rowData){
    
  AltName.chr <- paste0(pathway_rowData$Description, " [", pathway_rowData$MetaCyc_code_safeName, "]")
    names(AltName.chr) <- rownames(pathway_rowData)
    
    pathFP +
      scale_y_discrete(
        labels = function(y) {
          AltNameBasic <- AltName.chr[y]
          return(AltNameBasic)
        }
      ) +
      theme(axis.text.y.left = element_markdown())
  }