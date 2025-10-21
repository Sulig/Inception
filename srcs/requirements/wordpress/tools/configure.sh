#!/bin/sh
set -e

echo "🎯 Configurando WordPress..."

# Verificar si podemos resolver el hostname 'mariadb'
echo "🔍 Verificando resolución DNS..."
if ping -c 1 mariadb &> /dev/null; then
    echo "✅ DNS resuelve correctamente"
else
    echo "❌ No se puede resolver 'mariadb'"
    echo "📋 Información de red:"
    cat /etc/hosts
    exit 1
fi

# Esperar a que MariaDB esté listo con mejor diagnóstico
echo "⏳ Esperando a MariaDB..."
timeout=90
while ! mysql -h mariadb -u ${WORDPRESS_DB_USER} -p${WORDPRESS_DB_PASSWORD} -e "SELECT 1;" ${WORDPRESS_DB_NAME} 2>/dev/null; do
  sleep 3
  timeout=$((timeout - 3))
  if [ $timeout -le 0 ]; then
    echo "❌ No se puede conectar a MariaDB después de 90 segundos"

    # Diagnóstico adicional
    echo "🔍 Diagnóstico de conectividad:"
    echo "   - Probando conexión TCP a mariadb:3306..."
    if nc -z mariadb 3306 &> /dev/null; then
        echo "   ✅ Puerto 3306 está abierto"
    else
        echo "   ❌ No se puede conectar al puerto 3306"
    fi

    echo "   - Verificando credenciales..."
    echo "     DB_HOST: mariadb"
    echo "     DB_USER: ${WORDPRESS_DB_USER}"
    echo "     DB_NAME: ${WORDPRESS_DB_NAME}"

    # Intentar conectar sin base de datos específica
    if mysql -h mariadb -u ${WORDPRESS_DB_USER} -p${WORDPRESS_DB_PASSWORD} -e "SELECT 1;" 2>/dev/null; then
        echo "   ✅ Puede conectarse al servidor, pero no a la DB específica"
        echo "   🔍 Verificando si la base de datos existe..."
        if mysql -h mariadb -u ${WORDPRESS_DB_USER} -p${WORDPRESS_DB_PASSWORD} -e "SHOW DATABASES;" 2>/dev/null | grep -q "${WORDPRESS_DB_NAME}"; then
            echo "   ✅ La base de datos existe"
        else
            echo "   ❌ La base de datos NO existe"
        fi
    else
        echo "   ❌ No puede conectarse al servidor MariaDB"
    fi

    # Continuar de todos modos para ver si WordPress puede recuperarse
    echo "🚨 Continuando a pesar del error..."
    break
  fi
  echo "⏰ Esperando conexión a MariaDB... ($timeout segundos restantes)"
done

echo "✅ Conectado a MariaDB"

# Continuar con la configuración normal de WordPress...
if ! /usr/local/bin/wp core is-installed --path=/var/www/html 2>/dev/null; then
    echo "📀 WordPress no está instalado, procediendo con configuración..."

    if [ ! -f "/var/www/html/wp-config.php" ]; then
        echo "📝 Creando wp-config.php..."
        /usr/local/bin/wp config create \
            --dbname=${WORDPRESS_DB_NAME} \
            --dbuser=${WORDPRESS_DB_USER} \
            --dbpass=${WORDPRESS_DB_PASSWORD} \
            --dbhost=mariadb \
            --locale=es_ES \
            --path=/var/www/html \
            --skip-check
    fi

    echo "🚀 Instalando WordPress..."
    /usr/local/bin/wp core install \
        --url=https://${DOMAIN_NAME} \
        --title="Inception Project" \
        --admin_user=${WORDPRESS_ADMIN_USER} \
        --admin_password=${WORDPRESS_ADMIN_PASSWORD} \
        --admin_email=${WORDPRESS_ADMIN_EMAIL} \
        --path=/var/www/html \
        --skip-email

    /usr/local/bin/wp language core install es_ES --path=/var/www/html --activate
    echo "✅ WordPress instalado y configurado"
else
    echo "✅ WordPress ya está instalado, saltando configuración"
fi

chown -R nobody:nobody /var/www/html
chmod -R 755 /var/www/html

echo "🚀 Iniciando PHP-FPM..."
exec php-fpm81 -F
