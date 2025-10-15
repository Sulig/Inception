#!/bin/bash
set -eu

# DEBUG=1 para trazas: export DEBUG=1
[ "${DEBUG:-}" = "1" ] && set -x

# Comprobar variables obligatorias
: "${MYSQL_ROOT_PASSWORD:?Need MYSQL_ROOT_PASSWORD non-empty}"
: "${MYSQL_DATABASE:?Need MYSQL_DATABASE non-empty}"
: "${MYSQL_USER:?Need MYSQL_USER non-empty}"
: "${MYSQL_PASSWORD:?Need MYSQL_PASSWORD non-empty}"

DATADIR=/var/lib/mysql
chown -R mysql:mysql "$DATADIR"

# Inicializar si hace falta
if [ ! -d "$DATADIR/mysql" ]; then
  echo "=> Inicializando datos de MariaDB..."
  if command -v mysql_install_db >/dev/null 2>&1; then
    mysql_install_db --user=mysql --datadir="$DATADIR"
  else
    echo "!! mysql_install_db no encontrado, intentando alternativa mysqld --initialize-insecure"
    mysqld --initialize-insecure --user=mysql --datadir="$DATADIR"
  fi
fi

# Arrancar servidor temporal en background (usa socket por defecto)
echo "=> Arrancando servidor temporal..."
mysqld_safe --datadir="$DATADIR" &
pid="$!"

# Esperar a que el socket esté disponible (usa socket UNIX por defecto)
echo "=> Esperando a que MariaDB acepte conexiones (timeout 60s)..."
timeout=60
while ! mysqladmin ping --silent; do
  sleep 1
  timeout=$((timeout - 1))
  if [ $timeout -le 0 ]; then
    echo "¡¡No arranca MariaDB temporal!!"
    tail -n 200 /var/log/mysql/error.log || true
    exit 1
  fi
done

# Ejecutar SQL de configuración (conexión por socket, idempotente)
echo "=> Configurando root y base de datos..."
mysql <<-EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL

# Apagar servidor temporal de forma ordenada usando mysqladmin (socket)
echo "=> Deteniendo servidor temporal..."
if command -v mysqladmin >/dev/null 2>&1; then
  mysqladmin shutdown || kill "$pid"
else
  kill "$pid"
fi

wait "$pid" 2>/dev/null || true

# Ejecutar el proceso final (respetar CMD)
echo "=> Arrancando servidor final de MariaDB (exec)..."
exec "$@"
