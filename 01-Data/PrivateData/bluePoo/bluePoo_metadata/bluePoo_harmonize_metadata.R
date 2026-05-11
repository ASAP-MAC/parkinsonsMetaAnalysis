library(readr)

bp_1 <- read_tsv("metadata_tt.tsv")
 
bp_2 <- read_tsv("P1__mapp_sample_names.tsv")
colnames(bp_2)[ncol(bp_2)] <- "participant_id"

bp_3 <- merge(bp_2, bp_1, all = "TRUE", by = "participant_id")

write_tsv(bp_3, "bluePoo_metadata_ga.tsv")
