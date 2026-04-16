#!/bin/bash

set -e

# Initialize database if not exists
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db
fi

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    # Initial setup without password
    cat > /init.sql <<EOF

    exec mysqld --user=mysql --datadir=/var/lib/mysql --init-file=/init.sql
    
    echo "MariaDB initialization completed."
else
    echo "MariaDB database already exists."
    exec mysqld_safe --user=mysql --datadir=/var/lib/mysql
fi

# Start MySQL in foreground
echo "Starting MariaDB server..."