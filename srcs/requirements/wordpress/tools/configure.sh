#!/bin/sh
# srcs/requirements/wordpress/tools/configure.sh
set -e

echo "🎯 Configurando WordPress..."

# Esperar a que MariaDB esté realmente listo
echo "⏳ Esperando a MariaDB..."
timeout=60
while ! mysql -h mariadb -u ${WORDPRESS_DB_USER} -p${WORDPRESS_DB_PASSWORD} -e "SELECT 1;" ${WORDPRESS_DB_NAME} 2>/dev/null; do
  sleep 2
  timeout=$((timeout - 2))
  if [ $timeout -le 0 ]; then
    echo "❌ No se puede conectar a MariaDB después de 60 segundos"
    exit 1
  fi
  echo "⏰ Esperando conexión a MariaDB... ($timeout segundos restantes)"
done
echo "✅ Conectado a MariaDB"

# Crear wp-config.php si no existe
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "📝 Creando wp-config.php..."

    wp --path=/var/www/html config create \
        --dbname=${WORDPRESS_DB_NAME} \
        --dbuser=${WORDPRESS_DB_USER} \
        --dbpass=${WORDPRESS_DB_PASSWORD} \
        --dbhost=mariadb \
        --locale=es_ES \
        --skip-check

    echo "✅ wp-config.php creado"
else
    echo "✅ wp-config.php ya existe"
fi

# Instalar WordPress si no está instalado
if ! wp --path=/var/www/html core is-installed; then
    echo "📀 Instalando WordPress..."

    wp --path=/var/www/html core install \
        --url=https://${DOMAIN_NAME} \
        --title="Inception Project" \
        --admin_user=${WORDPRESS_ADMIN_USER} \
        --admin_password=${WORDPRESS_ADMIN_PASSWORD} \
        --admin_email=${WORDPRESS_ADMIN_EMAIL} \
        --skip-email

    echo "✅ WordPress instalado automáticamente"
else
    echo "✅ WordPress ya está instalado"
fi

# Configurar idioma español (si es necesario)
wp --path=/var/www/html language core install es_ES
wp --path=/var/www/html site switch-language es_ES

# Configurar permisos
chown -R nobody:nobody /var/www/html
chmod -R 755 /var/www/html

echo "🚀 Iniciando PHP-FPM..."
exec php-fpm81 -F
