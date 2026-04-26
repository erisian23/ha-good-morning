#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

LOCAL_PACKAGE_DIR="${REPO_ROOT}/home-assistant/packages/good_morning"
REMOTE_HOST="haos-vm"
REMOTE_PACKAGES_DIR="/config/packages"
REMOTE_PACKAGE_DIR="${REMOTE_PACKAGES_DIR}/good_morning"
REMOTE_BACKUP_DIR="${REMOTE_PACKAGES_DIR}/.backups"
STAMP="$(date +%Y%m%d-%H%M%S)"
REMOTE_BACKUP_PACKAGE_DIR="${REMOTE_BACKUP_DIR}/good_morning.${STAMP}"

echo "Repo root: ${REPO_ROOT}"
echo "Local package: ${LOCAL_PACKAGE_DIR}"
echo "Remote package: ${REMOTE_HOST}:${REMOTE_PACKAGE_DIR}"

if [[ ! -f "${LOCAL_PACKAGE_DIR}/package.yaml" ]]; then
  echo "ERROR: package.yaml not found at ${LOCAL_PACKAGE_DIR}/package.yaml" >&2
  exit 1
fi

if [[ ! -d "${LOCAL_PACKAGE_DIR}/scripts" ]]; then
  echo "ERROR: scripts directory not found at ${LOCAL_PACKAGE_DIR}/scripts" >&2
  exit 1
fi

echo
echo "Checking SSH connectivity..."
ssh "${REMOTE_HOST}" 'test -d /config && echo "Connected to HAOS SSH add-on."'

echo
echo "Preparing remote package directory and backup..."
ssh "${REMOTE_HOST}" "
  set -euo pipefail
  mkdir -p '${REMOTE_PACKAGES_DIR}' '${REMOTE_BACKUP_DIR}'
  if [ -d '${REMOTE_PACKAGE_DIR}' ]; then
    cp -a '${REMOTE_PACKAGE_DIR}' '${REMOTE_BACKUP_PACKAGE_DIR}'
    echo 'Backed up existing package to ${REMOTE_BACKUP_PACKAGE_DIR}'
  else
    echo 'No existing package to back up.'
  fi
"

echo
echo "Uploading package to temporary location..."
ssh "${REMOTE_HOST}" "rm -rf '${REMOTE_PACKAGE_DIR}.new' && mkdir -p '${REMOTE_PACKAGE_DIR}.new'"
scp -r "${LOCAL_PACKAGE_DIR}/." "${REMOTE_HOST}:${REMOTE_PACKAGE_DIR}.new/"

echo
echo "Installing uploaded package..."
ssh "${REMOTE_HOST}" "
  set -euo pipefail
  rm -rf '${REMOTE_PACKAGE_DIR}'
  mv '${REMOTE_PACKAGE_DIR}.new' '${REMOTE_PACKAGE_DIR}'
"

echo
echo "Running Home Assistant config check..."
if ssh "${REMOTE_HOST}" "ha core check"; then
  echo "Config check passed."
else
  echo
  echo "ERROR: Config check failed. Rolling back..."
  ssh "${REMOTE_HOST}" "
    set -euo pipefail
    rm -rf '${REMOTE_PACKAGE_DIR}'
    if [ -d '${REMOTE_BACKUP_PACKAGE_DIR}' ]; then
      cp -a '${REMOTE_BACKUP_PACKAGE_DIR}' '${REMOTE_PACKAGE_DIR}'
      echo 'Restored backup package.'
    else
      echo 'No backup package existed. Package removed.'
    fi
  "
  exit 1
fi

echo
echo "Reloading Home Assistant core YAML..."
ssh "${REMOTE_HOST}" "ha core reload"

echo
echo "Deployment complete."
