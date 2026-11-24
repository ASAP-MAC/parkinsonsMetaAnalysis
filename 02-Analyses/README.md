
utils/render_qmd.sh runs the same script twice, once for MetaPhlAn, once for HUMAnN
other parameters need to be specified.

## Activate environment

```bash
micromamba activate quarto
```

## BugSigDB summary of PD signatures

```bash
quarto render 00-Parkinson-in-BugSigDB.qmd
```

## Table 1's and alpha/beta diversities scripts

This scripts analyzes metaphlan and humann pathways, but on a selection of 
parameters:

  - transformation: `relative_abundance`
  - alpha metrics: `richness`, `shannon`, and, if metaphlan, `faith` phylogenetic richness
  - beta diversity metric: `Bray-Curtis`

```bash
quarto render 01-demographic-tables.qmd
mv 01-demographic-tables.docx results/.
```

```bash
../utils/render_qmd.sh "02-alpha_beta_diversity.qmd"
```

## PD-Control meta-analysis

### Classic meta-analysis

```bash
../utils/render_qmd.sh "03-PD-metaAnalysis.qmd"
```
### LODO random forest classification

*NB**: This analysis takes approximately 2 hours, plan ahead.

```bash
for tool in MetaPhlAn HUMAnN; do for tr in relative_abundance voom; do
  quarto render 04-ML-RF-LODO-gradient.qmd -P biobakery_tool:$tool -P transform:$tr \
    --output "04-ML-RF-LODO-gradient_${tool}-${tr}.html"
done; done
```

## Constipation signature analysis

### Constipation meta-analysis

Although underpowered, a meta-analysis is still worth doing to extract
per-dataset summary statistics for the AsnicarF_2021 dataset and for future
cases where more datasets with constipation may be available.

Here we have to lower the default `minStudies.n = 6` to 3, since there are 4
meta-analyzable datasets.

```bash
../utils/render_qmd.sh "05-Constipation-healthy-metaAnalysis.qmd"
```

### Constipation score

```bash
../utils/render_qmd.sh "06-PD-Constipation-score-and-mediation.qmd"
```

# Declutter the directory

```bash
rm *.html
rm slurm*
rm *.rmarkdown
find . -maxdepth 1 -type d -name "*_files" -exec rm -r {} +
find . -maxdepth 1 -type d -name "*_cache" -exec rm -r {} +
```