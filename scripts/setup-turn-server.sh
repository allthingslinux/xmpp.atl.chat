#!/bin/bash
# ============================================================================
# COMPREHENSIVE TURN SERVER SETUP SCRIPT
# ============================================================================
# This script sets up the complete TURN/STUN server configuration for XMPP.atl.chat

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    print_error "This script must be run from the xmpp.atl.chat directory"
    exit 1
fi

print_status "Starting TURN server configuration setup..."

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_warning ".env file not found. Creating from template..."
    if [ -f "templates/env/env.example" ]; then
        cp templates/env/env.example .env
        print_success "Created .env file from template"
        print_warning "Please review and update the .env file with your actual values"
        print_warning "Especially check: TURN_SECRET, TURN_DOMAIN, and TURN_REALM"
        exit 1
    else
        print_error "No .env template found. Please create .env file manually."
        exit 1
    fi
fi

# Source environment variables
print_status "Loading environment variables..."
export $(grep -v '^#' .env | xargs)

# Set default values
TURN_SECRET=${TURN_SECRET:-"vEIheW+T+MiuulmzX69ck7UJ3ZxuhZLZiykq9XvBU98="}
TURN_DOMAIN=${TURN_DOMAIN:-"turn.atl.chat"}
TURN_REALM=${TURN_REALM:-"atl.chat"}
TURN_PORT=${TURN_PORT:-"3478"}
TURNS_PORT=${TURNS_PORT:-"5349"}

print_status "Configuration values:"
echo "  TURN Domain: $TURN_DOMAIN"
echo "  TURN Realm: $TURN_REALM"
echo "  TURN Port: $TURN_PORT"
echo "  TURNS Port: $TURNS_PORT"
echo "  TURN Secret: ${TURN_SECRET:0:10}..."

# Check if envsubst is available
if ! command -v envsubst &> /dev/null; then
    print_warning "envsubst not found. Installing gettext..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y gettext-base
    elif command -v yum &> /dev/null; then
        sudo yum install -y gettext
    elif command -v pacman &> /dev/null; then
        sudo pacman -S gettext
    else
        print_error "Could not install envsubst. Please install gettext-base package manually."
        exit 1
    fi
fi

# Create runtime directories
print_status "Creating runtime directories..."
mkdir -p .runtime/turn
mkdir -p .runtime/certs

# Generate TURN configuration
print_status "Generating TURN server configuration..."
envsubst < deployment/coturn/turnserver.conf > .runtime/turn/turnserver.conf

# Verify configuration
print_status "Verifying TURN configuration..."
if [ -f ".runtime/turn/turnserver.conf" ]; then
    print_success "TURN configuration generated successfully"

    # Check key configuration items
    echo "Configuration verification:"
    echo "  ✓ Secret configured: $(grep -c "static-auth-secret" .runtime/turn/turnserver.conf || echo "0")"
    echo "  ✓ Realm configured: $(grep -c "realm" .runtime/turn/turnserver.conf || echo "0")"
    echo "  ✓ Server name configured: $(grep -c "server-name" .runtime/turn/turnserver.conf || echo "0")"
    echo "  ✓ Ports configured: $(grep -c "listening-port" .runtime/turn/turnserver.conf || echo "0")"
else
    print_error "Failed to generate TURN configuration file"
    exit 1
fi

# Check if certificates exist
print_status "Checking SSL certificates..."
if [ -d ".runtime/certs/live" ]; then
    print_success "SSL certificates found in .runtime/certs/live"
else
    print_warning "SSL certificates not found in .runtime/certs/live"
    print_warning "TURN over TLS may not work without proper certificates"
fi

# Test Docker Compose configuration
print_status "Testing Docker Compose configuration..."
if docker compose config > /dev/null 2>&1; then
    print_success "Docker Compose configuration is valid"
else
    print_error "Docker Compose configuration has errors"
    docker compose config
    exit 1
fi

# Display next steps
print_success "TURN server configuration setup complete!"
echo ""
echo "Next steps:"
echo "1. Review the generated configuration: .runtime/turn/turnserver.conf"
echo "2. Ensure your .env file has the correct values"
echo "3. Start the services: docker compose up -d"
echo "4. Test TURN connectivity: docker exec xmpp-coturn turnutils_uclient -v -t -u username -w password $TURN_DOMAIN $TURN_PORT"
echo "5. Test Prosody TURN integration: docker exec xmpp-prosody prosodyctl check turn"
echo ""
echo "For testing with external STUN server:"
echo "  docker exec xmpp-prosody prosodyctl check turn -v --ping=stun.conversations.im"
