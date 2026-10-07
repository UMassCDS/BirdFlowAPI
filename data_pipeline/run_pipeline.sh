#!/bin/bash

# Run poultry scraper
python -m src.scrapers.poultry_scraper
if [ $? -eq 0 ]; then
    echo "Poultry scraper executed successfully."
else
    echo "Poultry scraper failed."
fi

# Run wild birds scraper
python -m src.scrapers.wild_birds_scraper
if [ $? -eq 0 ]; then
    echo "Wild birds scraper executed successfully."
else
    echo "Wild birds scraper failed."
fi

# Run bovine scraper
python -m src.scrapers.bovine_scraper
if [ $? -eq 0 ]; then
    echo "Bovine scraper executed successfully."
else
    echo "Bovine scraper failed."
fi


# --- Run poultry processor ---
python -m src.processors.poultry_processor

if [ $? -eq 0 ]; then
    echo "Poultry processor executed successfully."
else
    echo "Poultry processor failed."
fi

# --- Run wild birds processor ---
python -m src.processors.wild_birds_processor

if [ $? -eq 0 ]; then
    echo "Wild birds processor executed successfully."
else
    echo "Wild birds processor failed."
fi

# --- Run bovine processor ---
python -m src.processors.bovine_processor

if [ $? -eq 0 ]; then
    echo "Bovine processor executed successfully."
else
    echo "Bovine processor failed."
fi

# --- Upload processed data to S3 ---
python -m src.utils.s3_uploader

if [ $? -eq 0 ]; then
    echo "S3 upload executed successfully."
else
    echo "S3 upload failed."
fi