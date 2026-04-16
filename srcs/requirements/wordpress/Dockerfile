FROM debian:bullseye

RUN apt update && apt install -y \
	php7.4-fpm \
	php7.4-mysqli \
	php7.4-redis \
	curl \
	redis-tools \
	mariadb-client \
	ftp \
	&& rm -rf /var/lib/apt/lists/*

# Install PHP CLI for WP-CLI and other CLI tools
RUN apt-get update && apt-get install -y \
    php-cli \
    php-xml \
    && rm -rf /var/lib/apt/lists/*

COPY www.conf /etc/php/7.4/fpm/pool.d/

COPY ./tools/script.sh .
RUN chmod +x script.sh

RUN mkdir -p /var/www/html /run/php
RUN chown -R www-data:www-data /var/www/html /run/php

# Install WP-CLI
RUN curl -sSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
	&& chmod +x /usr/local/bin/wp

EXPOSE 9000

CMD ["./script.sh"]

