#!/bin/bash

# 1. Definir tu carpeta
DIR="$HOME/Pictures/wallpaper/"

# 2. Abrir menú interactivo con previsualización lateral de Kitty corregida
WALLPAPER=$(find "$DIR" -type f | fzf \
    --prompt="Selecciona fondo: " \
    --preview="kitty +kitten icat --clear --transfer-mode=memory --stdin=no --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0 {}" \
    --preview-window="right:60%"
)

# Si presionas Esc y cancelas, el script termina sin hacer nada
if [ -z "$WALLPAPER" ]; then
    exit 0
fi

# 3. Aplicar el fondo con una transición suave
awww img "$WALLPAPER" --transition-type wipe

# 4. Extraer los colores y generar archivos (sin usar caché)
wal -q -t -i "$WALLPAPER" 2>/dev/null

# 5. Aplicar los colores a tu sistema
hyprctl reload
killall -SIGUSR2 waybar
makoctl reload

# Cargar las variables de Pywal en la memoria de este script
source ~/.cache/wal/colors.sh

# Inyectar los colores directamente en el núcleo de Hyprland
hyprctl keyword general:col.active_border "$color2 $color4 45deg"
hyprctl keyword general:col.inactive_border "$background"
