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
# New
chrome_options.add_argument("--user-data-dir=/tmp/chrome-poultry")
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")

service = Service(CHROMEDRIVER_PATH)

# Original webpage: https://www.aphis.usda.gov/livestock-poultry-disease/avian/avian-influenza/hpai-detections/commercial-backyard-flocks
url = "https://publicdashboards.dl.usda.gov/t/MRP_PUB/views/VS_Avian_HPAIConfirmedDetections2022/HPAI2022ConfirmedDetections?:embed=y&:isGuestRedirectFromVizportal=y"

driver = webdriver.Chrome(service=service, options=chrome_options)
driver.get(url)

# "Download Data" button
download_btn = WebDriverWait(driver, 30).until(
    EC.element_to_be_clickable((By.XPATH, "//div[@role='button' and @title='Download Crosstab']"))
)
driver.execute_script("arguments[0].click();", download_btn)

# "A Table by Confirmation Date" listbox item
listbox_item = WebDriverWait(driver, 30).until(
    EC.element_to_be_clickable((By.XPATH, "//div[@role='option' and @title='Affected Totals']"))
)
driver.execute_script("arguments[0].scrollIntoView(true);", listbox_item)
driver.execute_script("arguments[0].click();", listbox_item)
listbox_item = WebDriverWait(driver, 30).until(
    EC.element_to_be_clickable((By.XPATH, "//div[@role='option' and @title='A Table by Confirmation Date']"))
)
driver.execute_script("arguments[0].scrollIntoView(true);", listbox_item)
driver.execute_script("arguments[0].click();", listbox_item)

# CSV option
csv_option = WebDriverWait(driver, 30).until(
    EC.element_to_be_clickable((By.XPATH, "//label[.//div[text()='CSV']]"))
)
driver.execute_script("arguments[0].click();", csv_option)

# Click "Download" button from pop-up window
popup_download_btn = WebDriverWait(driver, 30).until(
    EC.element_to_be_clickable((By.XPATH, '//*[@id="export-crosstab-options-dialog-Dialog-BodyWrapper-Dialog-Body-Id"]/div/div[3]/button'))
)
driver.execute_script("arguments[0].click();", popup_download_btn)

# Extra time to observe changes in webpage
time.sleep(2)

