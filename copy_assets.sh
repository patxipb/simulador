#!/usr/bin/env bash
set -euo pipefail

# copy_assets.sh
# Copia imágenes y audio desde el repo "patxipb/figuras" hacia un proyecto "simulador".
# Uso:
#   ./copy_assets.sh [--figuras <path_or_git_url>] [--simulador <path>] [--audio-file <path>] [--keep-clone]
#
# Comportamiento por defecto:
# - Clona https://github.com/patxipb/figuras.git en un directorio temporal si no se proporciona --figuras.
# - Usa ./simulador como destino si no se proporciona --simulador.
# - Copia figuras/image/* -> <simulador>/assets/images/ (preserva subcarpetas).
# - Busca el primer archivo de audio encontrado (*.mp3, *.wav) en el repo figuras; si encuentra varios
#   prioriza nombres que contengan 'disparo' o 'sonido'. Copia ese archivo a <simulador>/assets/audio/disparo.<ext>.
# - Si quieres forzar un archivo de audio concreto usa --audio-file <ruta_local_o_remote>.
# - Opcional: si detecta que flutter está instalado y que el destino tiene pubspec.yaml, ejecuta 'flutter pub get'.

# Defaults
FIGURAS_SOURCE=""
SIMULADOR_DIR="./simulador"
FORCE_AUDIO_FILE=""
KEEP_CLONE=false

print_help() {
  cat <<EOF
Uso: $0 [opciones]

Opciones:
  --figuras <path_or_git_url>   Ruta local a repo figuras o URL git. Si no se pasa, se clona https://github.com/patxipb/figuras.git en un tmpdir.
  --simulador <path>            Ruta al proyecto simulador (por defecto ./simulador).
  --audio-file <path>           Forzar uso de este archivo de audio (ruta local). Si se pasa, se copia y renombra a disparo.<ext>.
  --keep-clone                  Si se clona el repo figuras en tmpdir, lo conserva en lugar de borrarlo.
  -h, --help                    Mostrar esta ayuda.
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --figuras)
      FIGURAS_SOURCE="$2"; shift 2;;
    --simulador)
      SIMULADOR_DIR="$2"; shift 2;;
    --audio-file)
      FORCE_AUDIO_FILE="$2"; shift 2;;
    --keep-clone)
      KEEP_CLONE=true; shift 1;;
    -h|--help)
      print_help; exit 0;;
    *)
      echo "Opción desconocida: $1"; print_help; exit 1;;
  esac
done

# Helper to absolute path
abspath() {
  python3 - <<PY - "$1"
import os,sys
print(os.path.abspath(sys.argv[1]))
PY
}

echo "Destino simulador: $SIMULADOR_DIR"

# Ensure simulador dir exists (if not, create it)
if [[ ! -d "$SIMULADOR_DIR" ]]; then
  echo "Directorio destino '$SIMULADOR_DIR' no existe. Creándolo..."
  mkdir -p "$SIMULADOR_DIR"
fi

# Prepare figuras source: either local path or clone remote
CLONED_TMP_DIR=""
FIGURAS_DIR=""

if [[ -n "$FIGURAS_SOURCE" ]]; then
  # If provided source looks like a git URL (starts with http or git@), clone it
  if [[ "$FIGURAS_SOURCE" =~ ^https?:// ]] || [[ "$FIGURAS_SOURCE" =~ ^git@ ]]; then
    echo "Clonando $FIGURAS_SOURCE ..."
    CLONED_TMP_DIR="$(mktemp -d)"
    git clone --depth 1 "$FIGURAS_SOURCE" "$CLONED_TMP_DIR"
    FIGURAS_DIR="$CLONED_TMP_DIR"
  else
    # treat as local path
    if [[ -d "$FIGURAS_SOURCE" ]]; then
      FIGURAS_DIR="$FIGURAS_SOURCE"
    else
      echo "Error: la ruta proporcionada en --figuras no existe: $FIGURAS_SOURCE"
      exit 1
    fi
  fi
else
  # Clone default remote repo
  DEFAULT_REPO="https://github.com/patxipb/figuras.git"
  echo "No se proporcionó --figuras, clonando repo por defecto: $DEFAULT_REPO"
  CLONED_TMP_DIR="$(mktemp -d)"
  git clone --depth 1 "$DEFAULT_REPO" "$CLONED_TMP_DIR"
  FIGURAS_DIR="$CLONED_TMP_DIR"
fi

echo "Repo figuras localizado en: $FIGURAS_DIR"

# Look for image folder(s)
IMAGE_SRC_DIRS=()
# Common folder name observed: image
if [[ -d "$FIGURAS_DIR/image" ]]; then
  IMAGE_SRC_DIRS+=("$FIGURAS_DIR/image")
fi
# also accept 'images' etc.
if [[ -d "$FIGURAS_DIR/images" ]]; then
  IMAGE_SRC_DIRS+=("$FIGURAS_DIR/images")
fi

# If none found, search for png/jpg files and pick their parent dir
if [[ ${#IMAGE_SRC_DIRS[@]} -eq 0 ]]; then
  echo "No se encontró carpeta image/ ni images/. Buscando archivos de imagen en el repo..."
  mapfile -t found_images < <(find "$FIGURAS_DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.svg' \) -printf '%h\n' | sort -u)
  if [[ ${#found_images[@]} -gt 0 ]]; then
    echo "Se han encontrado directorios con imágenes. Usando el primero: ${found_images[0]}"
    IMAGE_SRC_DIRS+=("${found_images[0]}")
  fi
fi

if [[ ${#IMAGE_SRC_DIRS[@]} -eq 0 ]]; then
  echo "Aviso: no se han encontrado imágenes en el repo figuras."
else
  echo "Directorios de imágenes detectados:"
  for d in "${IMAGE_SRC_DIRS[@]}"; do echo "  - $d"; done
fi

# Prepare destination dirs
DEST_IMAGES_DIR="$SIMULADOR_DIR/assets/images"
DEST_AUDIO_DIR="$SIMULADOR_DIR/assets/audio"

mkdir -p "$DEST_IMAGES_DIR"
mkdir -p "$DEST_AUDIO_DIR"

# Copy images (preserving subfolders)
if [[ ${#IMAGE_SRC_DIRS[@]} -gt 0 ]]; then
  echo "Copiando imágenes a $DEST_IMAGES_DIR ..."
  for src in "${IMAGE_SRC_DIRS[@]}"; do
    # copy contents preserving structure: if src == FIGURAS_DIR/image, copy contents directly into assets/images
    # use rsync if available for nicer behavior, otherwise cp -r
    if command -v rsync >/dev/null 2>&1; then
      rsync -av --exclude='.git' "$src"/ "$DEST_IMAGES_DIR"/
    else
      cp -r "$src"/. "$DEST_IMAGES_DIR"/
    fi
  done
  echo "Imágenes copiadas."
fi

# Determine audio file to copy
AUDIO_TO_COPY=""

if [[ -n "$FORCE_AUDIO_FILE" ]]; then
  if [[ -f "$FORCE_AUDIO_FILE" ]]; then
    AUDIO_TO_COPY="$FORCE_AUDIO_FILE"
    echo "Usando audio forzado: $AUDIO_TO_COPY"
  else
    echo "Error: archivo especificado en --audio-file no existe: $FORCE_AUDIO_FILE"
    # continue to try auto-detect
  fi
fi

if [[ -z "$AUDIO_TO_COPY" ]]; then
  echo "Buscando archivos de audio (*.mp3, *.wav) en $FIGURAS_DIR ..."
  mapfile -t audios < <(find "$FIGURAS_DIR" -type f \( -iname '*.mp3' -o -iname '*.wav' -o -iname '*.ogg' \) -print)

  if [[ ${#audios[@]} -eq 0 ]]; then
    echo "No se encontraron archivos de audio en el repo figuras."
  else
    # Prefer files that include 'disparo' or 'sonido' or 'shot' in name (case-insensitive)
    preferred=""
    for a in "${audios[@]}"; do
      lower=$(basename "$a" | tr '[:upper:]' '[:lower:]')
      if [[ "$lower" == *dispar* ]] || [[ "$lower" == *sonido* ]] || [[ "$lower" == *shot* ]] || [[ "$lower" == *fire* ]]; then
        preferred="$a"
        break
      fi
    done
    if [[ -n "$preferred" ]]; then
      AUDIO_TO_COPY="$preferred"
    else
      # use first audio found
      AUDIO_TO_COPY="${audios[0]}"
    fi
    echo "Audio seleccionado: $AUDIO_TO_COPY"
  fi
fi

# If an audio was selected, copy and rename to disparo.<ext>
if [[ -n "${AUDIO_TO_COPY:-}" ]]; then
  ext="${AUDIO_TO_COPY##*.}"
  target_audio="$DEST_AUDIO_DIR/disparo.$ext"
  echo "Copiando audio a $target_audio ..."
  cp "$AUDIO_TO_COPY" "$target_audio"
  echo "Audio copiado."
  AUDIO_FINAL="$target_audio"
else
  echo "No se ha copiado ningún audio. Para pruebas puedes añadir manualmente un MP3/WAV a $DEST_AUDIO_DIR y nombrarlo disparo.mp3 (o ajustar lib/services/audio_service.dart)."
  AUDIO_FINAL=""
fi

# Optionally run flutter pub get if flutter exists and pubspec.yaml present
if command -v flutter >/dev/null 2>&1 && [[ -f "$SIMULADOR_DIR/pubspec.yaml" ]]; then
  echo "Ejecutando 'flutter pub get' en $SIMULADOR_DIR ..."
  (cd "$SIMULADOR_DIR" && flutter pub get)
else
  echo "Omitiendo 'flutter pub get' (flutter no encontrado o pubspec.yaml ausente en destino)."
fi

# Cleanup cloned repo if it was created and user didn't request to keep it
if [[ -n "$CLONED_TMP_DIR" && "$KEEP_CLONE" = false ]]; then
  echo "Eliminando clone temporal $CLONED_TMP_DIR ..."
  rm -rf "$CLONED_TMP_DIR"
fi

# Summary
echo "------ Resumen ------"
echo "Destino imágenes: $DEST_IMAGES_DIR"
if [[ -d "$DEST_IMAGES_DIR" ]]; then
  echo "Total archivos en assets/images: $(find "$DEST_IMAGES_DIR" -type f | wc -l)"
fi
if [[ -n "$AUDIO_FINAL" ]]; then
  echo "Archivo de audio final: $AUDIO_FINAL"
else
  echo "No se añadió audio. Añade un mp3/wav a $DEST_AUDIO_DIR o usa --audio-file para forzar uno."
fi

echo "Listo. Revisa que los nombres de archivo no contengan espacios problemáticos. Si los hay, renómbralos o actualiza referencias en tu código Flutter."
echo "Si el archivo de audio no es mp3, actualiza lib/services/audio_service.dart para usar la extensión correcta (disparo.$ext)."
