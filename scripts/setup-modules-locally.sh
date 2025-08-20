#!/bin/bash

# One-time script to download all Prosody community modules locally
# Follows the official Prosody documentation approach
# Usage: ./setup-modules-locally.sh

set -e

PROSODY_MODULES_DIR="prosody-modules"
ENABLED_DIR="prosody-modules-enabled"

echo "📦 Setting up Prosody community modules (official approach)..."

# Clone the repository (do this once)
if [[ ! -d "$PROSODY_MODULES_DIR/.hg" ]]; then
    echo "⬇️  Cloning prosody-modules repository..."

    # Try to use bundle first (avoids rate limiting)
    if [[ -f "prosody-modules.zstd-v2" ]]; then
        echo "📦 Using local bundle to avoid rate limiting..."
        hg clone "prosody-modules.zstd-v2" "$PROSODY_MODULES_DIR"
        # Set up paths to use official repo for future updates
        cat > "$PROSODY_MODULES_DIR/.hg/hgrc" << 'EOF'
[paths]
default = https://hg.prosody.im/prosody-modules/
bundle = ../prosody-modules.zstd-v2
EOF
    else
        echo "🌐 Cloning directly from official repository..."
        hg clone https://hg.prosody.im/prosody-modules/ "$PROSODY_MODULES_DIR"
    fi
else
    echo "⬆️  Updating existing repository..."
    (cd "$PROSODY_MODULES_DIR" && (hg pull bundle 2> /dev/null && echo "📦 Updated from bundle" || (hg pull default && echo "🌐 Updated from official repo")) && hg update)
fi

# Create enabled directory
mkdir -p "$ENABLED_DIR"

# Default modules to enable
DEFAULT_MODULES=(
    "mod_cloud_notify"
    "mod_cloud_notify_extensions"
    "mod_muc_notifications"
    "mod_muc_offline_delivery"
    "mod_http_status"
    "mod_admin_web"
    "mod_compliance_latest"
    "mod_anti_spam"
    "mod_admin_blocklist"
    "mod_spam_reporting"
    "mod_csi_battery_saver"
    "mod_invites"
    "mod_vcard_muc"
    "mod_s2s_status"
    "mod_log_slow_events"
    "mod_pastebin"
    "mod_reload_modules"
    "mod_pubsub_subscription"
)

echo "🔗 Creating symlinks for default modules..."
for module in "${DEFAULT_MODULES[@]}"; do
    if [[ -d "$PROSODY_MODULES_DIR/$module" ]]; then
        ln -sf "../$PROSODY_MODULES_DIR/$module" "$ENABLED_DIR/$module"
        echo "✅ $module -> enabled"
    else
        echo "❌ $module not found in repository"
    fi
done

echo "🎉 Local module setup complete!"
echo "📁 Repository: $PROSODY_MODULES_DIR"
echo "📁 Enabled modules: $ENABLED_DIR"
echo
echo "To add more modules: ln -s ../prosody-modules/mod_new_module prosody-modules-enabled/mod_new_module"
echo "To remove modules: rm prosody-modules-enabled/mod_unwanted_module"
