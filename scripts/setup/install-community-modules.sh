#!/bin/bash
set -euo pipefail

DEST="/usr/local/lib/prosody/community-modules"
ROCKS_SERVER="https://modules.prosody.im/rocks/"

# Use the Prosody plugin installer (LuaRocks) for community modules
ROCKS_MODULES=()

usage() {
    echo "Usage: $0 module1 [module2 ...]"
    echo "  Examples:"
    echo "    $0 anti_spam pubsub_subscription muc_notifications"
    echo "    $0 mod_anti_spam mod_pubsub_subscription mod_muc_notifications"
    exit 1
}

if [[ $# -eq 0 ]]; then
    usage
fi

mkdir -p "$DEST"

install_via_rocks() {
    local modname="$1"
    echo "Installing $modname via prosodyctl rocks ..."
    prosodyctl install --server="$ROCKS_SERVER" "mod_$modname" || {
        echo "[ERROR] Failed to install mod_$modname via rocks" >&2
        exit 3
    }
}

is_in_array() {
    local needle="$1"
    shift
    local item
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

normalize_modname() {
    # Accept names with or without leading mod_
    local raw="$1"
    echo "${raw#mod_}"
}

for mod in "$@"; do
    # Normalize provided names to strip any leading mod_
    mod_normalized="$(normalize_modname "$mod")"
    install_via_rocks "$mod_normalized"
done

echo "All requested modules installed."
