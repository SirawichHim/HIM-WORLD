OBJECTIVE : i'm lazy to copy paste and enter for query data on my company tool
import time
import pyautogui
import pyperclip
import tkinter as tk
from threading import Thread

class AutoKeywordApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Program_name")
        
        self.file_name_entry = tk.Entry(root)
        self.file_name_entry.pack()
        
        self.start_button = tk.Button(root, text="Start (Enter)", command=self.start_automation)
        self.start_button.pack()
        
        self.pause_button = tk.Button(root, text="Pause (ESC)", command=self.pause_automation)
        self.pause_button.pack()
        
        self.word_list = []
        
        self.root.bind("<Return>", lambda event: self.start_automation())  # Bind Enter key
        self.root.bind("<Escape>", lambda event: self.pause_automation())  # Bind ESC key

    def start_automation(self):
        self.running = True
        self.paused = False
        self.read_keywords()
        self.automation_thread = Thread(target=self.run_automation)
        self.automation_thread.start()

    def pause_automation(self):
        self.paused = not self.paused

    def read_keywords(self):
        file_name = self.file_name_entry.get()
        print(f"Reading keywords from file: {file_name}")  # Debug line
        self.word_list = []  
        try:
            with open(file_name, 'r', encoding='utf-8') as file:
                self.word_list = file.read().splitlines()
            print(f"Loaded {len(self.word_list)} keywords from {file_name}")
        except FileNotFoundError:
            print(f"File {file_name} not found")

    def run_automation(self):
        time.sleep(5)  
        for word in self.word_list:
            if not self.running:
                break
            if self.paused:
                while self.paused:
                    time.sleep(1)
            pyperclip.copy(word)
            pyautogui.hotkey('ctrl', 'v')
            pyautogui.press('enter')
            time.sleep(1)

if __name__ == "__main__":
    root = tk.Tk()
    app = AutoKeywordApp(root)
    root.mainloop()
