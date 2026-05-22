
```bash
micromamba activate quarto

for tool in MetaPhlAn HUMAnN;
do
  cp "02-PD-metaAnalysis.qmd" "02-PD-metaAnalysis_${tool}.qmd"
  quarto render "02-PD-metaAnalysis_${tool}.qmd" \
    -P "biobakery_tool:${tool}"
  rm "02-PD-metaAnalysis_${tool}.qmd"
done
```