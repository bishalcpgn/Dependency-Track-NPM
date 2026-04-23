#!/bin/bash
# Run this ONCE on the server to bootstrap everything
# curl -fsSL https://raw.githubusercontent.com/<username>/<repo>/main/infra/deptrack/bootstrap.sh | bash

set -euo pipefail

WORKDIR="/opt/deptrack"
GITHUB_RAW="https://github.com/bishalcpgn/Dependency-Track-NPM/blob/main/run.sh"

echo "[bootstrap] Creating working directory..."
sudo mkdir -p "$WORKDIR"
sudo chown "$USER:$USER" "$WORKDIR"
chmod 750 "$WORKDIR"

echo "[bootstrap] Downloading files from GitHub..."
curl -fsSL "${GITHUB_RAW}/init.sh"            -o "${WORKDIR}/init.sh"
curl -fsSL "${GITHUB_RAW}/docker-compose.yml" -o "${WORKDIR}/docker-compose.yml"

echo "[bootstrap] Setting permissions..."
chmod 700 "${WORKDIR}/init.sh"
chmod 600 "${WORKDIR}/docker-compose.yml"

echo "[bootstrap] Verifying downloads..."
[ -s "${WORKDIR}/init.sh" ]            || { echo "[bootstrap] ERROR: init.sh is empty or missing."; exit 1; }
[ -s "${WORKDIR}/docker-compose.yml" ] || { echo "[bootstrap] ERROR: docker-compose.yml is empty or missing."; exit 1; }

echo "[bootstrap] Running init.sh..."
"${WORKDIR}/init.sh"
