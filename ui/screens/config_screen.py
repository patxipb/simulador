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
        ttk.Label(self, text="Configuración").grid(row=0, column=0, columnspan=2, pady=20)

        # Forma
        ttk.Label(self, text="Figura").grid(row=1, column=0)
        ttk.Combobox(self, textvariable=self.shape, values=list(SHAPES.values())).grid(row=1, column=1)

        # Color
        ttk.Label(self, text="Color").grid(row=2, column=0)
        ttk.Combobox(self, textvariable=self.color, values=list(COLORS.values())).grid(row=2, column=1)

        # Duración
        ttk.Label(self, text="Duración (ms)").grid(row=3, column=0)
        ttk.Entry(self, textvariable=self.duration).grid(row=3, column=1)

        # Repeticiones
        ttk.Label(self, text="Repeticiones").grid(row=4, column=0)
        ttk.Entry(self, textvariable=self.repetitions).grid(row=4, column=1)

        ttk.Label(self, text="Fondo").grid(row=5, column=0)

        # Modo de fondo
        ttk.Combobox(
            self,
            textvariable=self.bg_mode,
            values=list(BACKGROUND_MODES.values()),
            state="readonly"
        ).grid(row=5, column=1)

        ttk.Label(self, text="Dificultad").grid(row=6, column=0)

        # Dificultad
        ttk.Combobox(
            self,
            textvariable=self.difficulty,
            values=list(DIFFICULTY.values()),
            state="readonly"
        ).grid(row=6, column=1)

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