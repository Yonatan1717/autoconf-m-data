#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SOURCE="${REPO_ROOT}/generated/freeradius/clients_network_switches.conf"
DEST="${SCRIPT_DIR}/config/clients.conf"

if [[ ! -f "${SOURCE}" ]]; then
    echo "Fant ikke ${SOURCE}. Kjør generatoren først."
    exit 1
fi

cp "${SOURCE}" "${DEST}"
echo "Oppdatert ${DEST} fra generator-output. Kontroller RADIUS-secret før oppstart."
