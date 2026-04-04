import random
from core.state import SceneState, ColumnState, Shape

SHAPES = ["circulo", "square", "triangle"]
COLORS = ["red", "green", "blue", "yellow"]

class SimulationEngine:
    def __init__(self, images, config):
        self.images = images
        self.config = config
        self.target_count = 0

    def next_scene(self):
        columns = []

        for _ in range(3):
            image = None
            shape = None

            # fondo
            if self.config.background_mode == "always":
                image = random.choice(self.images)
            else:
                if random.random() < 0.7:
                    image = random.choice(self.images)

            if image and random.random() < 0.5:

                # 🔥 decidir si es objetivo
                if random.random() < self.config.target_probability:
                    shape_type = self.config.shape
                    color = self.config.color
                else:
                    # figura distractora
                    shape_type = random.choice(SHAPES)
                    color = random.choice(COLORS)

                    # evitar coincidencia accidental con objetivo
                    while (
                        shape_type == self.config.shape and
                        color == self.config.color
                    ):
                        shape_type = random.choice(SHAPES)
                        color = random.choice(COLORS)

                shape = Shape(type=shape_type, color=color)

                # 🎯 contar SOLO objetivos reales
                if (
                    shape_type == self.config.shape and
                    color == self.config.color
                ):
                    self.target_count += 1

            columns.append(ColumnState(image_path=image, shape=shape))

        return SceneState(columns)