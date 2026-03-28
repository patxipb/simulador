from tkinter import ttk
from PIL import Image, ImageTk

class ImagePanel(ttk.Frame):
    def __init__(self, parent, image_path):
        super().__init__(parent)

        self.original = Image.open(image_path)

        self.rowconfigure(0, weight=1)
        self.columnconfigure(0, weight=1)

        self.label = ttk.Label(self, anchor="center")
        self.label.grid(row=0, column=0)

        self.after(50, self._resize)  # 🔑 primera renderización correcta
        self.bind("<Configure>", lambda e: self._resize())

    def _resize(self):
        w = self.winfo_width()
        h = self.winfo_height()

        if w <= 1 or h <= 1:
            return

        img_ratio = self.original.width / self.original.height
        frame_ratio = w / h

        if frame_ratio > img_ratio:
            new_h = h
            new_w = int(h * img_ratio)
        else:
            new_w = w
            new_h = int(w / img_ratio)

        resized = self.original.resize((new_w, new_h), Image.LANCZOS)
        self.tk_image = ImageTk.PhotoImage(resized)

        self.label.config(image=self.tk_image)

        # 🔑 CENTRADO REAL
        self.label.place(relx=0.5, rely=0.5, anchor="center")