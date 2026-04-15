#!/bin/bash

## --- configuration from environment ---
# Database
DB_NAME=${DB_NAME:-wordpress}
DB_USER=${DB_USER:-wp_user}
# Support both DB_PASSWORD and DB_PASS env names
DB_PASS=${DB_PASSWORD:-${DB_PASS:-wp_pass}}
DB_HOST=${DB_HOST:-mariadb}

# WordPress
WP_URL=${WP_URL:-http://localhost}
WP_TITLE=${WP_TITLE:-Inception Site}
WP_ADMIN=${WP_ADMIN:-admin}
# Admin password can be provided via WP_ADMIN_PASS env
WP_ADMIN_PASS=${WP_ADMIN_PASS:-admin}
WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL:-oshcheho@student.42.fr}

## ---  wait for MariaDB ---
echo "⏳ Waiting for MariaDB..."
until mysqladmin ping -h$DB_HOST --silent; do
    sleep 1
done

## --- download WordPress ---
wp core download --allow-root

## --- config ---
wp config create \
    --dbname=$DB_NAME \
    --dbuser=$DB_USER \
    --dbpass=$DB_PASS \
    --dbhost=$DB_HOST \
    --allow-root

## --- install ---
wp core install \
    --url=$WP_URL \
    --title="$WP_TITLE" \
    --admin_user=$WP_ADMIN \
    --admin_password=$WP_ADMIN_PASS \
    --admin_email=$WP_ADMIN_EMAIL \
    --allow-root

## --- simple content ---
wp post create \
    --post_title="Hello from Inception 🚀" \
    --post_content="This is my WordPress site running in Docker." \
    --post_status=publish \
    --allow-root

## --- start php-fpm ---
exec php-fpm7.4 -F