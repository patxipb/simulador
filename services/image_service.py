import random

def get_random_columns(num_columns=3, probability=1.0):
    """
    Devuelve una lista de columnas donde se mostrará la imagen.
    """
    return [i for i in range(num_columns) if random.random() < probability]