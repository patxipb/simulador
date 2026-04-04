SHAPES = {
    "circle": "Círculo",
    "square": "Cuadrado",
    "triangle": "Triángulo"
}

COLORS = {
    "red": "Rojo",
    "green": "Verde",
    "blue": "Azul",
    "yellow": "Amarillo"
}

INV_SHAPES = {v: k for k, v in SHAPES.items()}
INV_COLORS = {v: k for k, v in COLORS.items()}

BACKGROUND_MODES = {
    "random": "Aleatorio",
    "always": "Siempre visible"
}

INV_BACKGROUND_MODES = {v: k for k, v in BACKGROUND_MODES.items()}

DIFFICULTY = {
    "easy": "Fácil",
    "medium": "Media",
    "hard": "Difícil"
}

INV_DIFFICULTY = {v: k for k, v in DIFFICULTY.items()}

DIFFICULTY_VALUES = {
    "easy": 0.7,
    "medium": 0.4,
    "hard": 0.2
}