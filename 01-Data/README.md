# Prepare data for meta-analysis

## Download public data from `parkinsonsMetagenomicData`

```bash
for pipl in MetaPhlAn HUMAnN;
do
  cp "01-prepare-pMD-data.qmd" \
     "01-prepare-pMD-data_${pipl}.qmd"

  quarto render "01-prepare-pMD-data_${pipl}.qmd" \
    -P "biobakery_pipeline:${pipl}" \
    -P "overwrite_TSE_out:yes"

  rm "01-prepare-pMD-data_${pipl}.qmd"
done
```

## Prepare unpublished data locally (blue Poo, Payami NGRC, Payami UAB)

```bash
for pipl in MetaPhlAn HUMAnN;
do
  cp "02-prepare-private-data.qmd" \
     "02-prepare-private-data_${pipl}.qmd"

  quarto render "02-prepare-private-data_${pipl}.qmd" \
    -P "biobakery_pipeline:${pipl}" \
    -P "overwrite_TSE_out:yes"

  rm "02-prepare-private-data_${pipl}.qmd"
done
```

## Files are stores in local home to ensure data privacy

If private data were available under `~/parkinsonMetaAnalysis_data/02-private_local_datasets`
these below would be the datasets that were just created:

```bash
cd ~/parkinsonMetaAnalysis_data

find . -type d -name "*.tse"

./02-private_local_datasets/bluePoo/AsnicarF_2021_MetaPhlAn.tse
./02-private_local_datasets/bluePoo/AsnicarF_2021_HUMAnN.tse
./02-private_local_datasets/Payami/NGRC_UAB_MetaPhlAn.tse
./02-private_local_datasets/Payami/NGRC_UAB_HUMAnN.tse
./01-pMD_datasets/pMD_MetaPhlAn.tse
./01-pMD_datasets/pMD_HUMAnN.tse
```

## Sample exclusions step by step are stored as .json files

```bash
cd ~/parkinsonMetaAnalysis_data

find . -type f -name "*sample_filtering_steps.json"

./02-private_local_datasets/bluePoo/00-AsnicarF_2021_HUMAnN_sample_filtering_steps.json
./02-private_local_datasets/bluePoo/00-AsnicarF_2021_MetaPhlAn_sample_filtering_steps.json
./02-private_local_datasets/Payami/00-NGRC_UAB_MetaPhlAn_sample_filtering_steps.json
./02-private_local_datasets/Payami/00-NGRC_UAB_HUMAnN_sample_filtering_steps.json
./01-pMD_datasets/00-pMD_HUMAnN_sample_filtering_steps.json
./01-pMD_datasets/00-pMD_MetaPhlAn_sample_filtering_steps.json
```

## Merge all data into one TSE for simplicity

This last step is useful for one last round of exclusions

```bash
for pipl in MetaPhlAn HUMAnN;
do
  cp "03-merge-data-for-PD-metaAnalysis.qmd" \
     "03-merge-data-for-PD-metaAnalysis_${pipl}.qmd"

  quarto render "03-merge-data-for-PD-metaAnalysis_${pipl}.qmd" \
    -P "biobakery_pipeline:${pipl}" \
    -P "overwrite_TSE_out:yes"

  rm "03-merge-data-for-PD-metaAnalysis_${pipl}.qmd"
done
```