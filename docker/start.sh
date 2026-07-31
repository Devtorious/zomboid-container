#!/usr/bin/env bash
set -euo pipefail

TIMEZONE="${TIMEZONE:-UTC}"
STEAM_APP_ID="${STEAM_APP_ID:-380870}"
STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/data/steamcmd}"
ZOMBOID_SERVER_DIR="${ZOMBOID_SERVER_DIR:-/data/pzserver}"
UPDATE_ON_START="${UPDATE_ON_START:-1}"
ZOMBOID_SERVER_NAME="${ZOMBOID_SERVER_NAME:-servertest}"

if [[ -f "/usr/share/zoneinfo/${TIMEZONE}" ]]; then
  ln -snf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
  echo "${TIMEZONE}" > /etc/timezone
fi

mkdir -p "${STEAM_INSTALL_DIR}" "${ZOMBOID_SERVER_DIR}" /data

if ! command -v FEXBash >/dev/null 2>&1; then
  echo "FEXBash not found. Check FEX installation in the container image." >&2
  exit 1
fi

if ! FEXBash -c 'true' >/dev/null 2>&1; then
  echo "Initializing FEX rootfs (first run may take a while)..."
  if command -v FEXRootFSFetcher >/dev/null 2>&1; then
    yes | FEXRootFSFetcher || true
  fi
fi

if ! FEXBash -c 'true' >/dev/null 2>&1; then
  echo "FEX rootfs initialization failed. Ensure this container runs privileged with seccomp=unconfined." >&2
  exit 1
fi

if [[ ! -x "${STEAM_INSTALL_DIR}/steamcmd.sh" ]]; then
  echo "Installing SteamCMD..."
  curl -fsSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -o /tmp/steamcmd_linux.tar.gz
  tar -xzf /tmp/steamcmd_linux.tar.gz -C "${STEAM_INSTALL_DIR}"
  rm -f /tmp/steamcmd_linux.tar.gz
fi

if [[ "${UPDATE_ON_START}" == "1" || ! -x "${ZOMBOID_SERVER_DIR}/start-server.sh" ]]; then
  echo "Updating/installing Project Zomboid dedicated server (app ${STEAM_APP_ID})..."
  FEXBash -c "\"${STEAM_INSTALL_DIR}/steamcmd.sh\" +@sSteamCmdForcePlatformType linux +force_install_dir \"${ZOMBOID_SERVER_DIR}\" +login anonymous +app_update \"${STEAM_APP_ID}\" validate +quit"
fi

if [[ ! -x "${ZOMBOID_SERVER_DIR}/start-server.sh" ]]; then
  echo "Could not find ${ZOMBOID_SERVER_DIR}/start-server.sh after install." >&2
  exit 1
fi

echo "Starting Project Zomboid server: ${ZOMBOID_SERVER_NAME}"
exec FEXBash -c "cd \"${ZOMBOID_SERVER_DIR}\" && ./start-server.sh \"${ZOMBOID_SERVER_NAME}\""
