#!/bin/bash

set -e


MYSQL_PASSWORD="$(cat "$MYSQL_PASSWORD_FILE")"
MYSQL_ROOT_PASSWORD="$(cat "$MYSQL_ROOT_PASSWORD_FILE")"

mkdir -p /var/lib/mysql
install -d -m 755 -o mysql -g mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql


if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal --skip-test-db >/dev/null
fi

echo "Starting temporary MariaDB server for initialization..."
mysqld_safe --user=mysql --datadir=/var/lib/mysql --skip-networking >/dev/null 2>&1 &
pid="${!}"

until mysqladmin ping --silent; do
    sleep 1
done

echo "Creating database and user if needed..."
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

mysqladmin shutdown
wait "$pid"

exec mysqld_safe --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0
