#!/bin/bash
set -euo pipefail

SRC="/tmp/prosody-modules"
DEST="/usr/local/lib/prosody/community-modules"
ROCKS_SERVER="https://modules.prosody.im/rocks/"

# Prefer hg copy for all modules by default. Leave ROCKS_MODULES empty unless
# a module truly requires rocks layout. This avoids special handling.
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

copy_module() {
    local modname="$1"
    local srcdir="$SRC/mod_$modname"
    local dstdir="$DEST/mod_$modname"
    if [[ ! -d "$srcdir" ]]; then
        echo "[WARN] Module not found in source tree: $srcdir"
        return 2
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

    if is_in_array "$mod_normalized" "${ROCKS_MODULES[@]}"; then
        install_via_rocks "$mod_normalized"
        continue
    fi

    if ! copy_module "$mod_normalized"; then
        echo "[INFO] Falling back to rocks installation for $mod_normalized ..."
        install_via_rocks "$mod_normalized"
    fi
done

echo "All requested modules installed."
