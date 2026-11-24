# ==========================================================================
# voom log2-CPM transformation, identical to limma::voom()$E
# ==========================================================================

#' voom transformation without fitting a model
#'
#' Reproduces the expression values (`$E`) returned by `limma::voom()` with
#' default settings (`normalize.method = "none"`, no offsets), using the same
#' arithmetic in the same order so results are numerically identical:
#'
#'   E = log2( (counts + 0.5) / (lib.size + 1) * 1e6 )
#'
#' The transformation is sample-wise: each sample only depends on its own counts
#' and library size. The design matrix passed to `limma::voom()` only affects the
#' precision weights, not `$E`, so it is not needed here. Therefore applying it
#' to all datasets at once gives the same values as applying it per dataset (as
#' `limmaTSE(voom.transform = TRUE)` does in 03-PD-metaAnalysis.qmd), provided
#' that `lib.size` is the same, i.e. the column sums of the same counts.
#'
#' @param counts \code{matrix} of counts, features in rows, samples in columns
#' @param lib.size \code{numeric} library sizes, one per sample
#'   (Default: `colSums(counts)`, as in `limma::voom()`)
#'
#' @returns \code{matrix} of log2-CPM values with the dimnames of `counts`
voom_transform <- function(counts, lib.size = colSums(counts)) {
  counts <- as.matrix(counts)
  if (length(lib.size) != ncol(counts)) {
    stop("`lib.size` must have one value per sample (column of `counts`).")
  }
  # same construction and arithmetic as in limma::voom()
  lib.size.matrix <- matrix(lib.size, nrow(counts), ncol(counts), byrow = TRUE)
  log2((counts + 0.5) / (lib.size.matrix + 1) * 1e+06)
}
