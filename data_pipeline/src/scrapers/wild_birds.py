from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

url = "https://www.aphis.usda.gov/livestock-poultry-disease/avian/avian-influenza/hpai-detections/wild-birds"

driver = webdriver.Chrome()
driver.get(url)

# Click "CSV" button
csv_download_xpath = '//*[@id="DataTables_Table_0_wrapper"]/div[1]/div[1]/div/button[1]'
csv_download_button = WebDriverWait(driver, 10).until(
    EC.element_to_be_clickable((By.XPATH, csv_download_xpath))
)
driver.execute_script("arguments[0].click();", csv_download_button)

# Extra time to observe changes in webpage
time.sleep(10)
