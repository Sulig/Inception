#!/bin/bash
set -e

# variables esperadas en .env:
# MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD

DATADIR="/var/lib/mysql"

# Si la BD no está inicializada -> inicializar
if [ ! -d "$DATADIR/mysql" ]; then
  echo "[entrypoint] Inicializando base de datos..."
  mariadb-install-db --user=mysql --datadir="$DATADIR" > /dev/null

  # arrancamos temporalmente el servidor con --skip-networking para crear user/db
  mysqld_safe --datadir="$DATADIR" --skip-networking &
  pid="$!"

  # Espera a que el socket esté listo
  attempts=0
  until mysqladmin ping >/dev/null 2>&1; do
    attempts=$((attempts+1))
    if [ $attempts -gt 30 ]; then
      echo "mysqld no responde, abortando!"
      exit 1
    fi
    sleep 0.5
  done

  echo "[entrypoint] Creando usuarios y base de datos iniciales..."
  # Usar variables de entorno; si no existen, usar valores por defecto seguros (solo para testing)
  : "${MYSQL_ROOT_PASSWORD:=rootpass}"
  : "${MYSQL_DATABASE:=wordpress}"
  : "${MYSQL_USER:=wp_user}"
  : "${MYSQL_PASSWORD:=wp_pass}"

  mysql -uroot <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

  # crear una tabla de ejemplo para que "la base no esté vacía"
  mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" <<-EOSQL
    CREATE TABLE IF NOT EXISTS example_table (
      id INT PRIMARY KEY AUTO_INCREMENT,
      name VARCHAR(100) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    INSERT INTO example_table (name) VALUES ('initialized');
EOSQL

  echo "[entrypoint] Deteniendo servidor temporal..."
  mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
  wait "$pid" || true
  echo "[entrypoint] Inicialización completada."
fi

# finalmente, ejecutar el servidor en primer plano (reemplaza el proceso del contenedor)
exec "$@"
