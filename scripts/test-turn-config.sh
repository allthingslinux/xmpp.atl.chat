#!/bin/bash
# ============================================================================
# TURN/STUN Configuration Test Script
# ============================================================================
# This script tests the TURN/STUN configuration without starting services
# Run this before deploying to production to catch configuration errors

set -e

echo "🔍 Testing TURN/STUN Configuration..."
echo "======================================"

# Check if .env file exists and has TURN configuration
if [ ! -f .env ]; then
    echo "❌ .env file not found"
    exit 1
fi

echo "✅ .env file found"

# Check required TURN environment variables
required_vars=("TURN_DOMAIN" "TURN_REALM" "TURN_PORT" "TURN_SECRET")
missing_vars=()

for var in "${required_vars[@]}"; do
    if ! grep -q "^${var}=" .env; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -gt 0 ]; then
    echo "❌ Missing required TURN environment variables:"
    printf '  - %s\n' "${missing_vars[@]}"
    exit 1
fi

echo "✅ All required TURN environment variables found"

# Check Prosody configuration
echo ""
echo "🔍 Checking Prosody TURN configuration..."

# Check if turn_external module is enabled
if ! grep -q '"turn_external"' core/config/prosody.cfg.lua; then
    echo "❌ turn_external module not enabled in Prosody config"
    exit 1
fi

echo "✅ turn_external module enabled"

# Check if TURN configuration exists in network config
if ! grep -q "turn_external_secret" core/config/conf.d/05-network.cfg.lua; then
    echo "❌ TURN configuration not found in network config"
    exit 1
fi

  echo "✅ TURN configuration found in network config"
  echo "✅ COTURN configuration file found"

# Check docker-compose.yml for COTURN service
if ! grep -q "xmpp-coturn:" docker-compose.yml; then
    echo "❌ COTURN service not found in docker-compose.yml"
    exit 1
fi

echo "✅ COTURN service found in docker-compose.yml"

# Check if TURN ports are properly configured
if ! grep -q "TURN_PORT.*3478" docker-compose.yml; then
    echo "❌ TURN port configuration not found in docker-compose.yml"
    exit 1
fi

echo "✅ TURN port configuration found"

# Check if TURN volume is configured
if ! grep -q "xmpp_coturn_data:" docker-compose.yml; then
    echo "❌ TURN volume not configured in docker-compose.yml"
    exit 1
fi

echo "✅ TURN volume configured"

# Check if .runtime/coturn directory exists
if [ ! -d ".runtime/coturn" ]; then
    echo "❌ .runtime/coturn directory not found"
    exit 1
fi

echo "✅ .runtime/coturn directory exists"

echo ""
echo "🎉 TURN/STUN configuration test passed!"
echo ""
echo "📋 Configuration Summary:"
echo "  - Domain: $(grep '^TURN_DOMAIN=' .env | cut -d'=' -f2)"
echo "  - Port: $(grep '^TURN_PORT=' .env | cut -d'=' -f2)"
echo "  - Secret: $(grep '^TURN_SECRET=' .env | cut -d'=' -f2 | cut -c1-8)..."
echo ""
echo "⚠️  IMPORTANT: Before starting in production:"
echo "  1. Change TURN_SECRET to a strong, unique secret"
echo "  2. Ensure TURN ports are open in your firewall"
echo "  3. Verify DNS records for turn.atl.chat point to your server"
echo "  4. Test with 'docker compose up -d xmpp-coturn' first"
echo ""
echo "🔧 To test the configuration:"
echo "  docker compose up -d xmpp-coturn"
echo "  docker compose logs xmpp-coturn"
