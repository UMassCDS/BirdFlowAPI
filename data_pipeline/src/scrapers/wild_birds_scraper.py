from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from src.constants.environment_constants import CHROMEDRIVER_PATH
import time
import os

# Set custom directory to put downloaded files
download_dir = os.path.abspath("data/scraped_data")
os.makedirs(download_dir, exist_ok=True)

chrome_options = Options()
prefs = {
    "download.default_directory": download_dir,
    "download.prompt_for_download": False,
    "download.directory_upgrade": True,
    "safebrowsing.enabled": True
}
chrome_options.add_experimental_option("prefs", prefs)
chrome_options.add_argument("--log-level=3")
chrome_options.add_argument("--headless=new")
chrome_options.add_argument("--window-size=1920,1080")
chrome_options.add_argument("--user-data-dir=/tmp/chrome-wildbirds")
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")

service = Service(CHROMEDRIVER_PATH)

url = "https://www.aphis.usda.gov/livestock-poultry-disease/avian/avian-influenza/hpai-detections/wild-birds"

driver = webdriver.Chrome(service=service, options=chrome_options)
driver.get(url)

# Click "CSV" button
csv_download_xpath = '//*[@id="DataTables_Table_0_wrapper"]/div[1]/div[1]/div/button[1]'
csv_download_button = WebDriverWait(driver, 10).until(
    EC.element_to_be_clickable((By.XPATH, csv_download_xpath))
)
driver.execute_script("arguments[0].click();", csv_download_button)

# Extra time to observe changes in webpage
time.sleep(2)
