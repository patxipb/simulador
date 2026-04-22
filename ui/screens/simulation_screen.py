from tkinter import ttk
from core.engine import SimulationEngine
from ui.layouts.three_columns import ThreeColumnsLayout

class SimulationScreen(ttk.Frame):
    def __init__(self, parent, config, on_finish):
        super().__init__(parent)

        self.config = config
        self.on_finish = on_finish

        self.layout = ThreeColumnsLayout(self)
        self.layout.pack(fill="both", expand=True)

        self.engine = SimulationEngine(
            ["assets/images/figura_sola.png"],
            config
        )

        self._show_blank = True
        self._loop()

    def _loop(self):
        if self.engine.target_count >= self.config.repetitions:
            self.after(5000, self.on_finish)  # pausa 5s
            return

        if self._show_blank:
            # Pantalla de transición: solo fondo, sin figuras objetivo
            from core.state import SceneState, ColumnState
            blank_state = SceneState([ColumnState(image_path="assets/images/figura_sola.png", shape=None) for _ in range(3)])
            self.layout.render(blank_state)
            self._show_blank = False
            self.after(self.config.blank_duration, self._loop)
        else:
            state = self.engine.next_scene()
            self.layout.render(state)
            self._show_blank = True
            self.after(self.config.duration, self._loop)