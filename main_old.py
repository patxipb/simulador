import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk

RUTA_IMAGEN = "assets/images/figura_sola.png"

def main():
    root = tk.Tk()
    root.title("App con ttk")
    root.state("zoomed")

    root.bind("<Escape>", lambda e: root.destroy())

    # Layout raíz
    root.rowconfigure(0, weight=1)
    for i in range(3):
        root.columnconfigure(i, weight=1)

    # Contenedores (columnas)
    columnas = []
    labels = []

    for i in range(3):
        frame = ttk.Frame(root)
        frame.grid(row=0, column=i, sticky="nsew")
        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=1)

        label = ttk.Label(frame)
        label.grid(sticky="nsew")

        columnas.append(frame)
        labels.append(label)

    # Cargar imagen original
    imagen_original = Image.open(RUTA_IMAGEN)

    def redimensionar(event):
        for i, frame in enumerate(columnas):
            ancho = frame.winfo_width()
            alto = frame.winfo_height()

            if ancho > 0 and alto > 0:
                img = imagen_original.resize((ancho, alto))
                img_tk = ImageTk.PhotoImage(img)

                labels[i].config(image=img_tk)
                labels[i].image = img_tk  # evitar garbage collection

    # Evento de resize
    root.bind("<Configure>", redimensionar)

    root.mainloop()

if __name__ == "__main__":
    main()