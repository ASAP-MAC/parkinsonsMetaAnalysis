library(tidyverse)
library(parkinsonsMetagenomicData)

gene_families_unstrat_url <- get_hf_parquet_urls() %>% 
  filter(data_type == "genefamilies_unstratified") %>% 
  .$url

# print available parquet files' URLs
gene_families_unstrat_url

destfile <- "~/Downloads/genefamilies_unstratified_uuid.parquet"

if(!file.exists(destfile)){
  # download it if not there yet
  download.file(
    gene_families_unstrat_url[2],
    destfile = destfile
  )
}

wallenData <- filter(sampleMetadata, study_name == "WallenZD_2022")

dim(wallenData)

WallenZD_2022_gene_families <- returnSamples(sample_data = wallenData, 
                                             local_files = "~/Downloads/genefamilies_unstratified_uuid.parquet", 
                                             data_type = "genefamilies_unstratified"
                                             )

# Error in `vec_rep_each()`:
#   ! `times` can't be missing. Location 1 is missing.
# Run `rlang::last_trace()` to see where the error occurred.
# Warning message:
# In nrow * ncol : NAs produced by integer overflow

#------------------------------------------------------------------------------
# Other personal tests/attempts

# columns are 
## gene_family
## rpk_abundance
## uuid
## humann_header 

# parquet_raw <- arrow::read_parquet("~/Downloads/genefamilies_unstratified_uuid.parquet")
parquet_raw <- arrow::read_parquet(
  file = "~/Downloads/genefamilies_unstratified_uuid.parquet", col_select = c("gene_family","rpk_abundance", "uuid")
)

# use data.table? doesn't make sense