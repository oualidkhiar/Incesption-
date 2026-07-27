#!/bin/sh

set -e

DB_PASS=$(cat /run/secrets/db_password)
ADMIN_PASS=$(cat /run/secrets/wp_admin)
USER_PASS=$(cat /run/secrets/wp_user)

mkdir -p /run/php

mkdir -p /var/www/html

cd /var/www/html

if [ ! -f /var/www/html/.wp_files_exist ]; then

    wp core download --allow-root

    until mariadb-admin ping --silent; do
        sleep 1
    done

    wp config create \
        --dbname="${DATABASE_NAME}" \
        --dbuser="${DATABASE_USER}" \
        --dbpass="${DB_PASS}" \
        --dbhost="mariadb:3306" \
        --allow-root

    wp core install \
        --url="${DOMAINE_NAME}" \
        --title="my WordPress site test" \
        --admin_user="${ADMIN_NAME}" \
        --admin_password="${ADMIN_PASS}" \
        --admin_email="owner@owner.com" \
        --allow-root

    wp user create \
        "${USER_NAME}" \
        "${USER_EMAIL}" \
        --role=author \
        --user_pass="${USER_PASS}" \
        --allow-root

    touch .wp_files_exist
    chown -R www-data:www-data /var/www/html

fi

exec php-fpm8.2 -F