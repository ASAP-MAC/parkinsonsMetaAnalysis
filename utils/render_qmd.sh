#!/bin/bash

# Script to render a Quarto file for multiple biobakery tools (MetaPhlAn, HUMAnN)
# This automates the workaround of copying the file to have tool-specific output names.

# Usage: ./utils/render_qmd.sh <path/to/file.qmd> [tool1] [tool2] ...
# Example: ./utils/render_qmd.sh 01-Data/01-prepare-pMD-data.qmd

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <qmd_file> [tool1] [tool2] ..."
    echo "If no tools are provided, it defaults to MetaPhlAn and HUMAnN."
    exit 1
fi

TARGET_FILE=$1
shift

# Tools to iterate over
TOOLS=("$@")
if [ ${#TOOLS[@]} -eq 0 ]; then
    TOOLS=("MetaPhlAn" "HUMAnN")
fi

# Ensure the target file exists
if [ ! -f "$TARGET_FILE" ]; then
    echo "Error: File '$TARGET_FILE' not found."
    exit 1
fi

# Extract file details
DIR=$(dirname "$TARGET_FILE")
BASE=$(basename "$TARGET_FILE")
NAME="${BASE%.*}"
EXT="${BASE##*.}"

for TOOL in "${TOOLS[@]}"; do
    TMP_FILE="${DIR}/${NAME}_${TOOL}.${EXT}"
    
    echo "------------------------------------------------------------"
    echo "Rendering ${TARGET_FILE} for tool: ${TOOL}"
    echo "Temporary file: ${TMP_FILE}"
    
    cp "${TARGET_FILE}" "${TMP_FILE}"
    
    quarto render "${TMP_FILE}" \
        -P "biobakery_tool:${TOOL}"
    
    RENDER_STATUS=$?
    
    if [ -f "${TMP_FILE}" ]; then
        rm "${TMP_FILE}"
    fi
    
    if [ $RENDER_STATUS -ne 0 ]; then
        echo "Error: Failed to render ${TARGET_FILE} for ${TOOL}."
        exit 1
    fi
done

echo "------------------------------------------------------------"
echo "Finished rendering all tools."
