from tkinter import ttk

class EndScreen(ttk.Frame):
    def __init__(self, parent):
        super().__init__(parent)

        self.label = ttk.Label(self, text="Fin del ejercicio", anchor="center")
        self.label.pack(expand=True)