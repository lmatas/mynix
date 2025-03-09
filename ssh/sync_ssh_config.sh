#!/bin/bash

# Script para sincronizar configuraciones SSH de un archivo fuente al .ssh/config
# Uso: ./sync_ssh_config.sh [archivo_fuente]
# Si no se proporciona archivo_fuente, se usa /Users/lmatas/.config/nix/ssh/config

# Definir archivo fuente y destino
SOURCE=${1:-"/Users/lmatas/.config/nix/ssh/config"}
DEST="$HOME/.ssh/config"

# Verificar que el archivo fuente existe
if [ ! -f "$SOURCE" ]; then
    echo "❌ Error: El archivo fuente $SOURCE no existe"
    exit 1
fi

# Asegurar que el directorio .ssh existe con permisos adecuados
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Crear el archivo destino si no existe
if [ ! -f "$DEST" ]; then
    touch "$DEST"
    chmod 600 "$DEST"
    echo "📄 Creado archivo $DEST"
fi

echo "🔄 Sincronizando configuraciones SSH de $SOURCE a $DEST..."

# Hacer una copia de seguridad antes de modificar
BACKUP="$DEST.bak.$(date +%Y%m%d%H%M%S)"
cp "$DEST" "$BACKUP"
echo "💾 Copia de seguridad guardada en $BACKUP"

# Crear un archivo temporal para construir el nuevo config
TEMP_CONFIG=$(mktemp)
cp "$DEST" "$TEMP_CONFIG"

# Procesar cada host en el archivo fuente
grep -i "^Host " "$SOURCE" | while read -r host_line; do
    # Extraer el nombre del host (puede tener múltiples nombres separados por espacios)
    host_names=${host_line#Host }
    
    # Para cada host encontrado, determinar si ya existe en el archivo destino
    for host in $host_names; do
        # Ignorar patrones con * o ?
        if [[ "$host" == *\** || "$host" == *\?* ]]; then
            continue
        fi
        
        echo "🔍 Procesando host: $host"
        
        # Buscar el bloque de configuración en el archivo fuente
        start_line=$(grep -n "^Host .*\b$host\b" "$SOURCE" | head -1 | cut -d: -f1)
        if [ -z "$start_line" ]; then
            continue
        fi
        
        # Encontrar el final del bloque (la próxima línea con Host o EOF)
        end_line=$(tail -n +$((start_line + 1)) "$SOURCE" | grep -n "^Host " | head -1 | cut -d: -f1)
        if [ -z "$end_line" ]; then
            # Si no hay más bloques Host, tomar hasta el final del archivo
            end_line=$(wc -l < "$SOURCE")
        else
            # Ajustar para obtener el número de línea absoluto
            end_line=$((start_line + end_line - 1))
        fi
        
        # Extraer el bloque de configuración completo
        config_block=$(sed -n "${start_line},${end_line}p" "$SOURCE")
        
        # Verificar si el host ya existe en el archivo destino
        if grep -q "^Host .*\b$host\b" "$TEMP_CONFIG"; then
            echo "✏️ Actualizando configuración para $host"
            
            # Crear un nuevo archivo temporal
            NEW_TEMP=$(mktemp)
            
            # Encontrar el bloque para este host en el archivo temporal
            dest_start=$(grep -n "^Host .*\b$host\b" "$TEMP_CONFIG" | head -1 | cut -d: -f1)
            dest_end=$(tail -n +$((dest_start + 1)) "$TEMP_CONFIG" | grep -n "^Host " | head -1 | cut -d: -f1)
            
            if [ -z "$dest_end" ]; then
                # Si no hay más bloques Host, ir hasta el final del archivo
                dest_end=$(wc -l < "$TEMP_CONFIG")
            else
                # Ajustar para obtener el número de línea absoluto
                dest_end=$((dest_start + dest_end - 1))
            fi
            
            # Escribir el archivo actualizado excluyendo el bloque antiguo
            sed -n "1,$((dest_start - 1))p" "$TEMP_CONFIG" > "$NEW_TEMP"
            echo "$config_block" >> "$NEW_TEMP"
            sed -n "$((dest_end + 1)),\$p" "$TEMP_CONFIG" >> "$NEW_TEMP"
            
            # Reemplazar el archivo temporal
            mv "$NEW_TEMP" "$TEMP_CONFIG"
        else
            echo "➕ Agregando nueva configuración para $host"
            echo -e "\n$config_block" >> "$TEMP_CONFIG"
        fi
    done
done

# Mover el archivo temporal al destino final
mv "$TEMP_CONFIG" "$DEST"

# Establecer permisos seguros
chmod 600 "$DEST"

echo "✅ Sincronización completada"
echo "📝 Archivo de configuración actualizado: $DEST"
