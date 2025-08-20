#!/bin/bash
# ============================================================================
# TURN SERVER CONFIGURATION SETUP SCRIPT
# ============================================================================
# This script substitutes environment variables in the TURN server configuration
# and ensures proper setup for the COTURN container

set -euo pipefail

# Source environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Default values
TURN_SECRET=${TURN_SECRET:-"vEIheW+T+MiuulmzX69ck7UJ3ZxuhZLZiykq9XvBU98="}
TURN_DOMAIN=${TURN_DOMAIN:-"xmpp.atl.chat"}
TURN_REALM=${TURN_REALM:-"atl.chat"}

echo "Setting up TURN server configuration..."
echo "TURN Domain: $TURN_DOMAIN"
echo "TURN Realm: $TURN_REALM"
echo "TURN Secret: ${TURN_SECRET:0:10}..."

# Create runtime TURN config directory
mkdir -p .runtime/turn

# Substitute environment variables in the TURN configuration
envsubst < deployment/coturn/turnserver.conf > .runtime/turn/turnserver.conf

echo "TURN configuration generated at .runtime/turn/turnserver.conf"
echo "Configuration setup complete!"

# Verify the configuration
if [ -f .runtime/turn/turnserver.conf ]; then
    echo "Configuration file verification:"
    echo "  - Secret configured: $(grep -c "static-auth-secret" .runtime/turn/turnserver.conf || echo "0")"
    echo "  - Domain configured: $(grep -c "realm" .runtime/turn/turnserver.conf || echo "0")"
    echo "  - Server name configured: $(grep -c "server-name" .runtime/turn/turnserver.conf || echo "0")"
else
    echo "ERROR: Failed to generate TURN configuration file"
    exit 1
fi
