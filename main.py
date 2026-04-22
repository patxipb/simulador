import tkinter as tk
from ui.screens.config_screen import ConfigScreen
from ui.screens.simulation_screen import SimulationScreen
from ui.screens.end_screen import EndScreen

class App:
    def __init__(self, root):
        self.root = root
        self.current = None

        self.show_config()

    def _set_screen(self, screen):
        if self.current:
            self.current.destroy()
        self.current = screen
        self.current.pack(fill="both", expand=True)
        self.current.focus_set()
        self.root.update_idletasks()
        self.root.update()

    def show_config(self):
        self._set_screen(ConfigScreen(self.root, self.start_simulation))

    def start_simulation(self, config):
        self._set_screen(SimulationScreen(self.root, config, self.show_end))

    def show_end(self):
        self._set_screen(EndScreen(self.root, on_restart=self.show_config))

def main():
    root = tk.Tk()
    root.title("Simulador de Atención Visual")
    root.state("zoomed")

    #####################
    # Cerrar con Escape #
    root.bind("<Escape>", lambda e: root.destroy())
    #####################     

    App(root)

    root.mainloop()

if __name__ == "__main__":
    main()