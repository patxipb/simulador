from tkinter import ttk
from PIL import Image, ImageTk

class ImagePanel(ttk.Frame):
    def __init__(self, parent, image_path):
        super().__init__(parent)

        self.image_path = image_path
        self.label = ttk.Label(self)
        self.label.pack(expand=True, fill="both")

        self.original = Image.open(self.image_path)

        self.bind("<Configure>", self._resize)

    def _resize(self, event):
        if event.width > 0 and event.height > 0:
            img = self.original.copy()
            img.thumbnail((event.width, event.height))  # mantiene proporción

            self.tk_image = ImageTk.PhotoImage(img)
            self.label.config(image=self.tk_image)