import tkinter as tk
from tkinter import ttk
from ui.layouts.three_columns import ThreeColumnsLayout

RUTA_IMAGEN = "assets/images/figura_sola.png"

def main():
    root = tk.Tk()
    root.title("Simulador")
    root.state("zoomed")

    #####################
    # Cerrar con Escape #
    root.bind("<Escape>", lambda e: root.destroy())
    #####################      

    root.rowconfigure(0, weight=1)
    root.columnconfigure(0, weight=1)

    layout = ThreeColumnsLayout(root, RUTA_IMAGEN)
    layout.grid(sticky="nsew")

    root.mainloop()

if __name__ == "__main__":
    main()