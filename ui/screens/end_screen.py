import tkinter as tk
from tkinter import ttk

class EndScreen(ttk.Frame):
    def __init__(self, parent, on_restart=None):
        super().__init__(parent)

        # El contenedor principal ocupa todo y centra su contenido
        self.grid_rowconfigure(0, weight=1)
        self.grid_columnconfigure(0, weight=1)

        # Frame contenedor central
        content = ttk.Frame(self)
        content.grid(row=0, column=0)

        # --- TÍTULO ---
        self.label = tk.Label(
            content,
            text="Fin del ejercicio",
            anchor="center",
            font=("TkDefaultFont", 42)
        )
        self.label.grid(row=0, column=0, pady=(0, 40))

        # --- BOTONES ---
        button_frame = ttk.Frame(content)
        button_frame.grid(row=1, column=0)

        # Estilo botones
        base_font = ("TkDefaultFont", int(20 * 1.1))
        btn_style = ttk.Style()
        btn_style.configure("Big.TButton", font=base_font, padding=(20, 15))

        btn_salir = ttk.Button(
            button_frame,
            text="Cerrar programa",
            command=self.quit_app,
            style="Big.TButton"
        )
        btn_salir.grid(row=0, column=0, padx=20)

        btn_reiniciar = ttk.Button(
            button_frame,
            text="Volver a configuración",
            command=on_restart if on_restart else self.default_restart,
            style="Big.TButton"
        )
        btn_reiniciar.grid(row=0, column=1, padx=20)

        # Forzar foco
        self.after(10, self._force_focus)

    def _force_focus(self):
        self.focus_set()
        self.update_idletasks()
        self.update()

    def quit_app(self):
        self.winfo_toplevel().destroy()

    def default_restart(self):
        self.pack_forget()