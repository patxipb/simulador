import tkinter as tk
from tkinter import ttk
from core.config import ExerciseConfig
from utils.translations import SHAPES, COLORS, INV_SHAPES, INV_COLORS, BACKGROUND_MODES, INV_BACKGROUND_MODES, DIFFICULTY, INV_DIFFICULTY, DIFFICULTY_VALUES

class ConfigScreen(ttk.Frame):
    def __init__(self, parent, on_start):
        super().__init__(parent)

        self.on_start = on_start

        # Variables
        self.shape = tk.StringVar(value=list(SHAPES.values())[0])
        self.color = tk.StringVar(value=list(COLORS.values())[0])
        self.duration = tk.IntVar(value=1000)
        self.repetitions = tk.IntVar(value=5)
        self.bg_mode = tk.StringVar(value=BACKGROUND_MODES["random"])
        self.difficulty = tk.StringVar(value=DIFFICULTY["medium"])

        self._build()

    def _build(self):

        tk.Label(self, text="Configuración", font=("TkDefaultFont", 32)).grid(row=0, column=0, columnspan=2, pady=20)


        # Forma
        tk.Label(self, text="Figura", font=("TkDefaultFont", 20)).grid(row=1, column=0)

        om_shape = tk.OptionMenu(self, self.shape, *SHAPES.values())
        om_shape.config(font=("TkDefaultFont", 20))
        om_shape['menu'].config(font=("TkDefaultFont", 20))
        om_shape.grid(row=1, column=1, sticky="ew")

        # Color
        tk.Label(self, text="Color", font=("TkDefaultFont", 20)).grid(row=2, column=0)

        om_color = tk.OptionMenu(self, self.color, *COLORS.values())
        om_color.config(font=("TkDefaultFont", 20))
        om_color['menu'].config(font=("TkDefaultFont", 20))
        om_color.grid(row=2, column=1, sticky="ew")

        # Duración
        tk.Label(self, text="Duración (ms)", font=("TkDefaultFont", 20)).grid(row=3, column=0)
        ttk.Entry(self, textvariable=self.duration, font=("TkDefaultFont", 20)).grid(row=3, column=1)

        # Repeticiones
        tk.Label(self, text="Repeticiones", font=("TkDefaultFont", 20)).grid(row=4, column=0)
        ttk.Entry(self, textvariable=self.repetitions, font=("TkDefaultFont", 20)).grid(row=4, column=1)

        tk.Label(self, text="Fondo", font=("TkDefaultFont", 20)).grid(row=5, column=0)

        om_bg = tk.OptionMenu(self, self.bg_mode, *BACKGROUND_MODES.values())
        om_bg.config(font=("TkDefaultFont", 20))
        om_bg['menu'].config(font=("TkDefaultFont", 20))
        om_bg.grid(row=5, column=1, sticky="ew")

        tk.Label(self, text="Dificultad", font=("TkDefaultFont", 20)).grid(row=6, column=0)

        om_diff = tk.OptionMenu(self, self.difficulty, *DIFFICULTY.values())
        om_diff.config(font=("TkDefaultFont", 20))
        om_diff['menu'].config(font=("TkDefaultFont", 20))
        om_diff.grid(row=6, column=1, sticky="ew")

        # Botón
        ttk.Button(self, text="Iniciar", command=self._start).grid(row=7, column=0, columnspan=2, pady=20)

    def _start(self):
        difficulty_key = INV_DIFFICULTY[self.difficulty.get()]

        config = ExerciseConfig(
            shape=INV_SHAPES[self.shape.get()],
            color=INV_COLORS[self.color.get()],
            duration=self.duration.get(),
            repetitions=self.repetitions.get(),
            background_mode=INV_BACKGROUND_MODES[self.bg_mode.get()],
            target_probability=DIFFICULTY_VALUES[difficulty_key]
        )
        self.on_start(config)