import os

# Use environment variable for ChromeDriver path, default to container path
CHROMEDRIVER_PATH = os.getenv('CHROMEDRIVER_PATH', '/usr/bin/chromedriver')