FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    mariadb-server \
	mariadb-client \
    && rm -rf /var/lib/apt/lists/*

COPY conf/server.conf /etc/mysql/mariadb.conf.d/server.conf

COPY tools/script.sh /script.sh
RUN chmod +x /script.sh


RUN install -d -m 755 -o mysql -g mysql /run/mysqld

EXPOSE 3306

CMD ["/script.sh"]