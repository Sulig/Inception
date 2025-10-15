#!/bin/bash
set -eu

# Verbose only if DEBUG set
[ "${DEBUG:-}" = "1" ] && set -x

# Required env vars
: "${MYSQL_ROOT_PASSWORD:?Need MYSQL_ROOT_PASSWORD non-empty}"
: "${MYSQL_DATABASE:?Need MYSQL_DATABASE non-empty}"
: "${MYSQL_USER:?Need MYSQL_USER non-empty}"
: "${MYSQL_PASSWORD:?Need MYSQL_PASSWORD non-empty}"

DATADIR=/var/lib/mysql
SOCKET="/var/run/mysqld/mysqld.sock"

# Asegurar permisos
chown -R mysql:mysql "$DATADIR"
chown -R mysql:mysql /var/run/mysqld

# Initialize DB if needed
if [ ! -d "$DATADIR/mysql" ]; then
  echo "=> Inicializando datos de MariaDB..."

  if command -v mariadb-install-db >/dev/null 2>&1; then
    mariadb-install-db --user=mysql --datadir="$DATADIR" --auth-root-authentication-method=normal
  elif command -v mysql_install_db >/dev/null 2>&1; then
    mysql_install_db --user=mysql --datadir="$DATADIR"
  else
    mysqld --initialize-insecure --user=mysql --datadir="$DATADIR"
  fi
  echo "=> Inicialización completada"
fi

# Start temporary server with socket only
echo "=> Arrancando servidor temporal (socket only)..."
mysqld_safe --datadir="$DATADIR" --skip-networking --socket="$SOCKET" &
pid="$!"

# Wait for socket to be available AND server ready to accept connections
echo "=> Esperando a que MariaDB esté completamente lista..."
timeout=60
while true; do
  # Check if socket exists AND we can connect to it
  if [ -S "$SOCKET" ] && mysql -S "$SOCKET" -e "SELECT 1" >/dev/null 2>&1; then
    echo "=> MariaDB lista y aceptando conexiones"
    break
  fi

  sleep 1
  timeout=$((timeout - 1))
  if [ $timeout -le 0 ]; then
    echo "¡¡MariaDB no está listo para conexiones!!"
    echo "=== Últimos logs de error ==="
    tail -n 100 /var/log/mysql/error.log 2>/dev/null || echo "No se pudo leer el log de errores"
    echo "=== Estado del proceso ==="
    ps aux | grep mysql || echo "No hay procesos mysql"
    echo "=== Socket info ==="
    ls -la /var/run/mysqld/ 2>/dev/null || echo "No se pudo listar socket directory"
    exit 1
  fi
  echo "    Esperando... ($timeout segundos restantes)"
done

# Configure using socket connection (no password needed)
echo "=> Configurando root y base de datos..."
mysql -S "$SOCKET" <<-EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL

echo "=> Configuración completada"

# Stop temporary server
echo "=> Deteniendo servidor temporal..."
if kill "$pid" 2>/dev/null; then
  wait "$pid" 2>/dev/null || true
else
  echo "Proceso ya terminado"
fi

# Start final server
echo "=> Arrancando servidor final de MariaDB..."
exec "$@"
