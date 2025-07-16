#!/bin/bash
set -euo pipefail

SRC="/tmp/prosody-modules"
DEST="/usr/local/lib/prosody/community-modules"

usage() {
    echo "Usage: $0 module1 [module2 ...]"
    echo "  Example: $0 anti_spam pubsub_subscription muc_notifications"
    exit 1
}

if [[ $# -eq 0 ]]; then
    usage
fi

mkdir -p "$DEST"

copy_module() {
    local modname="$1"
    local srcdir="$SRC/mod_$modname"
    local dstdir="$DEST/mod_$modname"
    if [[ ! -d "$srcdir" ]]; then
        echo "[ERROR] Module not found: $srcdir" >&2
        exit 2
    fi
    echo "Copying $modname ..."
    rsync -a --exclude='lib/luarocks' "$srcdir" "$DEST/"
    # Handle dependencies if depends.txt exists
    if [[ -f "$srcdir/depends.txt" ]]; then
        while read -r dep; do
            dep="${dep#mod_}"
            if [[ -n "$dep" && ! -d "$DEST/mod_$dep" ]]; then
                echo "  Copying dependency: $dep"
                copy_module "$dep"
            fi
        done < "$srcdir/depends.txt"
    fi
}

for mod in "$@"; do
    copy_module "$mod"
done

echo "All requested modules installed."
