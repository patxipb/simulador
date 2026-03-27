from tkinter import ttk
from services.image_service import get_random_columns
from ui.components.image_panel import ImagePanel

class ThreeColumnsLayout(ttk.Frame):
    def __init__(self, parent, image_path):
        super().__init__(parent)

        self.columns = []
        self.image_path = image_path

        # Layout responsive SIEMPRE 3 columnas iguales
        self.rowconfigure(0, weight=1)
        for i in range(3):
            self.columnconfigure(i, weight=1)

        # Crear columnas SIEMPRE
        for i in range(3):
            frame = ttk.Frame(self)
            frame.grid(row=0, column=i, sticky="nsew")

            frame.rowconfigure(0, weight=1)
            frame.columnconfigure(0, weight=1)

            self.columns.append(frame)

        self.render_images()

    def render_images(self):
        # Limpiar contenido (NO eliminar columnas)
        for col in self.columns:
            for widget in col.winfo_children():
                widget.destroy()

        # Elegir columnas con imagen
        selected = get_random_columns()

        # Insertar imagen SOLO en algunas columnas
        for i in selected:
            panel = ImagePanel(self.columns[i], self.image_path)
            panel.grid(row=0, column=0, sticky="nsew")