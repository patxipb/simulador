from tkinter import ttk
from ui.components.image_panel import ImagePanel

class ThreeColumnsLayout(ttk.Frame):
    def __init__(self, parent):
        super().__init__(parent)

        self.panels = []

        self.rowconfigure(0, weight=1)
        for i in range(3):
            self.columnconfigure(i, weight=1)

        for i in range(3):
            panel = ImagePanel(self)
            panel.grid(row=0, column=i, sticky="nsew")
            self.panels.append(panel)

    def render(self, scene_state):
        for i, col_state in enumerate(scene_state.columns):
            self.panels[i].set_state(col_state)