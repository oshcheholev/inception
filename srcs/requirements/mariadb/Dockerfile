FROM debian:bullseye

# Install MariaDB server
RUN apt-get update && apt-get install -y \
    mariadb-server \
	mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Copy MariaDB configuration
COPY conf/server.conf /etc/mysql/mariadb.conf.d/server.conf

# Copy startup script
COPY tools/script.sh /script.sh
RUN chmod +x /script.sh

# Copy init SQL referenced by the MariaDB configuration
COPY tools/init.sql /var/lib/mysql/init.sql

RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

# Expose port 3306
EXPOSE 3306

# Start MariaDB
CMD ["/script.sh"]