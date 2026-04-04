from dataclasses import dataclass
from typing import Optional

@dataclass
class Shape:
    type: str   # "circle", "square", "triangle"
    color: str

@dataclass
class ColumnState:
    image_path: Optional[str] = None
    shape: Optional[Shape] = None

@dataclass
class SceneState:
    columns: list[ColumnState]