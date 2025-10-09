FROM python:3.11-slim

# Install system dependencies for web scraping and Chromium
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    curl \
    chromium \
    chromium-driver \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the pipeline code
COPY . .

# Set environment variables for headless Chromium
ENV CHROMEDRIVER_PATH=/usr/bin/chromedriver
ENV HEADLESS=true

# Make the pipeline scripts executable
RUN chmod +x run_pipeline.sh run_container.sh

# Create necessary directories
RUN mkdir -p data/scraped_data data/processed_data

# Default command - use container-friendly runner
CMD ["./run_container.sh"]
