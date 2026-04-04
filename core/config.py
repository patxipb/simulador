from dataclasses import dataclass

@dataclass
class ExerciseConfig:
    shape: str        # "circle", "square", "triangle"
    color: str        # "red", "green", etc
    duration: int     # ms visible
    repetitions: int  # nº veces objetivo
    background_mode: str   # "random" | "always"
    target_probability: float  # 0.0 - 1.0