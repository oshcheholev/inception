#!/bin/bash

service mariadb start

# Wait for MariaDB to be ready
sleep 5

mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF

# Stop service to restart in foreground
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

# Run MariaDB in foreground (IMPORTANT for Docker)
exec mysqld_safe