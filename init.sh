#!/bin/bash

set -euo pipefail

WORKDIR="/opt/dtrack"

# ------ Validate working directory ------
if [ ! -d "$WORKDIR" ]; then
  echo "[init] ERROR: Working directory ${WORKDIR} does not exist. Run start.sh first."
  exit 1
fi

if [ ! -f "${WORKDIR}/docker-compose.yml" ]; then
  echo "[init] ERROR: docker-compose.yml not found in ${WORKDIR}. Run run.sh first."
  exit 1
fi

cd "$WORKDIR"


# ------ Fetching Secrets ------ 

echo "[init] Fetching region from instance metadata..."
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

fetch() {
  aws ssm get-parameter \
    --name "$1" \
    --with-decryption \
    --query "Parameter.Value" \
    --output text \
    --region "$REGION"
}

echo "[init] Fetching secrets from SSM Parameter Store..."
export POSTGRES_ROOT_PASSWORD=$(fetch "/deptrack/postgres-root-password") || true
export DT_DB_PASSWORD=$(fetch "/deptrack/dt-db-password") || true
export NPM_DB_PASSWORD=$(fetch "/deptrack/npm-db-password") || true

if [[ -z "$POSTGRES_ROOT_PASSWORD" || -z "$DT_DB_PASSWORD" || -z "$NPM_DB_PASSWORD" ]]; then
  echo "[init] Error: One or more secrets are empty. Check SSM Parameter Store."
  echo "[init] Using Random Passwords (Not Recommended for Production):"
  export POSTGRES_PASSWORD="63421937fgwudfbshc"
  export DT_DB_PASSWORD="jjkuhh7yhgugu"
  export NPM_DB_PASSWORD="gfhdf76879asdfhjee"
fi

echo "[init] Secrets loaded."

# ------ Generate init-db.sql and Start Docker Compose ------ 

# PostgreSQL starts with a single superuser. This creates the two separate databases and their dedicated users on first boot.
echo "[init] Generating init-db.sql..."
cat > "${WORKDIR}/init-db.sql" <<EOF
CREATE USER deptrack WITH PASSWORD '${DT_DB_PASSWORD}';
CREATE DATABASE deptrack OWNER deptrack;
GRANT ALL PRIVILEGES ON DATABASE deptrack TO deptrack;

CREATE USER npm WITH PASSWORD '${NPM_DB_PASSWORD}';
CREATE DATABASE npm OWNER npm;
GRANT ALL PRIVILEGES ON DATABASE npm TO npm;
EOF
chmod 644 "${WORKDIR}/init-db.sql"
echo "[init] init-db.sql generated."

echo "[init] Starting Docker Compose..."
docker compose -p dtack -f "${WORKDIR}/docker-compose.yml" down -v
docker compose -p dtack -f "${WORKDIR}/docker-compose.yml" up -d  --wait
docker image prune -f --filter "until=24h"
