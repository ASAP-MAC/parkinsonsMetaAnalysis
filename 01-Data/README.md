# Prepare data for meta-analysis

## Download public data from `parkinsonsMetagenomicData`

```bash
quarto render 01-download-from-parkinsonsMetagenomicData.qmd \
  # downlaod MetaPhlAn
  -P pMD_data_type:"relative_abundance" \
  # overwrite target directory
  -P overwrite_output:"yes" \
  -P taxonomy_type:"GTDB"
  
quarto render 01-download-from-parkinsonsMetagenomicData.qmd \
  # downlaod MetaPhlAn
  -P pMD_data_type:"pathabundance_unstratified" \
  # overwrite target directory
  -P overwrite_output:"yes" \
  -P taxonomy_type:"GTDB"
```

## Prepare unpublished data locally (blue Poo, Payami NGRC, Payami UAB)

```bash
quarto render 02-prepare-private-data.qmd -P pMD_data_type:"relative_abundance"
quarto render 02-prepare-private-data.qmd -P pMD_data_type:"pathabundance_unstratified"
```

## Files are stores in local home to ensure data privacy

See TSE directories in `~/parkinsonMetaAnalysis_data/02-intermediate-datasets/...`

## Merge all data into one TSE for simplicity

```bash
quarto render 03-merge-data-for-PD-metaAnalysis.qmd -P pMD_data_type:"relative_abundance"
quarto render 03-merge-data-for-PD-metaAnalysis.qmd -P pMD_data_type:"pathabundance_unstratified"
```