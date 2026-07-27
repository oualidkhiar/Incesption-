FROM debian:bookworm

WORKDIR wp

RUN apt-get update && apt-get install -y php \
    php8.2-fpm \
    mariadb-client \
    php8.2-mysql \
    netcat-openbsd \
    curl

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY tools/wordpress_script.sh .

RUN chmod +x wordpress_script.sh

RUN sed -i "s|listen = /run/php/php8.2-fpm.sock|listen = 0.0.0.0:9000|" /etc/php/8.2/fpm/pool.d/www.conf

ENTRYPOINT ["./wordpress_script.sh"]