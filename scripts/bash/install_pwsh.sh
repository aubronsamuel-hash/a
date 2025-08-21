#!/usr/bin/env bash
set -euo pipefail

# Installe PowerShell 7 (pwsh) sur Debian/Ubuntu via le depot Microsoft.

# Utilisation:

# sudo bash scripts/bash/install_pwsh.sh

if [ "$(id -u)" -ne 0 ]; then
  echo "[ERROR] Ce script doit etre lance en root (sudo)." >&2
  exit 1
fi
. /etc/os-release
echo "[INFO] Distribution: $NAME $VERSION_ID"

# Dependances

apt-get update -y
apt-get install -y wget ca-certificates apt-transport-https gnupg lsb-release

# Depot Microsoft

MS_REPO_PKG="packages-microsoft-prod.deb"
wget -q "https://packages.microsoft.com/config/${ID}/${VERSION_ID}/packages-microsoft-prod.deb" \
  -O "/tmp/${MS_REPO_PKG}" || {
  echo "[WARN] URL repo pour ${ID}/${VERSION_ID} indisponible. Tentative fallback Ubuntu 22.04..." >&2
  wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O "/tmp/${MS_REPO_PKG}"
}
dpkg -i "/tmp/${MS_REPO_PKG}"
apt-get update -y

# Installer PowerShell 7

apt-get install -y powershell
echo "[OK] pwsh installe. Version:"
pwsh -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion'
