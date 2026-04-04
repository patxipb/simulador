from tkinter import ttk
import tkinter as tk
from PIL import Image, ImageTk
import random

class ImagePanel(ttk.Frame):
    def __init__(self, parent):
        super().__init__(parent)

        self.canvas = tk.Canvas(self, highlightthickness=0)
        self.canvas.pack(fill="both", expand=True)

        self.image = None
        self.circle = None
        self.original = None
        self.shape = None

        self.bind("<Configure>", lambda e: self._render())

    def set_state(self, column_state):
        self.image = column_state.image_path
        self.shape = column_state.shape

        if self.image:
            from PIL import Image
            self.original = Image.open(self.image)
        else:
            self.original = None

        self._render()


    def _render(self):
        w = self.winfo_width()
        h = self.winfo_height()

        if w <= 1 or h <= 1:
            return

        self.canvas.delete("all")

        if not self.original:
            return

        from PIL import ImageTk, Image

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

        cx, cy = w // 2, h // 2

        self.canvas.create_image(cx, cy, image=self.tk_image)

        # 🔥 DIBUJAR SHAPE
        if self.shape:
            self._draw_shape(cx, cy, new_w)

    def _draw_shape(self, cx, cy, image_width):
        size = int(image_width * 0.1)
        half = size // 2

        shape_type = self.shape.type
        color = self.shape.color

        if shape_type == "circle":
            self.canvas.create_oval(
                cx - half, cy - half,
                cx + half, cy + half,
                fill=color, outline=""
            )

        elif shape_type == "square":
            self.canvas.create_rectangle(
                cx - half, cy - half,
                cx + half, cy + half,
                fill=color, outline=""
            )

        elif shape_type == "triangle":
            self.canvas.create_polygon(
                cx, cy - half,          # arriba
                cx - half, cy + half,   # abajo izquierda
                cx + half, cy + half,   # abajo derecha
                fill=color, outline=""
            )