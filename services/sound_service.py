import threading
import os
import sys

try:
    from playsound import playsound
except ImportError:
    playsound = None

# Fallback para macOS sin playsound instalado
if playsound is None and sys.platform == "darwin":
    import subprocess
    def playsound(path, block=True):
        subprocess.Popen(["afplay", path])


def play_sound(path):
    # Reproduce el sonido en un hilo para no bloquear la UI
    threading.Thread(target=playsound, args=(path,), daemon=True).start()
