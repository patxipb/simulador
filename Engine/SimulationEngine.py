import random
from core.state import SceneState, ColumnState, Circle

class SimulationEngine:
    def __init__(self, images, config):
        self.images = images
        self.config = config
        self.target_count = 0

    def next_scene(self):
        columns = []

        for _ in range(3):
            # lógica existente...

            # ejemplo simplificado
            circle = None

            if random.random() < 0.5:
                color = random.choice(["red", "green", "blue", "yellow"])

                circle = Circle(color=color)

                # 👇 detectar objetivo
                if color == self.config.color and self.config.shape == "circle":
                    self.target_count += 1

            columns.append(ColumnState(image_path=..., circle=circle))

        return SceneState(columns)