#!/bin/bash
set -euo pipefail

SRC="/tmp/prosody-modules"
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
    if prosodyctl install --server="$ROCKS_SERVER" "mod_$modname"; then
        return 0
    fi
    return 1
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
    if install_via_rocks "$mod_normalized"; then
        continue
    fi

    # Fallback: fetch prosody-modules tarball and copy module
    echo "[INFO] prosodyctl could not install mod_$mod_normalized; attempting hg tarball fallback..."
    if [[ ! -d "$SRC" ]]; then
        mkdir -p "$SRC"
        tmp_tar="/tmp/prosody-modules.tar.gz"
        if curl -fsSL --retry 5 --retry-delay 5 -o "$tmp_tar" "https://hg.prosody.im/prosody-modules/archive/tip.tar.gz"; then
            tar -xzf "$tmp_tar" -C "$SRC" --strip-components=1
            rm -f "$tmp_tar"
        else
            echo "[ERROR] Failed to download prosody-modules tarball for fallback" >&2
            exit 3
        fi
    fi

    srcdir="$SRC/mod_$mod_normalized"
    if [[ -d "$srcdir" ]]; then
        echo "[INFO] Copying mod_$mod_normalized from prosody-modules source tree ..."
        rsync -a --exclude='lib/luarocks' "$srcdir" "$DEST/"
    else
        echo "[ERROR] Module mod_$mod_normalized not found in prosody-modules; cannot install." >&2
        exit 4
    fi
done

echo "All requested modules installed."
