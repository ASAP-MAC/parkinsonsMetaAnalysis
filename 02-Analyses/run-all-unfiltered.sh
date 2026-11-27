#!/bin/bash
# Run all analyses in 02-Analyses sequentially WITHOUT the prevalence (5%) /
# detection (1e-5) feature filter (filterFeatures: false).
# Results go to 02-Analyses/results/unfilteredFeatures/.
#
# Usage (from anywhere, inside the quarto environment):
#   micromamba activate quarto
#   bash 02-Analyses/run-all-unfiltered.sh
#
# The only difference with run-all-filtered.sh is the two variables below.

FILTER=false
SUFFIX=unfiltered

set -euo pipefail
cd "$(dirname "$0")"

# render <qmd> <tag> [quarto -P params...]
# Renders a copy named <name>_<tag>.qmd, so every tool/setting gets its own .html
render() {
  local qmd=$1 tag=$2
  shift 2
  local tmp="${qmd%.qmd}_${tag}.qmd"
  echo "==== $(date '+%F %T') rendering ${qmd} (${tag})"
  cp "$qmd" "$tmp"
  if ! quarto render "$tmp" "$@"; then
    rm -f "$tmp"
    echo "==== FAILED: ${qmd} (${tag})"
    exit 1
  fi
  rm -f "$tmp"
}

# 00 and 01 do not depend on the feature filter
quarto render 00-Parkinson-in-BugSigDB.qmd
quarto render 01-demographic-tables.qmd
mkdir -p results
mv 01-demographic-tables.docx results/.

# alpha and beta diversity: MetaPhlAn only
for tool in MetaPhlAn; do
  render 02-alpha_beta_diversity.qmd "${tool}_${SUFFIX}" -P "biobakery_tool:${tool}" -P "filterFeatures:${FILTER}"
done

for tool in MetaPhlAn HUMAnN; do
  render 03-PD-metaAnalysis.qmd "${tool}_${SUFFIX}" -P "biobakery_tool:${tool}" -P "filterFeatures:${FILTER}"
done

# slow: several hours in total
for tool in MetaPhlAn HUMAnN; do
  for tr in relative_abundance voom; do
    render 04-ML-RF-LODO-gradient.qmd "${tool}-${tr}_${SUFFIX}" -P "biobakery_tool:${tool}" -P "transform:${tr}" -P "filterFeatures:${FILTER}"
  done
done

# 06 reads the results of 05, so 05 must run first
for tool in MetaPhlAn HUMAnN; do
  render 05-Constipation-healthy-metaAnalysis.qmd "${tool}_${SUFFIX}" -P "biobakery_tool:${tool}" -P "filterFeatures:${FILTER}"
done

for tool in MetaPhlAn HUMAnN; do
  render 06-PD-Constipation-score-and-mediation.qmd "${tool}_${SUFFIX}" -P "biobakery_tool:${tool}" -P "filterFeatures:${FILTER}"
done

echo "==== $(date '+%F %T') all analyses finished (${SUFFIX})"
