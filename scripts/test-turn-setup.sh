#!/bin/bash
# ============================================================================
# TURN SERVER TESTING SCRIPT
# ============================================================================
# This script tests the TURN server setup and Prosody integration

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

print_status "Testing TURN server setup..."

# Check if containers are running
if ! docker compose ps | grep -q "xmpp-coturn.*Up"; then
    print_error "TURN server container is not running"
    print_status "Starting services..."
    docker compose up -d
    sleep 10
fi

# Test 1: Check TURN server connectivity
print_status "Test 1: Testing TURN server connectivity..."
if docker exec xmpp-coturn netstat -tuln | grep -q ":3478"; then
    print_success "TURN server is listening on port 3478"
else
    print_error "TURN server is not listening on port 3478"
fi

# Test 2: Check TURN server configuration
print_status "Test 2: Checking TURN server configuration..."
if docker exec xmpp-coturn cat /etc/turnserver.conf | grep -q "static-auth-secret"; then
    print_success "TURN server has authentication secret configured"
else
    print_error "TURN server missing authentication secret"
fi

# Test 3: Check Prosody TURN integration
print_status "Test 3: Testing Prosody TURN integration..."
if docker exec xmpp-prosody prosodyctl check turn 2>/dev/null; then
    print_success "Prosody TURN integration is working"
else
    print_warning "Prosody TURN integration test failed or not available"
fi

# Test 4: Test with external STUN server
print_status "Test 4: Testing TURN relay with external STUN server..."
if docker exec xmpp-prosody prosodyctl check turn -v --ping=stun.conversations.im 2>/dev/null; then
    print_success "TURN relay test passed"
else
    print_warning "TURN relay test failed (this is normal if external connectivity is restricted)"
fi

# Test 5: Check TURN credentials generation
print_status "Test 5: Checking TURN credentials generation..."
if docker exec xmpp-prosody prosodyctl mod_turn_external 2>/dev/null | grep -q "turn_external"; then
    print_success "TURN external module is loaded in Prosody"
else
    print_error "TURN external module is not loaded in Prosody"
fi

# Display configuration summary
print_status "Configuration Summary:"
echo "  TURN Domain: ${TURN_DOMAIN:-turn.atl.chat}"
echo "  TURN Port: ${TURN_PORT:-3478}"
echo "  TURNS Port: ${TURNS_PORT:-5349}"
echo "  TURN Secret: ${TURN_SECRET:0:10}..."

print_status "Testing complete!"
echo ""
echo "Next steps:"
echo "1. Test audio/video calls with an XMPP client"
echo "2. Check TURN server logs: docker logs xmpp-coturn"
echo "3. Check Prosody logs: docker logs xmpp-prosody"
echo "4. Verify DNS records for turn.atl.chat"
