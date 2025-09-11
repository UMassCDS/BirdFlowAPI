#!/usr/bin/env python3
"""
Container-friendly pipeline runner that sets up Chrome options for headless operation.
This script temporarily modifies the Chrome options in memory without changing the source files.
"""

import os
import sys
import importlib.util
import subprocess
from selenium.webdriver.chrome.options import Options

# Set environment variable for container mode
os.environ['CONTAINER_MODE'] = 'true'

def patch_chrome_options():
    """Monkey patch the Options class to include container-friendly settings"""
    original_init = Options.__init__
    
    def container_friendly_init(self):
        original_init(self)
        if os.environ.get('CONTAINER_MODE') == 'true':
            # Add container-friendly Chrome options
            self.add_argument("--headless")
            self.add_argument("--no-sandbox")
            self.add_argument("--disable-dev-shm-usage")
            self.add_argument("--disable-gpu")
            self.add_argument("--disable-extensions")
            self.add_argument("--disable-software-rasterizer")
            self.add_argument("--remote-debugging-port=9222")
            # Generate unique user data directory to avoid conflicts
            import tempfile
            import uuid
            temp_dir = tempfile.gettempdir()
            unique_dir = os.path.join(temp_dir, f"chrome_user_data_{uuid.uuid4()}")
            self.add_argument(f"--user-data-dir={unique_dir}")
    
    Options.__init__ = container_friendly_init

def run_pipeline():
    """Run the main pipeline script"""
    try:
        # Apply the monkey patch
        patch_chrome_options()
        
        # Import and run the main pipeline
        result = subprocess.run([
            sys.executable, 'run_pipeline.py'
        ], capture_output=False)
        
        return result.returncode
        
    except Exception as e:
        print(f"Error running pipeline: {e}")
        return 1

if __name__ == "__main__":
    exit_code = run_pipeline()
    sys.exit(exit_code)
