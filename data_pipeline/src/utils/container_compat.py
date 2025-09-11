"""
Container compatibility module for Selenium Chrome options.
Automatically patches Chrome options when running in container environments.
"""

import os
import tempfile
import uuid

# Check if we're running in a container
if os.environ.get('CONTAINER_MODE') == 'true' or os.path.exists('/.dockerenv'):
    try:
        from selenium.webdriver.chrome.options import Options
        
        # Store the original __init__ method
        _original_init = Options.__init__
        
        def _container_friendly_init(self):
            """Initialize Chrome options with container-friendly settings"""
            # Call the original init
            _original_init(self)
            
            # Add container-specific arguments
            self.add_argument('--headless')
            self.add_argument('--no-sandbox') 
            self.add_argument('--disable-dev-shm-usage')
            self.add_argument('--disable-gpu')
            self.add_argument('--disable-extensions')
            self.add_argument('--disable-software-rasterizer')
            self.add_argument('--remote-debugging-port=9222')
            self.add_argument('--disable-web-security')
            self.add_argument('--disable-features=VizDisplayCompositor')
            self.add_argument('--single-process')
            
            # Create a unique user data directory
            temp_dir = tempfile.gettempdir()
            unique_dir = os.path.join(temp_dir, f"chrome_user_data_{uuid.uuid4().hex[:8]}")
            self.add_argument(f'--user-data-dir={unique_dir}')
            
        # Replace the __init__ method
        Options.__init__ = _container_friendly_init
        
        print("✓ Chrome options patched for container environment")
        
    except ImportError:
        print("⚠ Selenium not available, Chrome options not patched")
    except Exception as e:
        print(f"⚠ Could not patch Chrome options: {e}")
