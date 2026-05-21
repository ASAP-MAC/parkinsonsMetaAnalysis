
```bash
micromamba activate quarto

# limma
quarto render 02-PD-metaAnalysis.qmd \
  -P pMD_data_type:relative_abundance \
  -P DA_method:limma

# maaslin2
quarto render 02-PD-metaAnalysis.qmd \
-P pMD_data_type:relative_abundance \
-P DA_method:limma
```