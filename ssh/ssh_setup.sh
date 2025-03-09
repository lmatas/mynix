#!/bin/bash

# Script para configurar conexiones SSH automatizadas
# Uso: ./ssh_setup.sh nombre host usuario [puerto]

# Comprobar argumentos
if [ $# -lt 3 ]; then
    echo "❌ Error: Faltan argumentos"
    echo "Uso: $0 nombre host usuario [puerto]"
    echo "Ejemplo: $0 servidor1 ejemplo.com usuario 22"
    exit 1
fi

NOMBRE=$1
HOST=$2
USER=$3
PORT=${4:-22}  # Si no se proporciona puerto, usar 22 por defecto
SCRIPT_PATH="$HOME/.ssh/${NOMBRE}_login.exp"
SERVICE_NAME="ssh-${HOST}"
ACCOUNT_NAME="${USER}@${HOST}"

echo "🔧 Configurando conexión SSH para $NOMBRE ($USER@$HOST:$PORT)"

# Asegurar que existe el directorio .ssh con permisos adecuados
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Solicitar contraseña
echo -n "🔑 Introduce la contraseña SSH: "
read -s PASSWORD
echo ""

# Guardar contraseña en Keychain
security add-generic-password -s "$SERVICE_NAME" -a "$ACCOUNT_NAME" -w "$PASSWORD" -U

# Verificar que se guardó correctamente
if security find-generic-password -s "$SERVICE_NAME" -a "$ACCOUNT_NAME" -w >/dev/null 2>&1; then
    echo "✅ Contraseña guardada correctamente en Keychain"
else
    echo "❌ Error al guardar la contraseña en Keychain"
    exit 1
fi

# Crear script de expect para el login automático
cat > "$SCRIPT_PATH" << EOL
#!/usr/bin/expect -f

# Script para login automático a $HOST usando expect
# Uso: ./${NOMBRE}_login.exp [contraseña]
# Si no se proporciona contraseña, se intentará obtener de Keychain

# Configurar timeout
set timeout 30

# Definir host y usuario
set host "$HOST"
set user "$USER"
set port "$PORT"

# Determinar la contraseña a usar
if {\$argc >= 1} {
    # Usar contraseña proporcionada como argumento
    set password [lindex \$argv 0]
} else {
    # Intentar obtener la contraseña del Keychain
    catch {
        set password [exec security find-generic-password -s "$SERVICE_NAME" -a "$ACCOUNT_NAME" -w]
    } result

    # Verificar si se pudo obtener la contraseña
    if {![info exists password]} {
        puts "⚠️ No se encontró la contraseña en Keychain para \$user@\$host"
        puts "Por favor ingresa la contraseña o ejecútalo como: ./${NOMBRE}_login.exp tucontraseña"
        
        # Solicitar contraseña interactivamente
        stty -echo
        send_user "Contraseña: "
        expect_user -re "(.*)\n"
        set password \$expect_out(1,string)
        stty echo
        send_user "\n"
    }
}

# Iniciar la conexión SSH
puts "🔄 Conectando a \$user@\$host:\$port..."
spawn ssh \$user@\$host -p \$port

# Manejar la conexión
expect {
    -re "password:" {
        send "\$password\r"
        exp_continue
    }
    -re "\$user@\$host's password:" {
        send "\$password\r"
        exp_continue
    }
    "yes/no" {
        send "yes\r"
        exp_continue
    }
    timeout {
        puts "❌ Tiempo de espera agotado esperando respuesta"
        exit 1
    }
    eof {
        puts "❌ La conexión se cerró inesperadamente"
        exit 1
    }
}

# Transferir control a la terminal interactiva
interact
EOL

# Establecer permisos
chmod +x "$SCRIPT_PATH"

# Crear el script sshlogin si no existe y copiarlo a /usr/local/bin
SSHLOGIN_SOURCE="$HOME/.config/nix/ssh/sshlogin"
SSHLOGIN_DEST="/usr/local/bin/sshlogin"

# Crear el directorio bin si no existe
mkdir -p "$(dirname "$SSHLOGIN_SOURCE")"

if [ ! -f "$SSHLOGIN_SOURCE" ]; then
    echo "🔧 Creando script sshlogin..."
    cat > "$SSHLOGIN_SOURCE" << 'EOF'
#!/bin/bash

# Script para ejecutar scripts de login SSH por nombre
# Uso: sshlogin nombre [contraseña]

# Verificar argumentos
if [ $# -lt 1 ]; then
    echo "❌ Error: Debes proporcionar al menos el nombre del sitio"
    echo "Uso: $(basename $0) nombre [contraseña]"
    echo "Ejemplo: $(basename $0) servidor1"
    exit 1
fi

NOMBRE=$1
SCRIPT_PATH="$HOME/.ssh/${NOMBRE}_login.exp"

# Verificar si existe el script
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "❌ Error: No se encontró el script de login para '$NOMBRE'"
    echo "Revisa si existe el archivo: $SCRIPT_PATH"
    
    # Listar sitios disponibles
    AVAILABLE=$(find "$HOME/.ssh/" -name "*_login.exp" | sed 's|.*/\(.*\)_login.exp|\1|' | sort)
    if [ -n "$AVAILABLE" ]; then
        echo -e "\n📋 Sitios disponibles:"
        echo "$AVAILABLE" | while read site; do
            echo "  - $site"
        done
    else
        echo -e "\n⚠️ No hay sitios configurados. Usa ssh_setup.sh para configurar uno."
    fi
    
    exit 1
fi

# Ejecutar el script con los argumentos adicionales (si hay)
if [ $# -gt 1 ]; then
    # Pasar todos los argumentos adicionales al script (útil para pasar la contraseña)
    shift
    "$SCRIPT_PATH" "$@"
else
    "$SCRIPT_PATH"
fi
EOF
    chmod +x "$SSHLOGIN_SOURCE"
    echo "✅ Script sshlogin creado en $SSHLOGIN_SOURCE"
fi

# Copiar sshlogin a /usr/local/bin si tiene permisos
if [ -w "$(dirname "$SSHLOGIN_DEST")" ]; then
    sudo p "$SSHLOGIN_SOURCE" "$SSHLOGIN_DEST"
    chmod +x "$SSHLOGIN_DEST"
    echo "✅ Script sshlogin instalado en $SSHLOGIN_DEST (disponible en el PATH)"
else
    echo "⚠️ No tienes permisos para instalar sshlogin en $SSHLOGIN_DEST"
    echo "Para instalarlo manualmente ejecuta:"
    echo "sudo cp \"$SSHLOGIN_SOURCE\" \"$SSHLOGIN_DEST\" && sudo chmod +x \"$SSHLOGIN_DEST\""
fi

echo "✅ Script de login creado en $SCRIPT_PATH"
echo "📝 Uso: $SCRIPT_PATH o sshlogin $NOMBRE"
