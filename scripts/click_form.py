import pyautogui
import time
import os

print("Waiting 3s for app to be ready...")
time.sleep(3)

print("Taking screenshot of home...")
pyautogui.screenshot("home_screen.png")

# Click on Quick Access -> Observation Reports
print("Clicking Observation Reports...")
# Assuming it's in the middle of the screen based on previous runs
pyautogui.click(800, 450)
time.sleep(2)

print("Taking screenshot of specialty selection...")
pyautogui.screenshot("specialty_screen.png")

# Click Cardiology (second row, first item)
print("Clicking Cardiology...")
pyautogui.click(200, 300)
time.sleep(2)

print("Taking screenshot of the new form (top)...")
pyautogui.screenshot("new_form_top.png")

# Scroll down slightly to see the rest of the form
pyautogui.scroll(-50)
time.sleep(1)

print("Taking screenshot of the new form (bottom)...")
pyautogui.screenshot("new_form_bottom.png")

print("Done capturing screenshots.")
