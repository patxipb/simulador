import tkinter as tk
from tkinter import ttk

class EndScreen(ttk.Frame):
    def __init__(self, parent):
        super().__init__(parent)

        self.label = tk.Label(self, text="Fin del ejercicio", anchor="center", font=("TkDefaultFont", 42))
        self.label.pack(expand=True)