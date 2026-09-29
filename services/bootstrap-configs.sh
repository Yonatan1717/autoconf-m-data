#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

copy_if_missing() {
    local src="$1"
    local dst="$2"
    if [[ -e "$dst" ]]; then
        echo "Beholder eksisterende: $dst"
    else
        cp "$src" "$dst"
        echo "Opprettet: $dst"
    fi
}

copy_if_missing .env.example .env
copy_if_missing freeradius/config/clients.conf.example freeradius/config/clients.conf
copy_if_missing freeradius/config/authorize.example freeradius/config/authorize
copy_if_missing tacacs-ng/config/tac_plus-ng.cfg.example tacacs-ng/config/tac_plus-ng.cfg

echo
echo "Neste steg: bytt alle CHANGE_ME_* verdier før docker compose up."
