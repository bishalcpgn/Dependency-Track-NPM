#!/bin/bash
set -euo pipefail

WORKDIR="/opt/deptrack"
GITHUB_RAW="https://raw.githubusercontent.com/bishalcpgn/Dependency-Track-NPM/main"

echo "[bootstrap] Creating working directory..."
sudo mkdir -p "$WORKDIR"
sudo chown "$USER:$USER" "$WORKDIR"
chmod 750 "$WORKDIR"

echo "[bootstrap] Downloading files from GitHub..."

download_file() {
    local url="$1"
    local output="$2"

    echo "[bootstrap] -> Fetching ${url}"
    if ! curl -fL "$url" -o "$output"; then
        echo "[bootstrap] ERROR: Failed to download ${url}"
        exit 1
    fi
}

download_file "${GITHUB_RAW}/init.sh" "${WORKDIR}/init.sh"
download_file "${GITHUB_RAW}/docker-compose.yml" "${WORKDIR}/docker-compose.yml"

echo "[bootstrap] Setting permissions..."
chmod 700 "${WORKDIR}/init.sh"
chmod 600 "${WORKDIR}/docker-compose.yml"

echo "[bootstrap] Verifying downloads..."
if [[ ! -s "${WORKDIR}/init.sh" ]]; then
    echo "[bootstrap] ERROR: init.sh is empty or missing."
    exit 1
fi

if [[ ! -s "${WORKDIR}/docker-compose.yml" ]]; then
    echo "[bootstrap] ERROR: docker-compose.yml is empty or missing."
    exit 1
fi

echo "[bootstrap] Running init.sh..."
exec "${WORKDIR}/init.sh"
