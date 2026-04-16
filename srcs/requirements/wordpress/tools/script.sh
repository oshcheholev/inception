#!/bin/bash

set -e

## --- configuration from environment ---
# Database
DB_NAME=${DB_NAME:-wordpress}
DB_USER=${DB_USER:-wp_user}
# Support both DB_PASSWORD and DB_PASS env names
DB_PASS=${DB_PASSWORD:-${DB_PASS:-wp_pass}}
DB_HOST=${DB_HOST:-mariadb}

# WordPress
WP_URL=${WP_URL:-https://localhost}
WP_TITLE=${WP_TITLE:-Inception Site}
WP_ADMIN=${WP_ADMIN:-admin}
# Admin password can be provided via WP_ADMIN_PASS env
WP_ADMIN_PASS=${WP_ADMIN_PASS:-admin}
WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL:-${WP_EMAIL:-oshcheho@student.42.fr}}

# Run WP-CLI in the mounted web root so files persist and are served by nginx.
cd /var/www/html

## ---  wait for MariaDB ---
echo "⏳ Waiting for MariaDB..."
until mysqladmin ping -h$DB_HOST --silent; do
    sleep 1
done

# Wait until DB credentials can authenticate to avoid race on first boot.
until mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" -e "USE $DB_NAME;" >/dev/null 2>&1; do
    sleep 1
done

## --- download WordPress ---
if [ ! -f /var/www/html/index.php ]; then
    wp core download --allow-root
fi

## --- config ---
if [ ! -f /var/www/html/wp-config.php ]; then
    wp config create \
        --dbname=$DB_NAME \
        --dbuser=$DB_USER \
        --dbpass=$DB_PASS \
        --dbhost=$DB_HOST \
        --allow-root
fi

## --- install ---
if ! wp core is-installed --allow-root >/dev/null 2>&1; then
    wp core install \
        --url=$WP_URL \
        --title="$WP_TITLE" \
        --admin_user=$WP_ADMIN \
        --admin_password=$WP_ADMIN_PASS \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root
fi

# Keep runtime URL aligned with exposed host port so browser redirects stay valid.
wp option update home "$WP_URL" --allow-root
wp option update siteurl "$WP_URL" --allow-root

## --- simple content ---
if ! wp post list --post_type=post --title="Hello from Inception 🚀" --field=ID --allow-root | grep -q .; then
    wp post create \
        --post_title="Hello from Inception 🚀" \
        --post_content="This is my WordPress site running in Docker." \
        --post_status=publish \
        --allow-root
fi

## --- start php-fpm ---
exec php-fpm7.4 -F