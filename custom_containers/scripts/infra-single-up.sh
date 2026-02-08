#!/usr/bin/env bash
set -euo pipefail

# Install Docker Engine + Docker Compose plugin (v2) on Ubuntu/Debian
# Idempotent: re-running won't break anything.

if [[ $EUID -ne 0 ]]; then
  SUDO="sudo"
else
  SUDO=""
fi

log() { echo -e "✅ $*"; }
warn() { echo -e "⚠️  $*"; }
err() { echo -e "❌ $*" >&2; }

# Quick check
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  log "Docker and Docker Compose are already installed."
  docker --version
  docker compose version
  exit 0
fi

log "Installing prerequisites..."
$SUDO apt-get update -y
$SUDO apt-get install -y ca-certificates curl gnupg

log "Setting up Docker apt keyring..."
$SUDO install -m 0755 -d /etc/apt/keyrings

# Download & dearmor key (always refresh to avoid old/broken keys)
$SUDO rm -f /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO gpg --dearmor -o /etc/apt/keyrings/docker.gpg
$SUDO chmod a+r /etc/apt/keyrings/docker.gpg

log "Adding Docker repository..."
CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME:-}")"
if [[ -z "$CODENAME" ]]; then
  err "Could not detect Ubuntu codename from /etc/os-release"
  exit 1
fi

ARCH="$(dpkg --print-architecture)"
$SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null <<EOF
deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable
EOF

log "Installing Docker Engine + Compose plugin..."
$SUDO apt-get update -y
$SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

log "Enabling Docker service..."
$SUDO systemctl enable --now docker

# Add current user to docker group (so you can run docker without sudo)
USER_TO_ADD="${SUDO_USER:-$USER}"
if id -nG "$USER_TO_ADD" | grep -qw docker; then
  log "User '$USER_TO_ADD' is already in docker group."
else
  log "Adding user '$USER_TO_ADD' to docker group..."
  $SUDO usermod -aG docker "$USER_TO_ADD"
  warn "Log out / log in (or run: newgrp docker) to use docker without sudo."
fi

log "Installed successfully:"
docker --version || true
docker compose version || true
