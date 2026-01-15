#!/usr/bin/env bash
set -euo pipefail

# copy_assets_rename.sh
# Copia imágenes y audio desde el repo "patxipb/figuras" hacia un proyecto "simulador".
# Además renombra automáticamente archivos y carpetas que contienen espacios por guiones bajos (_),
# a menos que pases --no-rename-spaces.
#
# Uso:
#   ./copy_assets_rename.sh [--figuras <path_or_git_url>] [--simulador <path>] [--audio-file <path>]
#                            [--keep-clone] [--no-rename-spaces] [--dry-run]
#
# Opciones:
#   --figuras <path_or_git_url>   Ruta local o URL git del repo figuras. Si no se pasa, se clona
#                                 https://github.com/patxipb/figuras.git en un tmpdir.
#   --simulador <path>            Ruta al proyecto simulador (por defecto ./simulador).
#   --audio-file <path>           Forzar uso de este archivo de audio (ruta local).
#   --keep-clone                  Si se clona el repo figuras en tmpdir, lo conserva.
#   --no-rename-spaces            No renombrar archivos/carpetas con espacios.
#   --dry-run                     Mostrar qué se haría (copias y renombrados) sin modificar nada.
#   -h, --help                    Mostrar ayuda.
#
# Comportamiento:
#  - Copia figuras/image/* -> <simulador>/assets/images/ (preserva subcarpetas).
#  - Busca el primer audio en el repo (mp3/wav/ogg) priorizando nombres con 'dispar'/'sonido'/'shot',
#    y lo copia a <simulador>/assets/audio/disparo.<ext>.
#  - Luego renombra (si no se desactiva) archivos y carpetas en assets/ reemplazando espacios por '_'.
#  - En modo --dry-run solo muestra operaciones sin realizarlas.

# Defaults
FIGURAS_SOURCE=""
SIMULADOR_DIR="./simulador"
FORCE_AUDIO_FILE=""
KEEP_CLONE=false
RENAME_SPACES=true
DRY_RUN=false

print_help() {
  cat <<EOF
Uso: $0 [opciones]

Opciones:
  --figuras <path_or_git_url>   Ruta local a repo figuras o URL git. Si no se pasa, se clona https://github.com/patxipb/figuras.git en un tmpdir.
  --simulador <path>            Ruta al proyecto simulador (por defecto ./simulador).
  --audio-file <path>           Forzar uso de este archivo de audio (ruta local).
  --keep-clone                  Si se clona el repo figuras en tmpdir, lo conserva en lugar de borrarlo.
  --no-rename-spaces            No renombrar archivos/carpetas con espacios.
  --dry-run                     Mostrar acciones sin ejecutarlas.
  -h, --help                    Mostrar esta ayuda.
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --figuras) FIGURAS_SOURCE="$2"; shift 2;;
    --simulador) SIMULADOR_DIR="$2"; shift 2;;
    --audio-file) FORCE_AUDIO_FILE="$2"; shift 2;;
    --keep-clone) KEEP_CLONE=true; shift 1;;
    --no-rename-spaces) RENAME_SPACES=false; shift 1;;
    --dry-run) DRY_RUN=true; shift 1;;
    -h|--help) print_help; exit 0;;
    *) echo "Opción desconocida: $1"; print_help; exit 1;;
  esac
done

echo "Destino simulador: $SIMULADOR_DIR"
echo "Renombrar espacios: $RENAME_SPACES"
if $DRY_RUN; then echo "Modo DRY-RUN activado (no se harán cambios)."; fi

# Ensure destination exists
if [[ ! -d "$SIMULADOR_DIR" ]]; then
  if $DRY_RUN; then
    echo "[DRY] Crearía directorio: $SIMULADOR_DIR"
  else
    echo "Creando directorio destino '$SIMULADOR_DIR'..."
    mkdir -p "$SIMULADOR_DIR"
  fi
fi

CLONED_TMP_DIR=""
FIGURAS_DIR=""

# Prepare figuras source
if [[ -n "$FIGURAS_SOURCE" ]]; then
  if [[ "$FIGURAS_SOURCE" =~ ^https?:// ]] || [[ "$FIGURAS_SOURCE" =~ ^git@ ]]; then
    echo "Clonando $FIGURAS_SOURCE ..."
    CLONED_TMP_DIR="$(mktemp -d)"
    if $DRY_RUN; then
      echo "[DRY] git clone --depth 1 $FIGURAS_SOURCE $CLONED_TMP_DIR"
      FIGURAS_DIR="$CLONED_TMP_DIR"
    else
      git clone --depth 1 "$FIGURAS_SOURCE" "$CLONED_TMP_DIR"
      FIGURAS_DIR="$CLONED_TMP_DIR"
    fi
  else
    if [[ -d "$FIGURAS_SOURCE" ]]; then
      FIGURAS_DIR="$FIGURAS_SOURCE"
    else
      echo "Error: la ruta proporcionada en --figuras no existe: $FIGURAS_SOURCE"
      exit 1
    fi
  fi
else
  DEFAULT_REPO="https://github.com/patxipb/figuras.git"
  echo "No se proporcionó --figuras, clonando repo por defecto: $DEFAULT_REPO"
  CLONED_TMP_DIR="$(mktemp -d)"
  if $DRY_RUN; then
    echo "[DRY] git clone --depth 1 $DEFAULT_REPO $CLONED_TMP_DIR"
    FIGURAS_DIR="$CLONED_TMP_DIR"
  else
    git clone --depth 1 "$DEFAULT_REPO" "$CLONED_TMP_DIR"
    FIGURAS_DIR="$CLONED_TMP_DIR"
  fi
fi

echo "Repo figuras localizado en: $FIGURAS_DIR"

# Detect image dir(s)
IMAGE_SRC_DIRS=()
if [[ -d "$FIGURAS_DIR/image" ]]; then IMAGE_SRC_DIRS+=("$FIGURAS_DIR/image"); fi
if [[ -d "$FIGURAS_DIR/images" ]]; then IMAGE_SRC_DIRS+=("$FIGURAS_DIR/images"); fi
if [[ ${#IMAGE_SRC_DIRS[@]} -eq 0 ]]; then
  mapfile -t found_images < <(find "$FIGURAS_DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.svg' \) -printf '%h\n' | sort -u)
  if [[ ${#found_images[@]} -gt 0 ]]; then
    IMAGE_SRC_DIRS+=("${found_images[0]}")
  fi
fi

DEST_IMAGES_DIR="$SIMULADOR_DIR/assets/images"
DEST_AUDIO_DIR="$SIMULADOR_DIR/assets/audio"

if $DRY_RUN; then
  echo "[DRY] Crear directorios: $DEST_IMAGES_DIR  $DEST_AUDIO_DIR"
else
  mkdir -p "$DEST_IMAGES_DIR"
  mkdir -p "$DEST_AUDIO_DIR"
fi

# Copy images
if [[ ${#IMAGE_SRC_DIRS[@]} -gt 0 ]]; then
  echo "Copiando imágenes a $DEST_IMAGES_DIR ..."
  for src in "${IMAGE_SRC_DIRS[@]}"; do
    if $DRY_RUN; then
      if command -v rsync >/dev/null 2>&1; then
        echo "[DRY] rsync -av --exclude='.git' \"$src\"/ \"$DEST_IMAGES_DIR\"/"
      else
        echo "[DRY] cp -r \"$src\"/. \"$DEST_IMAGES_DIR\"/"
      fi
    else
      if command -v rsync >/dev/null 2>&1; then
        rsync -av --exclude='.git' "$src"/ "$DEST_IMAGES_DIR"/
      else
        cp -r "$src"/. "$DEST_IMAGES_DIR"/
      fi
    fi
  done
  echo "Imágenes copiadas."
else
  echo "Aviso: no se encontraron imágenes en el repo figuras."
fi

# Determine audio to copy
AUDIO_TO_COPY=""
if [[ -n "$FORCE_AUDIO_FILE" ]]; then
  if [[ -f "$FORCE_AUDIO_FILE" ]]; then
    AUDIO_TO_COPY="$FORCE_AUDIO_FILE"
    echo "Usando audio forzado: $AUDIO_TO_COPY"
  else
    echo "Error: archivo especificado en --audio-file no existe: $FORCE_AUDIO_FILE"
    exit 1
  fi
fi

if [[ -z "$AUDIO_TO_COPY" ]]; then
  echo "Buscando archivos de audio (*.mp3, *.wav, *.ogg) en $FIGURAS_DIR ..."
  mapfile -t audios < <(find "$FIGURAS_DIR" -type f \( -iname '*.mp3' -o -iname '*.wav' -o -iname '*.ogg' \) -print)
  if [[ ${#audios[@]} -eq 0 ]]; then
    echo "No se encontraron archivos de audio en el repo figuras."
  else
    preferred=""
    for a in "${audios[@]}"; do
      lower=$(basename "$a" | tr '[:upper:]' '[:lower:]')
      if [[ "$lower" == *dispar* ]] || [[ "$lower" == *sonido* ]] || [[ "$lower" == *shot* ]] || [[ "$lower" == *fire* ]]; then
        preferred="$a"
        break
      fi
    done
    if [[ -n "$preferred" ]]; then AUDIO_TO_COPY="$preferred"; else AUDIO_TO_COPY="${audios[0]}"; fi
    echo "Audio seleccionado: $AUDIO_TO_COPY"
  fi
fi

AUDIO_FINAL=""
if [[ -n "${AUDIO_TO_COPY:-}" ]]; then
  ext="${AUDIO_TO_COPY##*.}"
  target_audio="$DEST_AUDIO_DIR/disparo.$ext"
  if $DRY_RUN; then
    echo "[DRY] cp \"$AUDIO_TO_COPY\" \"$target_audio\""
    AUDIO_FINAL="$target_audio"
  else
    cp "$AUDIO_TO_COPY" "$target_audio"
    AUDIO_FINAL="$target_audio"
    echo "Audio copiado a: $AUDIO_FINAL"
  fi
else
  echo "No se añadió audio."
fi

# Rename files/directories with spaces (if requested)
if $RENAME_SPACES; then
  echo "Renombrado automático de archivos/carpetas con espacios -> '_' (guiones bajos)."
  # Operar sobre assets/images y assets/audio
  TARGET_ROOTS=("$DEST_IMAGES_DIR" "$DEST_AUDIO_DIR")

  for root in "${TARGET_ROOTS[@]}"; do
    if [[ ! -d "$root" ]]; then
      continue
    fi

    # Use find -depth to rename deepest entries first (to handle directories)
    if $DRY_RUN; then
      echo "[DRY] Buscar entradas con espacios en: $root"
      find "$root" -depth -name "* *" -print0 | while IFS= read -r -d '' f; do
        new="${f// /_}"
        echo "[DRY] RENOMBRAR: '$f' => '$new'"
      done
    else
      # perform renames
      find "$root" -depth -name "* *" -print0 | while IFS= read -r -d '' f; do
        new="${f// /_}"
        # If target exists, try to avoid collision by appending a numeric suffix
        if [[ -e "$new" ]]; then
          base="${new%.*}"
          ext="${new##*.}"
          # if there's no extension (dir), ext==new; handle both cases
          i=1
          candidate="${base}_$i"
          if [[ "$ext" != "$new" ]]; then
            candidate="${base}_$i.$ext"
          fi
          while [[ -e "$candidate" ]]; do
            i=$((i+1))
            candidate="${base}_$i"
            if [[ "$ext" != "$new" ]]; then
              candidate="${base}_$i.$ext"
            fi
          done
          echo "Advertencia: destino ya existe. Renombrando con sufijo: '$f' => '$candidate'"
          mv "$f" "$candidate"
        else
          echo "Renombrando: '$f' => '$new'"
          mv "$f" "$new"
        fi
      done
    fi
  done
else
  echo "Renombrado de espacios desactivado (--no-rename-spaces)."
fi

# Optional: flutter pub get if available
if command -v flutter >/dev/null 2>&1 && [[ -f "$SIMULADOR_DIR/pubspec.yaml" ]]; then
  if $DRY_RUN; then
    echo "[DRY] Ejecutaría: (cd $SIMULADOR_DIR && flutter pub get)"
  else
    echo "Ejecutando 'flutter pub get' en $SIMULADOR_DIR ..."
    (cd "$SIMULADOR_DIR" && flutter pub get)
  fi
fi

# Cleanup cloned repo if requested
if [[ -n "$CLONED_TMP_DIR" && "$KEEP_CLONE" = false ]]; then
  if $DRY_RUN; then
    echo "[DRY] Eliminaría clone temporal: $CLONED_TMP_DIR"
  else
    echo "Eliminando clone temporal $CLONED_TMP_DIR ..."
    rm -rf "$CLONED_TMP_DIR"
  fi
fi

# Summary
echo "------ Resumen ------"
if [[ -d "$DEST_IMAGES_DIR" ]]; then
  count_images=$(find "$DEST_IMAGES_DIR" -type f | wc -l || true)
  echo "Total archivos en assets/images: ${count_images:-0}"
fi
if [[ -d "$DEST_AUDIO_DIR" ]]; then
  count_audio=$(find "$DEST_AUDIO_DIR" -type f | wc -l || true)
  echo "Total archivos en assets/audio: ${count_audio:-0}"
fi
if [[ -n "$AUDIO_FINAL" ]]; then
  echo "Archivo de audio final: $AUDIO_FINAL"
fi

echo "Operación completada."
