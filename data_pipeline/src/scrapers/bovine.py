from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

# Original page: https://www.aphis.usda.gov/livestock-poultry-disease/avian/avian-influenza/hpai-detections/hpai-confirmed-cases-livestock
url = "https://publicdashboards.dl.usda.gov/t/MRP_PUB/views/VS_Cattle_HPAIConfirmedDetections2024/HPAI2022ConfirmedDetections?%3Aembed=y&%3AisGuestRedirectFromVizportal=y"

driver = webdriver.Chrome()
driver.get(url)

# "Download Data" button
download_btn = WebDriverWait(driver, 15).until(
    EC.element_to_be_clickable((By.XPATH, "//div[@role='button' and @title='Download Crosstab']"))
)
driver.execute_script("arguments[0].click();", download_btn)

time.sleep(5)

# "A Table by Confirmation Date" listbox item
listbox_item = WebDriverWait(driver, 10).until(
    EC.element_to_be_clickable((By.XPATH, "//*[@id='export-crosstab-options-dialog-Dialog-BodyWrapper-Dialog-Body-Id']/div/div[1]/div[2]/div/div/div[7]"))
)
driver.execute_script("arguments[0].scrollIntoView(true);", listbox_item)
driver.execute_script("arguments[0].click();", listbox_item)

# CSV option
csv_option = WebDriverWait(driver, 10).until(
    EC.element_to_be_clickable((By.XPATH, "//label[.//div[text()='CSV']]"))
)
driver.execute_script("arguments[0].click();", csv_option)

time.sleep(5)

# Click "Download" button from pop-up window
popup_download_btn = WebDriverWait(driver, 10).until(
    EC.element_to_be_clickable((By.XPATH, "//*[@id='export-crosstab-options-dialog-Dialog-BodyWrapper-Dialog-Body-Id']/div/div[3]/button"))
)
driver.execute_script("arguments[0].click();", popup_download_btn)

time.sleep(10)