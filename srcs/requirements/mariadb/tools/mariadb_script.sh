#!/bin/sh

set -e

send_queries() {
    mariadb -u root -e "${QUERIES}"
}

mkdir -p /var/lib/mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql /run/mysqld

DATABASE_PASS=$(cat /run/secrets/db_password)
DATABASE_ROOT_PASS=$(cat /run/secrets/db_root_password)

if [ ! -d /var/lib/mysql/"${DATABASE_NAME}" ]; then

    mariadbd --user=mysql --skip-networking &

    until mariadb-admin ping --silent; do
        sleep 1
    done

    QUERIES="CREATE DATABASE IF NOT EXISTS "${DATABASE_NAME}";
    CREATE USER IF NOT EXISTS '"${DATABASE_USER}"'@'%' IDENTIFIED BY '"${DATABASE_PASS}"';
    GRANT ALL PRIVILEGES ON "${DATABASE_NAME}".* TO '"${DATABASE_USER}"'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '"${DATABASE_ROOT_PASS}"';
    FLUSH PRIVILEGES;"

    send_queries

    mariadb-admin -u root -p"${DATABASE_ROOT_PASS}" shutdown

fi

exec mariadbd --user=mysql