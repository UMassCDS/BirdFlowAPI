#!/bin/bash

# Run CBS scraper
python src/scrapers/commercial_backyard_stocks.py
if [ $? -eq 0 ]; then
    echo "Commercial backyard stocks scraper ran successfully."
else
    echo "Commercial backyard stocks scraper failed."
fi

# Run WB scraper
python src/scrapers/wild_birds.py
if [ $? -eq 0 ]; then
    echo "Wild birds scraper ran successfully."
else
    echo "Wild birds scraper failed."
fi

# Run bovine scraper
python src/scrapers/bovine.py
if [ $? -eq 0 ]; then
    echo "Bovine scraper ran successfully."
else
    echo "Bovine scraper failed."
fi

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
    echo "Wild birds processor executed successfully."
else
    echo "Wild birds processor failed."
fi

# --- Run CBS processor ---
python -m src.processors.commercial_backyard_stocks_processor

if [ $? -eq 0 ]; then
    echo "Commercial backyard stocks processor executed successfully."
else
    echo "Commercial backyard stocks processor failed."
fi

# --- Run bovine processor ---
python -m src.processors.bovine_processor

if [ $? -eq 0 ]; then
    echo "Bovine processor executed successfully."
else
    echo "Bovine processor failed."
fi
