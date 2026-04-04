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

        self._loop()

    def _loop(self):
        if self.engine.target_count >= self.config.repetitions:
            self.after(5000, self.on_finish)  # pausa 5s
            return

        state = self.engine.next_scene()
        self.layout.render(state)

        self.after(self.config.duration, self._loop)