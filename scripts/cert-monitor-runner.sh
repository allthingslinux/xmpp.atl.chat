#!/bin/bash
# Simple wrapper script for certificate monitoring
# This script is called by the docker-compose cert-monitor service

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Starting certificate monitoring..."

# Run the certificate monitoring script
exec "$SCRIPT_DIR/certificate-monitor.sh" monitor
