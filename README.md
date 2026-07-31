# Inception

A small system administration project that builds a multi-container Docker
infrastructure from scratch — no pre-built images off Docker Hub, every
service (NGINX, WordPress, MariaDB) has its own Dockerfile built on
`debian:bookwarm`, wired together with `docker-compose` and run inside a
Debian virtual machine.

## Architecture

```
                     ┌─────────────┐
   HTTPS :443  ───▶  │    nginx    │  TLS termination (self-signed cert, TLS 1.3)
                     └──────┬──────┘
                            │  fastcgi (php-fpm)
                     ┌──────▼──────┐
                     │  wordpress  │  PHP-FPM, no built-in web server
                     └──────┬──────┘
                            │  mysql
                     ┌──────▼──────┐
                     │   mariadb   │  database
                     └─────────────┘
```

- **nginx** — the only service exposed to the outside world. Terminates TLS
  (self-signed certificate generated at build time) and forwards PHP
  requests to WordPress over FastCGI. Runs in the foreground (`daemon off;`).
- **wordpress** — runs `php-fpm` only (no NGINX/Apache bundled in). The
  entrypoint script waits for MariaDB, configures `wp-config.php` from
  environment variables/secrets, and installs WordPress on first boot if it
  isn't already set up.
- **mariadb** — the database. The entrypoint script initializes the data
  directory, creates the WordPress database, and creates the admin/user
  accounts on first run.

Each service is isolated in its own container, on its own Docker network,
communicating only over the ports it needs to expose to the others.

## Project layout

```
.
├── Makefile
├── secrets/
│   ├── db_password
│   ├── db_root_password
│   ├── wp_admin_password
│   └── wp_user_password
└── srcs/
    ├── docker-compose.yaml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   └── tools/mariadb_script.sh
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/nginx.conf
        └── wordpress/
            ├── Dockerfile
            └── tools/wordpress_script.sh
```

## Secrets

Credentials are never hardcoded into the Dockerfiles or committed as plain
environment variables. Instead, they're read from files in `secrets/` and
injected via Docker secrets / bind mounts at runtime:

| File | Purpose |
|---|---|
| `db_root_password` | MariaDB root password |
| `db_password` | Password for the WordPress database user |
| `wp_admin_password` | WordPress admin account password |
| `wp_user_password` | WordPress regular user account password |

> These files are excluded from version control — populate them locally
> before running `make`.

## Requirements

- Docker & Docker Compose
- A `.env` file (domain name, DB name/user, WP admin/user info — none of it
  secret) alongside `srcs/docker-compose.yaml`
- The `secrets/` files listed above, filled in

## Usage

```bash
make          # build images and start all containers (detached)
make down     # stop and remove containers
make clean    # down + remove images
make fclean   # clean + remove volumes/data (full reset)
make re       # fclean + up again
```

Once running, the site is reachable at `https://oukhiar.42.fr` (self-signed
cert, so the browser will warn about it — that's expected).

## Notes

- All containers are built `FROM debian:bookwarm` — no `latest` tags, no
  ready-made service images.
- Containers restart automatically (`restart: always` / `on-failure`) so the
  stack survives a VM reboot.
- Data (MariaDB database files, WordPress files/uploads) is persisted in
  named Docker volumes, bind-mounted to `/home/oukhiar/data` on the host, so
  content isn't lost when containers are recreated.