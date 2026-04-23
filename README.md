# Dependency-Track Setup

This repository contains scripts to bootstrap and initialize [OWASP Dependency-Track](https://dependencytrack.org/) with PostgreSQL using Docker Compose and [Nginx Proxy Manager](https://nginxproxymanager.com/).

## Quick Start

Run this command on your server to download and execute the bootstrap script:

```bash
curl -fsSL https://raw.githubusercontent.com/bishalcpgn/Dependency-Track-NPM/main/run.sh | bash
```

## What It Does

The bootstrap script:
1. Creates the working directory at `/opt/dtrack`
2. Downloads the necessary files (`init.sh` and `docker-compose.yml`)
3. Sets appropriate permissions
4. Runs the initialization script to:
   - Fetch secrets from AWS SSM Parameter Store
   - Generate the database initialization SQL
   - Start Docker containers with Docker Compose

## Prerequisites

- `curl` - to download the bootstrap script
- `docker` and `docker compose` - to run the containers
- AWS CLI configured with credentials (if using SSM Parameter Store for secrets)
- Appropriate permissions to use `sudo` and create directories

#### 1. Docker
[Official Docker Documentation](https://docs.docker.com/get-docker/)

**Ubuntu/Debian:**
```bash
# Remove existing packages
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)

# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

# Install docker and docker-compose-plugin
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to Docker group
sudo usermod -aG docker $USER
newgrp docker

# Start and enable Docker service
sudo systemctl enable docker
sudo systemctl start docker
```


Verify installation:
```bash
docker --version
docker compose version
```

> This setup uses Docker Compose v2 (`docker compose`), not v1 (`docker-compose`). v1 uses a hyphen (`docker-compose`) and v2 uses a space (`docker compose`).


#### 3. AWS CLI (Only if using AWS SSM Parameter Store for secrets)
[Official AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install awscli
```

## Files

- **run.sh** - Main bootstrap script (run this once)
- **init.sh** - Database initialization script (called by run.sh)
- **docker-compose.yml** - Docker Compose configuration for the services

## Verify 
```bash
# List all running containers
docker ps

# Tail logs of all containers
docker compose -f /opt/deptrack/docker-compose.yml logs -f | less

# Tail logs of a specific container
docker compose -f /opt/deptrack/docker-compose.yml logs -f dt-apiserver | less
```

## Notes

- The script uses AWS SSM Parameter Store to fetch secrets. If secrets are not found, it will use default passwords.
- All files are downloaded to `/opt/deptrack`
- Ensure proper permissions and security for the working directory


