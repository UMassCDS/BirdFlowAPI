#!/bin/bash

# Set environment variables for container mode
export DISPLAY=:99
export CONTAINER_MODE=true

# Create a unique temporary directory for Chrome user data
export CHROME_USER_DATA_DIR="/tmp/chrome_user_data_$(date +%s)_$$"
mkdir -p "$CHROME_USER_DATA_DIR"

# Import container compatibility by importing src module
python3 -c "import src" 2>/dev/null || echo "Container compatibility not available"

# Now run the actual pipeline shell script
exec ./run_pipeline.sh

# Clean up
rm -rf "$CHROME_USER_DATA_DIR"
