# Project Zomboid Dedicated Server (ARM64 + FEX-EMU)

This repository provides a CasaOS-friendly Docker Compose setup for running the x86_64 SteamCMD + Project Zomboid dedicated server on an ARM64 host (for example Orange Pi) using FEX-EMU.

## Deploy (CasaOS)

1. Open CasaOS **Custom Install** and paste this repository's `docker-compose.yml`.
2. Set environment variables if needed (or keep defaults).
3. Deploy and start the app.

## First run expectations

- The first startup can take several minutes:
  - FEX rootfs initialization runs if needed.
  - SteamCMD is downloaded.
  - App `380870` (Project Zomboid dedicated server) is installed/updated.
- Later starts are faster. Set `UPDATE_ON_START=0` to skip update checks each boot.

## Persistence

- Host path defaults to `./data` (set with `PZ_DATA_PATH`).
- In-container data path: `/data`.
- Main server files default to `/data/pzserver`.

## Ports

- `16261/udp` main server port
- `16262-16272/udp` default player slot range
- Optional RCON (commented): `27015/tcp`

## Key environment variables

- `TIMEZONE` (default `UTC`)
- `STEAM_APP_ID` (default `380870`)
- `STEAM_INSTALL_DIR` (default `/data/steamcmd`)
- `ZOMBOID_SERVER_DIR` (default `/data/pzserver`)
- `UPDATE_ON_START` (`1` or `0`, default `1`)
- `ZOMBOID_SERVER_NAME` (default `servertest`)

## Server settings

After first boot, edit Project Zomboid server config files under `/data/Zomboid/Server/` (inside the volume on the host), then restart the container.

## Basic troubleshooting (ARM64/FEX)

- If startup fails early, confirm the service runs with `privileged: true` and `seccomp=unconfined`.
- Ensure your ARM CPU/board supports FEX requirements.
- Check container logs for `FEXRootFSFetcher` or `steamcmd` failures and restart after fixing.
