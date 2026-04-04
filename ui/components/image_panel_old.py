from tkinter import ttk
import tkinter as tk
from PIL import Image, ImageTk
import random

class ImagePanel(ttk.Frame):
    def __init__(self, parent, image_path):
        super().__init__(parent)

        self.original = Image.open(image_path)

        self.canvas = tk.Canvas(self, highlightthickness=0)
        self.canvas.pack(fill="both", expand=True)

        #self.show_circle = random.choice([True, False])
        self.show_circle = should_show_circle()
        #self.circle_color = random.choice(["red", "green", "blue"])
        self.circle_color = get_random_color()

        self.bind("<Configure>", lambda e: self._resize())
        self.after(50, self._resize)

    def _resize(self):
        w = self.winfo_width()
        h = self.winfo_height()

        if w <= 1 or h <= 1:
            return

        self.canvas.delete("all")

        # === ESCALADO CON PROPORCIÓN ===
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

        # === CENTRADO ===
        x = w // 2
        y = h // 2

        self.canvas.create_image(x, y, image=self.tk_image)

        # === CÍRCULO OPCIONAL ===
        if self.show_circle:
            self._draw_circle(x, y, new_w)

    def _draw_circle(self, cx, cy, image_width):
        # tamaño = 15% del ancho de la imagen
        radius = int(image_width * 0.15 / 2)

        self.canvas.create_oval(
            cx - radius,
            cy - radius,
            cx + radius,
            cy + radius,
            fill=self.circle_color,
            outline=""
        )

def should_show_circle(prob=0.75):
    return random.random() < prob

def get_random_color():
    return random.choice(["red", "green", "blue"])