# 1st You have to run "pip install pyautogui pyperclip" on command prompt
# 2nd You can change the name "file.txt" to something else in line 7, such as "keyword.txt" like I did.
import time
import pyautogui
import pyperclip

with open('keyword.txt', 'r', encoding='utf-8') as file:
    word_list = file.read().splitlines()

# Setting time to switch to the target window : Recommend 5 
time.sleep(5)

# Loop through the words and automate the process
for word in word_list:
    # Copy word to clipboard
    pyperclip.copy(word)
    
    # Simulate paste and enter
    pyautogui.hotkey('ctrl', 'v')
    pyautogui.press('enter')
    
    # Setting time for pasting next word
    time.sleep(1)

# Actually, You can add stop function through "ESC" but you have to install keyboard on command prompt "pip install keyboard" 
import time
import pyautogui
import pyperclip
import keyboard

with open('keyword.txt', 'r', encoding='utf-8') as file:
    word_list = file.read().splitlines()

# Setting time to switch to the target window : Recommend 5
time.sleep(5)

# Loop through the words and automate the process
try:
    for word in word_list:
        if keyboard.is_pressed('Esc'):  # You can change to others
            print("Script stopped by user.")
            break

        # Copy word to clipboard
        pyperclip.copy(word)
        
        # Simulate paste and enter
        pyautogui.hotkey('ctrl', 'v')
        pyautogui.press('enter')
        
       # Setting time for pasting next word
        time.sleep(1)
except Exception as e:
    print("An error occurred:", e)

