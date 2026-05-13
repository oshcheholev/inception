# *This project has been created as part of the 42 curriculum by oshcheho.*

# DEVELOPER DOCUMENTATION

## Overview

This project is a Docker-based infrastructure stack created for the Inception project.

The infrastructure consists of:
- NGINX
- WordPress with PHP-FPM
- MariaDB

Each service runs inside its own container and communicates through a dedicated Docker network.

---

# Prerequisites

Required software:

- Docker
- Docker Compose
- GNU Make

Check installation:

```bash
docker --version
docker compose version
make --version
```

On Linux, Docker daemon must be running:

```bash
sudo systemctl start docker
```

Optional:

```bash
sudo systemctl enable docker
```

---

# Project structure

```text
inception/
├── Makefile
├── secrets/
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/
        └── mariadb/
            ├── Dockerfile
            └── tools/
```

---

# Environment configuration

Main configuration variables are stored in:

```text
srcs/.env
```

Example:

```env
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user

WP_ADMIN_USER=admin
WP_ADMIN_EMAIL=admin@example.com

DOMAIN_NAME=login.42.fr
```

---

# Secrets

Sensitive files are stored inside:

```text
secrets/
```

Secrets are mounted into containers by docker.

---

# Persistent data

Project data is stored inside:

```text
/home/<login>/data
```

Directories:

```text
/home/<login>/data/mariadb
/home/<login>/data/wordpress
```

Docker volumes map these directories into containers.

Example:

```yaml
volumes:
  mariadb:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/${USER}/data/mariadb
```

This allows database and WordPress files to persist after container rebuilds or restarts.

---

# Building the project

Build all images:

```bash
make build
```

Equivalent command:

```bash
docker compose -f srcs/docker-compose.yml build
```

---

# Starting the project

Start infrastructure:

```bash
make up
```

This command:
- creates required data directories
- builds images if needed
- creates volumes and network
- starts all containers

Equivalent command:

```bash
docker compose -f srcs/docker-compose.yml up -d
```

---

# Stopping the project

Stop containers:

```bash
make down
```

or:

```bash
docker compose -f srcs/docker-compose.yml down
```

---

# Removing containers, networks and volumes

Clean project:

```bash
make fclean
```

or manually:

```bash
docker compose -f srcs/docker-compose.yml down -v
```

Remove images:

```bash
docker system prune -a
```

---

# Useful Docker commands

List containers:

```bash
docker ps
```

List images:

```bash
docker images
```

List volumes:

```bash
docker volume ls
```

List networks:

```bash
docker network ls
```

---

# Container management

Restart services:

```bash
docker restart nginx
docker restart wordpress
docker restart mariadb
```

Open shell inside container:

```bash
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash
```

---

# Logs

Show logs from all services:

```bash
make logs
```

or:

```bash
docker compose -f srcs/docker-compose.yml logs
```

Logs for specific container:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

---

# MariaDB access

Enter MariaDB container:

```bash
docker exec -it mariadb bash
```

Connect to database:

```bash
mariadb -u root -p
```

Useful SQL commands:

```sql
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
```

---

# Networking

Project uses a dedicated Docker bridge network:

```text
srcs_inception_network
```

Containers communicate internally using service names:

```text
mariadb
wordpress
nginx
```

Example:

```bash
ping mariadb
```

from inside the wordpress container.

---

---

# Notes

- Containers are isolated and communicate only through the Docker network.
- Data persists through Docker volumes.
- Services restart automatically because of:
  
```yaml
restart: unless-stopped
```

- HTTPS is handled by NGINX using SSL certificates.