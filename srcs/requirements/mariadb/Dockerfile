FROM debian:bookworm

WORKDIR /mdb

RUN apt update && apt install -y mariadb-server \
    netcat-openbsd

COPY tools/mariadb_script.sh mariadb_script.sh

RUN chmod +x mariadb_script.sh

RUN sed -i "s|bind-address            = 127.0.0.1\
|bind-address = 0.0.0.0|" /etc/mysql/mariadb.conf.d/50-server.cnf

ENTRYPOINT ["./mariadb_script.sh"]