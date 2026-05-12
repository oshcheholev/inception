#!/bin/bash

set -e

DB_PASS="$(cat "$DB_PASSWORD_FILE")"
WP_ADMIN_PASS="$(cat "$WP_ADMIN_PASS_FILE")"
WP_USER2_PASS="$(cat "$WP_USER2_PASS_FILE")"

# Run WP-CLI in the mounted web root so files persist and are served by nginx.
cd /var/www/html

## ---  wait for MariaDB ---
echo "Waiting for MariaDB..."
until mysqladmin ping -h$DB_HOST --silent; do
    sleep 1
done

# Wait until DB credentials can authenticate to avoid race on first boot.
until mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" -e "USE ${DB_NAME};" >/dev/null 2>&1; do
    sleep 1
done

chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /run/php
## --- download WordPress ---
if [ ! -f /var/www/html/index.php ]; then
    wp core download --allow-root
fi

## --- config ---
if [ ! -f /var/www/html/wp-config.php ]; then
    wp config create \
        --dbname=${DB_NAME} \
        --dbuser=${DB_USER} \
        --dbpass=${DB_PASS} \
        --dbhost=${DB_HOST} \
        --allow-root
fi

## --- install ---
if ! wp core is-installed --allow-root >/dev/null 2>&1; then
    wp core install \
        --url=${WP_URL} \
        --title="${WP_TITLE}" \
        --admin_user=${WP_ADMIN} \
        --admin_password=${WP_ADMIN_PASS} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root
fi

# Keep runtime URL aligned with exposed host port so browser redirects stay valid.
wp option update home "${WP_URL}" --allow-root
wp option update siteurl "${WP_URL}" --allow-root

# Create additional user if needed
if ! wp user get "${WP_USER2}" --allow-root >/dev/null 2>&1; then
    echo "Creating additional WordPress user: $WP_USER2"
    wp user create "${WP_USER2}" "${WP_USER2_EMAIL}" \
        --user_pass="${WP_USER2_PASS}" \
        --role="${WP_USER2_ROLE}" \
        --allow-root
fi

## --- simple content ---
if ! wp post list --post_type=post --title="Hello from Inception!" --field=ID --allow-root | grep -q .; then
    wp post create \
        --post_title="Hello from Inception!" \
        --post_content="This is my WordPress site running in Docker." \
        --post_status=publish \
        --allow-root
fi

# install redis plugin
if [ "$REDIS_ENABLED" = "true" ]; then
     echo "Installing Redis Object Cache plugin..."
     wp plugin install redis-cache --activate --allow-root
     
     # configure redis
     wp config set WP_REDIS_HOST redis --allow-root
     wp config set WP_REDIS_PORT 6379 --raw --allow-root

     # enable cache
     echo "⏳ Waiting for Redis..."

     until redis-cli -h redis ping; do
         sleep 1
     done

     echo "✅ Redis is ready!"

     wp redis enable --allow-root
fi

## --- start php-fpm ---
exec php-fpm7.4 -F