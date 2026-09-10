# Shared helpers for 01-Data/01-prepare-pMD-data.qmd and
# 01-Data/02-prepare-bluePoo-data.qmd, so the tool-name mapping, country
# lookup, and MetaPhlAn/HUMAnN-specific TSE formatting stay in one place
# instead of drifting between the two scripts.

# maps a biobakery tool to the pMD data_type it corresponds to, and to the
# human-readable name used in output file names
biobakery_tool_map <- data.frame(
  data_type = c("relative_abundance", "pathabundance_unstratified"),
  biobakery_tool = c("MetaPhlAn", "HUMAnN"),
  output_name = c("relative_abundance", "pathways")
)

# country of origin per study, used to fill in colData$Country
country_per_study.chr <- c(
  BedarfJR_2017   = "Germany",
  BoktorJC_2023   = "USA",
  BoktorJC_2023.2 = "USA",
  DuruIC_2024     = "Finland",
  JoS_2022        = "South Korea",
  LeeEJ_2024      = "South Korea",
  MaoL_2021       = "China",
  NishiwakiH_2024 = "Japan",
  QianY_2020      = "China",
  WallenZD_2022   = "Deep South USA",
  ZhangM_2023     = "China",
  NGRC            = "USA",
  UAB             = "Deep South USA"
)

#' Apply MetaPhlAn/HUMAnN-specific formatting to a pMD-derived TSE
#'
#' Runs `pMD_enhance()` and then, depending on `tool`, standardizes
#' `reads_processed` and the assay names/order so downstream scripts can
#' treat MetaPhlAn and HUMAnN TSEs uniformly (assays: counts,
#' relative_abundance, pathways where applicable).
#'
#' @param tse a TreeSummarizedExperiment as returned by `returnSamples()`
#' @param tool one of "MetaPhlAn" or "HUMAnN"
#' @param data_type the pMD data_type used to build `tse` (passed to `pMD_enhance()`)
format_tool_specific_tse <- function(tse, tool, data_type) {
  if (!(tool %in% c("MetaPhlAn", "HUMAnN"))) {
    stop("Biobakery tool requested not existent, choose between 'MetaPhlAn' and 'HUMAnN'")
  }

  tse <- pMD_enhance(tse, data_type = data_type)

  if (tool == "MetaPhlAn") {
    # reads_processed as numeric values
    tse@colData$reads_processed <- as.numeric(gsub(
      "#([0-9]+).*", "\\1", tse@colData$reads_processed
    ))

    # reorder and rename assays to counts; relative_abundance; pathways
    assays(tse) <- assays(tse)[c(3, 1, 2)]
  }

  if (tool == "HUMAnN") {
    # assume some reads processed from the abundances of the pathways
    tse@colData$reads_processed <- colSums(assay(tse))

    # rename first assay
    assayNames(tse)[1] <- "counts"
  }

  tse
}
