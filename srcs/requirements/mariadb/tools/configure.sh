#!/bin/bash
set -eux

# Variables de entorno obligatorias:
#   MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD

# 1) Preparar directorio de datos
DATADIR=/var/lib/mysql
chown -R mysql:mysql "$DATADIR"

# 2) Inicializar datos si hace falta
if [ ! -d "$DATADIR/mysql" ]; then
  echo "=> Inicializando datos de MariaDB..."
  mysql_install_db --user=mysql --datadir="$DATADIR"
fi

# 3) Arrancar servidor temporal en background (con TCP, sin --skip-networking)
echo "=> Arrancando servidor temporal..."
mysqld_safe --datadir="$DATADIR" &
pid="$!"

# 4) Esperar hasta que acepte conexiones
echo "=> Esperando a que MariaDB esté lista..."
timeout=30
while ! mysqladmin ping --silent --protocol=TCP; do
  sleep 1
  timeout=$((timeout - 1))
  if [ $timeout -le 0 ]; then
    echo "¡¡No arranca MariaDB temporal!!"
    exit 1
  fi
done

# 5) Configurar contraseñas y usuarios
echo "=> Configurando root y base de datos..."
mysql <<-EOSQL
  ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
  CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
  CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
  GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
  FLUSH PRIVILEGES;
EOSQL

# 6) Parar servidor temporal
echo "=> Deteniendo servidor temporal..."
kill "$pid"
wait "$pid"

# 7) Finalmente, arranca el demonio definitivo (reemplaza el proceso actual)
echo "=> Arrancando servidor final de MariaDB..."
exec "$@"
