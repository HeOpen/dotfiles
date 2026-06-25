#!/bin/bash

# Evitar la ejecución directa como root para no corromper las rutas de usuario ($HOME)
if [ "$(id -u)" -eq 0 ]; then
    echo "Error: No ejecutes este script con sudo directamente. El script solicitará privilegios cuando sea necesario."
    exit 1
fi

echo "=== Iniciando instalación del sistema de paleta dinámica ==="

# 1. Instalación de dependencias del sistema de forma desatendida
echo "-> Instalando paquetes necesarios mediante pacman..."
sudo pacman -S --needed --noconfirm fzf python-pywal mako imagemagick awww libnotify

# 2. Creación de la estructura de directorios requerida
echo "-> Creando infraestructura de directorios..."
mkdir -p ~/.local/bin ~/.config/wal/templates ~/.config/btop/themes ~/.config/kitty ~/.config/mako

# 3. Despliegue del script selector de fondos
echo "-> Generando script de cambio de fondo..."
cat << 'EOF' > ~/.local/bin/cambiar_fondo.sh
#!/bin/bash
DIR="$HOME/Pictures/wallpaper/"
WALLPAPER=$(find "$DIR" -type f | fzf --prompt="Selecciona fondo: " --preview="kitty +kitten icat --clear --transfer-mode=memory --stdin=no --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0 {}" --preview-window="right:60%")

if [ -z "$WALLPAPER" ]; then
    exit 0
fi

awww img "$WALLPAPER" --transition-type wipe
wal -q -t -i "$WALLPAPER" 2>/dev/null
source ~/.cache/wal/colors.sh

hyprctl keyword general:col.active_border "$color2 $color4 45deg"
hyprctl keyword general:col.inactive_border "$background"
killall -SIGUSR2 waybar
makoctl reload
EOF

chmod +x ~/.local/bin/cambiar_fondo.sh

# 4. Despliegue de la plantilla de Btop
echo "-> Generando plantilla de color para Btop..."
cat << 'EOF' > ~/.config/wal/templates/btop.theme
theme[main_bg]="{color0}"
theme[main_fg]="{color7}"
theme[title]="{color5}"
theme[hi_fg]="{color1}"
theme[selected_bg]="{color8}"
theme[selected_fg]="{color7}"
theme[proc_misc]="{color4}"
theme[cpu_box]="{color2}"
theme[mem_box]="{color3}"
theme[net_box]="{color6}"
theme[proc_box]="{color1}"
theme[div_line]="{color8}"
EOF

ln -sf ~/.cache/wal/btop.theme ~/.config/btop/themes/pywal.theme

# 5. Inyección de configuraciones de forma segura (Idempotencia)
echo "-> Enlazando archivos de configuración de las aplicaciones..."
# Configuración de Kitty via Symlink Nativo
echo "-> Configurando Kitty desde los dotfiles..."
if [ -d "$HOME/dotfiles/kitty" ]; then
    # Eliminar configuración predeterminada limpia si existiera
    rm -rf ~/.config/kitty
    
    # Crear el enlace simbólico directo al repositorio
    ln -sf ~/dotfiles/kitty ~/.config/kitty
    echo "   [Kitty] Enlace simbólico creado correctamente."
else
    echo "   [Error] No se encontró la carpeta kitty dentro de ~/dotfiles/"
fi

# Configuración de Waybar (Asumiendo ruta estándar del sistema)
WAYBAR_CSS="$HOME/.config/waybar/style.css"
if [ -f "$WAYBAR_CSS" ]; then
    if ! grep -q "colors-waybar.css" "$WAYBAR_CSS"; then
        sed -i '1i @import url("../../.cache/wal/colors-waybar.css");' "$WAYBAR_CSS"
        echo "   [Waybar] Importación CSS añadida en la línea 1."
    fi
else
    echo "   [Aviso] No se encontró style.css de Waybar. Recuerda añadir el @import manualmente si usas otra ruta."
fi

echo "=== Instalación completada con éxito ==="
echo "Asegúrate de tener imágenes en ~/Pictures/wallpaper/ y ejecuta 'cambiar_fondo.sh' para inicializar la paleta."

# Configuración de Bash via Symlink
echo "-> Configurando Bash desde los dotfiles..."
if [ -f "$HOME/dotfiles/.bashrc" ]; then
    # Forzar la creación del enlace, sobrescribiendo el archivo por defecto del SO
    ln -sf ~/dotfiles/.bashrc ~/.bashrc
    echo "   [Bash] Enlace simbólico de .bashrc creado correctamente."
else
    echo "   [Error] No se encontró el archivo .bashrc en ~/dotfiles/"
fi
