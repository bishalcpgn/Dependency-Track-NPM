# Dependency-Track Setup

This repository contains scripts to bootstrap and initialize [OWASP Dependency-Track](https://dependencytrack.org/) with PostgreSQL using Docker Compose and [Nginx Proxy Manager](https://nginxproxymanager.com/).

## Quick Start

Run this command on your server to download and execute the bootstrap script:

```bash
curl -fsSL https://raw.githubusercontent.com/bishalcpgn/Dependency-Track-NPM/main/infra/deptrack/run.sh | bash
```

## What It Does

The bootstrap script:
1. Creates the working directory at `/opt/deptrack`
2. Downloads the necessary files (`init.sh` and `docker-compose.yml`)
3. Sets appropriate permissions
4. Runs the initialization script to:
   - Fetch secrets from AWS SSM Parameter Store
   - Generate the database initialization SQL
   - Start Docker containers with Docker Compose

## Prerequisites

- `curl` - to download the bootstrap script
- `docker` and `docker-compose` - to run the containers
- AWS CLI configured with credentials (if using SSM Parameter Store for secrets)
- Appropriate permissions to use `sudo` and create directories

## Files

- **run.sh** - Main bootstrap script (run this once)
- **init.sh** - Database initialization script (called by run.sh)
- **docker-compose.yml** - Docker Compose configuration for the services

## Notes

- The script uses AWS SSM Parameter Store to fetch secrets. If secrets are not found, it will generate random passwords (not recommended for production).
- All files are downloaded to `/opt/deptrack`
- Ensure proper permissions and security for the working directory
