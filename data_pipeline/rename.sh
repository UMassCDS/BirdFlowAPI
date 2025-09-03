#!/bin/bash

# Array of original file paths
ORIGINAL_FILES=(
    "data/scraped_data/HPAI Detections in Wild Birds.csv"
    "data/scraped_data/A Table by Confirmation Date.csv"
    "data/scraped_data/Table Details by Date.csv"
)

# Array of new file names (not full paths)
NEW_FILES=(
    "wild_birds.csv"
    "commercial_backyard_stocks.csv"
    "bovine.csv"
)

if [ "${#ORIGINAL_FILES[@]}" -ne "${#NEW_FILES[@]}" ]; then
    echo "Error: Number of original files and new names must match."
    exit 1
fi

for i in "${!ORIGINAL_FILES[@]}"; do
    ORIGINAL_FILE="${ORIGINAL_FILES[i]}"
    NEW_FILE="${NEW_FILES[i]}"
    if [ ! -f "$ORIGINAL_FILE" ]; then
        echo "File '$ORIGINAL_FILE' does not exist. Skipping..."
        continue
    fi
    DIR_PATH="$(dirname "$ORIGINAL_FILE")"
    NEW_FILE_PATH="$DIR_PATH/$NEW_FILE"

    mv "$ORIGINAL_FILE" "$NEW_FILE_PATH"

    if [ $? -eq 0 ]; then
        echo "Renamed '$ORIGINAL_FILE' to '$NEW_FILE_PATH'"
    else
        echo "Failed to rename '$ORIGINAL_FILE'"
    fi
done

# --- Run WB processor ---
python -m src.processors.wild_birds_processor

if [ $? -eq 0 ]; then
    echo "Python script executed successfully."
else
    echo "Python script failed."
fi
