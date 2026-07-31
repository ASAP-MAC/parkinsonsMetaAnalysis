
utils/render_qmd.sh runs the same script twice, once for MetaPhlAn, once for HUMAnN
other parameters need to be specified.

## STORMS-table1-alpha-beta

This scripts analyzes metaphlan and humann pathways, but on a selection of 
parameters:

  - transformation: `relative_abundance`
  - alpha metrics: `richness`, `shannon`, and, if metaphlan, `faith` phylogenetic richness
  - beta diversity metric: `Bray-Curtis`
  
```bashs
micromamba activate quarto

quarto render 01-STORMS-table1-alpha_beta_diversity.qmd
```
## PD-Control meta-analysis

### Classic meta-analysis

```bash
../utils/render_qmd.sh "02-PD-metaAnalysis.qmd"
```

### LODO random forest classification

```bash
../utils/render_qmd.sh "03-ML-RF-LODO-relative_abundance.qmd"
../utils/render_qmd.sh "03-ML-RF-LODO-voom.qmd"
```

## Constipation signature analysis

### Constipation meta-analysis

Although underpowered, a meta-analysis is still worth doing

```bash
../utils/render_qmd.sh "04-Constipation-healthy-metaAnalysis.qmd"
```

### Constipation score

```bash
../utils/render_qmd.sh "05-Constipation-score.qmd"
```

# Declutter the directory

```bash
rm *.html
rm slurm*
rm *.rmarkdown
find . -maxdepth 1 -type d -name "*_files" -exec rm -r {} +
find . -maxdepth 1 -type d -name "*_cache" -exec rm -r {} +
```