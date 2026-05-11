# Download public `parkinsonsMetagenomicData`

## MetaPhlAn relative abundance data

```bash
quarto render 01-download-from-parkinsonsMetagenomicData.qmd \
  -P pMD_data_type:"relative_abundance" \ # downlaod MetaPhlAn
  -P overwrite_output:"yes" \ # overwrite target directory
  -P taxonomy_type:"GTDB"
```

## HUMAnN v3.9 unstratified pathways 

```bash
quarto render 01-download-from-parkinsonsMetagenomicData.qmd \
-P pMD_data_type:"pathabundance_unstratified" \ # downlaod HUMAnN unstrat. PTW
-P overwrite_output:"yes" \# overwrite target directory
```

# Prepare unpublished data locally

## Blue Poo (PMID: 33722860)

## NGRC from Payami Lab

## UAB from Payami Lab

