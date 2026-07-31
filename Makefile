MARIADB_VOLUME_DIR="/home/oukhiar/data/mariadb"
WORDPRESS_VOLUME_DIR="/home/oukhiar/data/wordpress"
COMPOSE=docker compose -f srcs/docker-compose.yaml
VOLUME_HOST_DIR=/home/oukhiar/data


all:
	mkdir -p ${WORDPRESS_VOLUME_DIR} ${MARIADB_VOLUME_DIR}
	${COMPOSE} up --build

clean:
	${COMPOSE} down

fclean:
	${COMPOSE} down -v
	sudo rm -rf ${VOLUME_HOST_DIR}/*

re: fclean all