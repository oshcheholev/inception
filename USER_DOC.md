# *This project has been created as part of the 42 curriculum by oshcheho.*

# USER DOCUMENTATION

## Overview

This project is a Docker-based infrastructure stack created for the Inception project.

The stack contains 3 main services:

- **NGINX**
  - Reverse proxy and web server
  - Handles HTTPS connections
  - Serves the WordPress website

- **WordPress**
  - PHP-based CMS
  - Main website service
  - Connected to MariaDB database

- **MariaDB**
  - Database server
  - Stores WordPress data, users, posts, settings, etc.

All services run inside separate Docker containers and communicate through a Docker network.

---

# Starting the project

Build and start all containers:

```bash
make up
```

or manually:

```bash
docker compose -f srcs/docker-compose.yml up --build -d
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

Stop and remove volumes:

```bash
make clean
```

or:

```bash
docker compose -f srcs/docker-compose.yml down -v
```

---

# Accessing the website

After starting the project, open:

```text
https://localhost
```

or:

```text
https://oshcheho.42.fr
```

Because a self-signed SSL certificate is used, the browser may display a security warning. This is expected.

---

# Accessing WordPress admin panel

Open:

```text
https://oshcheho/wp-admin
```

Login using the administrator credentials created during WordPress setup.

---

# Credentials and configuration

Project credentials are stored in:

```text
srcs/.env
```

Example variables:

```env

WP_ADMIN_USER=admin
WP_ADMIN_EMAIL=admin@example.com
```

All secrets (passwords) are stored in special folder: /secrets
Sensitive files and secrets are mounted into containers through Docker volumes.

---

# Checking container status

List running containers:

```bash
docker ps
```

Expected containers:

```text
nginx
wordpress
mariadb
```

---

# Checking logs

Show logs from all services:

```bash
make logs
```

or:

```bash
docker compose -f srcs/docker-compose.yml logs
```

Check logs for a specific container:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

---

# Checking volumes

List Docker volumes:

```bash
docker volume ls
```

Project volumes:

```text
srcs_wordpress
srcs_mariadb
```

Persistent data is stored inside:

```text
/home/oshcheho/data
```

---

# Checking network

List Docker networks:

```bash
docker network ls
```

Inspect project network:

```bash
docker network inspect srcs_inception_network
```

---

# Entering containers

Open shell inside a container:

```bash
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash
```

---

# MariaDB access

Connect to MariaDB from inside the container:

```bash
docker exec -it mariadb bash
```

Then:

```bash
mariadb -u root -p
```

---

# Restarting services

Restart all services:

```bash
docker compose restart
```

Restart single service:

```bash
docker restart nginx
docker restart wordpress
docker restart mariadb
```

---

# Common issues

## 403 Forbidden

Usually means:
- WordPress files are missing
- wrong NGINX root path
- incorrect permissions

Check:

```bash
docker exec -it wordpress ls -la /var/www/html
```

---

## WordPress stuck on "Waiting for MariaDB"

Usually caused by:
- wrong database credentials
- wrong DB host
- MariaDB not ready yet

Database host must be:

```text
mariadb
```

not:

```text
localhost
```

---

## Containers do not start

Check logs:

```bash
make logs
```

and verify:
- ports are free
- volumes exist
- `.env` variables are correct

---

# Project structure

```text
inception/
├── Makefile
├── secrets/
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── nginx/
        ├── wordpress/
        └── mariadb/
```