# *This project has been created as part of the 42 curriculum by oshcheho.*

# Inception

## Description

The goal of this project is to build a small infrastructure using Docker and Docker Compose.  
Each service runs inside its own container and communicates through a Docker network.

The project is based on a WordPress website running with:
- NGINX
- WordPress + PHP-FPM
- MariaDB

Additional bonus services were added:
- Redis cache
- FTP server
- Adminer
- Flask monitoring dashboard
- cAdvisor monitoring system

The infrastructure is fully containerized and persistent data is stored inside Docker volumes.

The project helped me better understand:
- Docker and containerization
- networking between containers
- reverse proxy architecture
- volumes and persistent storage
- service isolation
- infrastructure monitoring
- basic DevOps concepts

## Design choices

## Docker vs Virtual Machines

Main Docker advantages:

it is lighter and faster
it shares the host kernel
it allows easier service separation
it is more efficient for microservices

Virtual machines emulate full operating systems and consume more resources.

## Secrets vs Environment variables

Environment variables are used for:

configuration
ports
system paths
service names
user names

Secrets are used for:

passwords
sensitive credentials

Secrets are stored separately from code and mounted into containers at runtime.

## Docker network vs Host network

A bridge network is used in this project.

Advantages:

containers can communicate using service names
isolation from the host system
better security

Host network mode is not used because it removes isolation and is less secure.

## Volumes vs Bind mounts

Docker volumes are used for persistent data:

WordPress files
MariaDB database

Volumes are preferred because:

they are managed by Docker
they are portable
they are safer than bind mounts

Bind mounts depend on the host filesystem and are avoided in this project.

---

# Project Structure

```bash
.
├── Makefile
├── secrets/
├── srcs/
│   ├── docker-compose.yml
│   ├── .env
│   └── requirements/
│       ├── nginx/
│       ├── mariadb/
│       ├── wordpress/
│       ├── redis/
│       ├── ftp/
│       ├── adminer/
│       ├── webpage/
│       └── cadvisor/

```

# Services

## NGINX

NGINX is the entry point of the whole infrastructure.

It is responsible for:
- HTTPS connection (SSL)
- reverse proxy to WordPress
- routing requests to the correct container

NGINX is the only service exposed to the host machine. All other services are internal.

It forwards PHP requests to PHP-FPM inside the WordPress container.

---

## WordPress + PHP-FPM

This is the main application of the project.

WordPress runs inside PHP-FPM and is served through NGINX.

It is responsible for:
- generating the website
- handling user requests
- WordPress installation
- plugin management (Redis cache)

WordPress files are stored in a Docker volume to persist data.

---

## MariaDB

MariaDB is the database service used by WordPress.

It stores:
- users
- posts
- comments
- configuration data

The database is initialized automatically at container startup using a script.

Credentials are not hardcoded and are loaded from Docker secrets.

---
## Bonus

## Redis

Redis is used as a cache layer for WordPress.

It improves performance by:
- storing frequently accessed data in memory
- reducing load on MariaDB
- speeding up page rendering

Redis communicates internally with WordPress using the Docker network.

---

## FTP Server

The FTP server is used to manage WordPress files externally.

It allows:
- uploading files to the WordPress volume
- editing website content without entering containers
- remote file management

The FTP container shares the same volume as WordPress.

---

## Adminer

Adminer is a lightweight database administration tool.

It provides:
- graphical interface for MariaDB
- ability to run SQL queries
- database inspection and debugging

Adminer connects directly to MariaDB through the internal network.

---

## Monitoring Webpage (Flask Dashboard)

A custom monitoring service built with Python and Flask.

It provides a simple real-time dashboard showing:
- WordPress status
- MariaDB status
- Redis status
- NGINX status
- FTP status
- Adminer status

It works by checking TCP/HTTP connectivity between containers.

This simulates a simplified production monitoring system.

---

## cAdvisor

cAdvisor is a container monitoring tool.

It provides real-time metrics about Docker containers:
- CPU usage
- memory usage
- network usage
- disk usage

It gives visibility into how containers behave during runtime.

---

# Instructions

## Clone repository

```bash
git clone <repository>
cd inception
```

---

## Configure domain

Add the domain to `/etc/hosts`:

```bash
127.0.0.1 oshcheho.42.fr
```

This is required to access the project using the domain name instead of localhost.

---

## Create secrets

All sensitive data is stored in the `secrets/` directory and mounted into containers at runtime.

```bash
mkdir -p secrets

echo "pass" > secrets/credentials.txt
echo "pass" > secrets/db_password.txt
echo "root_pass" > secrets/db_root_password.txt
echo "pass" > secrets/ftp_password.txt
echo "pass" > secrets/wp_password.txt
echo "pass" > secrets/wp_user2_password.txt

```

Secrets are used instead of hardcoded credentials in environment variables or images.
Of course, in production passwords should be much stronger!
---

## Build and run mandatory part

Start the core infrastructure:

```bash
make up
```

This launches:
- NGINX
- WordPress + PHP-FPM
- MariaDB

All services are connected through a Docker network and use volumes for persistence.

---

## Build and run bonus part

Start full infrastructure including bonus services:

```bash
make bonus
```

This adds:
- Redis cache
- FTP server
- Adminer
- Flask monitoring dashboard
- cAdvisor

---

## Stop containers

```bash
make down
```

Stops all running containers while preserving volumes and data.

---

## Clean everything

```bash
make fclean
```

Removes containers, images, and volumes depending on implementation.

⚠️ This will delete all persistent data including database and WordPress content.

---

# Access

## Main website

```text
https://oshcheho.42.fr
```

WordPress is served via NGINX with HTTPS enabled.

---

## Adminer

```text
http://oshcheho.42.fr:8080
```

Web interface for managing the MariaDB database.
- Server - Mariadb
- Username - .env -> DB_USER
- Password - secrets - db.password.txt
- Database - wordpress

---

## Monitoring dashboard

```text
http://oshcheho.42.fr:8001
```

Flask-based monitoring system showing live status of all services.

---

## cAdvisor

```text
http://oshcheho.42.fr:8081
```

Container metrics dashboard showing CPU, memory, and network usage.

---

# Notes

- Only NGINX is exposed to the host machine
- All other services communicate through a private Docker network
- Persistent data is stored using Docker volumes
- Sensitive information is stored using Docker secrets
- Each service runs in a separate container for isolation
- To connect to db run
```bash
   docker exec -it mariadb bash
```

   - then
```bash
   mariadb -u root -p
```
---

# Main Concepts Learned
- Docker image creation
- Docker Compose orchestration
- service isolation
- reverse proxy architecture
- SSL/TLS configuration
- container networking
- persistent storage
- infrastructure monitoring
- Redis caching
- basic DevOps practices

# Resources
## Documentation
- Docker documentation
- Docker Compose documentation
- NGINX documentation
- MariaDB documentation
- WordPress documentation
- Additional services documentation
## Tutorials and References
- DigitalOcean Docker tutorials
- Medium articles about Docker networking
- WordPress + Mysql + Nginx setup guides
- LinuxServer Docker examples

# AI Usage

## AI tools were mainly used for:

- understanding Docker networking concepts
- debugging container issues
- researching Redis and monitoring setup
- improving infrastructure design ideas
- structuring Readme.md

All implementation, debugging, configuration, integration and testing were done manually.