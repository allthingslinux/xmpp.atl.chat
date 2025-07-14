#!/bin/bash
set -euo pipefail

# Professional Prosody XMPP Server - Development Environment Setup
# Automates setup for localhost testing and development

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
readonly PROJECT_DIR
readonly ENV_DEV_FILE="$PROJECT_DIR/.env.dev"
readonly DEV_COMPOSE_FILE="$PROJECT_DIR/docker-compose.dev.yml"
readonly DEV_TOOLS_DIR="$PROJECT_DIR/dev-tools"
readonly DEV_LOGS_DIR="$PROJECT_DIR/logs/dev"

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}${BOLD}[STEP]${NC} $1"
}

prompt_user() {
    local prompt="$1"
    local default="${2:-}"
    local response

    if [[ -n "$default" ]]; then
        read -r -p "$prompt [$default]: " response
        echo "${response:-$default}"
    else
        read -r -p "$prompt: " response
        echo "$response"
    fi
}

check_dependencies() {
    log_step "Checking development dependencies..."

    local missing_deps=()

    # Check for required tools
    if ! command -v docker >/dev/null 2>&1; then
        missing_deps+=("docker")
    fi

    if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
        missing_deps+=("docker-compose")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_error "Please install them and run this script again."
        exit 1
    fi

    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi

    log_info "All dependencies are available ✓"
}

# ============================================================================
# SETUP FUNCTIONS
# ============================================================================

setup_environment() {
    log_step "Setting up development environment configuration..."

    if [[ -f "$ENV_DEV_FILE" ]]; then
        log_warn "Development environment file already exists: $ENV_DEV_FILE"
        if ! prompt_user "Do you want to recreate it? (y/N)" "n" | grep -qi "^y"; then
            log_info "Keeping existing development environment file"
            return 0
        fi
    fi

    # Copy development environment template
    cp "$PROJECT_DIR/examples/env.dev.example" "$ENV_DEV_FILE"

    log_info "Development environment configuration created at $ENV_DEV_FILE ✓"
    log_info "You can customize the settings in $ENV_DEV_FILE if needed"
}

setup_directories() {
    log_step "Creating development directories..."

    # Create development-specific directories
    mkdir -p "$DEV_LOGS_DIR"
    mkdir -p "$DEV_TOOLS_DIR/webclient"
    mkdir -p "$PROJECT_DIR/static-files"

    # Set proper permissions
    chmod 755 "$DEV_LOGS_DIR"
    chmod 755 "$DEV_TOOLS_DIR"
    chmod 755 "$PROJECT_DIR/static-files"

    log_info "Development directories created ✓"
}

setup_dev_tools() {
    log_step "Setting up development tools..."

    # Create nginx configuration for web client
    cat >"$DEV_TOOLS_DIR/nginx-webclient.conf" <<'EOF'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # CORS for XMPP WebSocket connections
    location /xmpp-websocket {
        add_header Access-Control-Allow-Origin "*";
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
        add_header Access-Control-Allow-Headers "Content-Type, Authorization";
        
        if ($request_method = 'OPTIONS') {
            return 204;
        }
        
        proxy_pass http://xmpp-prosody-dev:5280;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static files
    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

    # Create simple web client for testing
    cat >"$DEV_TOOLS_DIR/webclient/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>XMPP Development Client</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #007bff;
        }
        .header h1 {
            color: #007bff;
            margin: 0;
        }
        .section {
            margin: 20px 0;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
            background: #fafafa;
        }
        .section h3 {
            margin-top: 0;
            color: #333;
        }
        .code {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 4px;
            padding: 10px;
            font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
            font-size: 14px;
            margin: 10px 0;
        }
        .link-list {
            list-style: none;
            padding: 0;
        }
        .link-list li {
            margin: 10px 0;
        }
        .link-list a {
            color: #007bff;
            text-decoration: none;
            padding: 8px 12px;
            border: 1px solid #007bff;
            border-radius: 4px;
            display: inline-block;
        }
        .link-list a:hover {
            background: #007bff;
            color: white;
        }
        .status {
            padding: 10px;
            border-radius: 4px;
            margin: 10px 0;
        }
        .status.success {
            background: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
        }
        .status.warning {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            color: #856404;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 XMPP Development Environment</h1>
            <p>Professional Prosody XMPP Server - Development Mode</p>
        </div>

        <div class="section">
            <h3>📱 Connection Information</h3>
            <div class="code">
                Server: localhost<br>
                Domain: localhost<br>
                Ports: 5222 (STARTTLS), 5223 (Direct TLS)<br>
                WebSocket: ws://localhost:5280/xmpp-websocket<br>
                BOSH: http://localhost:5280/http-bind
            </div>
            <div class="status warning">
                <strong>Note:</strong> Self-signed certificates are used in development. 
                Your XMPP client may show certificate warnings - this is expected.
            </div>
        </div>

        <div class="section">
            <h3>🔧 Development Tools</h3>
            <ul class="link-list">
                <li><a href="http://localhost:5280/admin" target="_blank">Admin Panel (HTTP)</a></li>
                <li><a href="https://localhost:5281/admin" target="_blank">Admin Panel (HTTPS)</a></li>
                <li><a href="http://localhost:8080" target="_blank">Database Admin (Adminer)</a></li>
                <li><a href="http://localhost:8082" target="_blank">Log Viewer (Dozzle)</a></li>
                <li><a href="http://localhost:5280/metrics" target="_blank">Metrics Endpoint</a></li>
            </ul>
        </div>

        <div class="section">
            <h3>👥 Create Test Users</h3>
            <p>Run these commands to create test users:</p>
            <div class="code">
                # Create admin user<br>
                docker compose -f docker-compose.dev.yml exec xmpp-prosody-dev prosodyctl adduser admin@localhost<br><br>
                
                # Create test users<br>
                docker compose -f docker-compose.dev.yml exec xmpp-prosody-dev prosodyctl adduser alice@localhost<br>
                docker compose -f docker-compose.dev.yml exec xmpp-prosody-dev prosodyctl adduser bob@localhost
            </div>
        </div>

        <div class="section">
            <h3>📱 Recommended XMPP Clients</h3>
            <ul>
                <li><strong>Android:</strong> Conversations (F-Droid/Play Store)</li>
                <li><strong>iOS:</strong> Monal (App Store)</li>
                <li><strong>Desktop:</strong> Gajim, Dino, Pidgin</li>
                <li><strong>Web:</strong> Converse.js (can be integrated here)</li>
            </ul>
        </div>

        <div class="section">
            <h3>🧪 Testing Features</h3>
            <ul>
                <li>✅ User registration enabled</li>
                <li>✅ File upload (up to 100MB)</li>
                <li>✅ Multi-user chat (MUC)</li>
                <li>✅ Message archiving (MAM)</li>
                <li>✅ Push notifications</li>
                <li>✅ WebSocket support</li>
                <li>✅ TURN/STUN for voice/video</li>
            </ul>
        </div>

        <div class="status success">
            <strong>Development Environment Ready!</strong> 
            Your XMPP server is running with all features enabled for testing.
        </div>
    </div>

    <script>
        // Simple connection status checker
        function checkServices() {
            const services = [
                { name: 'XMPP HTTP', url: 'http://localhost:5280/admin' },
                { name: 'Database Admin', url: 'http://localhost:8080' },
                { name: 'Log Viewer', url: 'http://localhost:8082' }
            ];
            
            // This would need CORS to work properly, but gives users the idea
            console.log('Development services should be available at:');
            services.forEach(service => {
                console.log(`- ${service.name}: ${service.url}`);
            });
        }
        
        // Check services when page loads
        document.addEventListener('DOMContentLoaded', checkServices);
    </script>
</body>
</html>
EOF

    log_info "Development tools configured ✓"
}

setup_static_files() {
    log_step "Setting up static file serving..."

    # Create a simple index page for static file serving
    cat >"$PROJECT_DIR/static-files/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>XMPP Server - Development</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 600px;
            margin: 50px auto;
            padding: 20px;
            text-align: center;
        }
        .logo { font-size: 4em; margin-bottom: 20px; }
        h1 { color: #007bff; }
        .info { background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="logo">💬</div>
    <h1>XMPP Development Server</h1>
    <p>Professional Prosody XMPP Server running in development mode</p>
    
    <div class="info">
        <h3>Connect with:</h3>
        <p><strong>Server:</strong> localhost</p>
        <p><strong>Domain:</strong> localhost</p>
        <p><strong>Ports:</strong> 5222 (STARTTLS), 5223 (Direct TLS)</p>
    </div>
    
    <p><a href="http://localhost:8081">→ Development Tools</a></p>
</body>
</html>
EOF

    log_info "Static files configured ✓"
}

cleanup_previous() {
    log_step "Cleaning up previous development environment..."

    # Stop and remove previous development containers
    if docker compose -f "$DEV_COMPOSE_FILE" ps -q >/dev/null 2>&1; then
        log_info "Stopping existing development containers..."
        docker compose -f "$DEV_COMPOSE_FILE" down
    fi

    # Optionally remove development volumes
    if prompt_user "Do you want to remove development data volumes? (y/N)" "n" | grep -qi "^y"; then
        log_info "Removing development volumes..."
        docker volume rm -f xmpp_prosody_data_dev xmpp_prosody_uploads_dev xmpp_postgres_data_dev xmpp_coturn_data_dev xmpp_certs_dev 2>/dev/null || true
        log_info "Development volumes removed ✓"
    else
        log_info "Keeping existing development volumes"
    fi
}

start_development_environment() {
    log_step "Starting development environment..."

    cd "$PROJECT_DIR"

    # Build the development image
    log_info "Building development Docker image..."
    docker compose -f "$DEV_COMPOSE_FILE" build

    # Start core services first
    log_info "Starting core services (Prosody + PostgreSQL)..."
    docker compose -f "$DEV_COMPOSE_FILE" up -d xmpp-prosody-dev xmpp-postgres-dev

    # Wait for services to be healthy
    log_info "Waiting for services to be ready..."
    sleep 10

    # Start additional services
    log_info "Starting development tools..."
    docker compose -f "$DEV_COMPOSE_FILE" up -d

    log_info "Development environment started ✓"
}

create_test_users() {
    log_step "Creating test users..."

    cd "$PROJECT_DIR"

    # Wait for Prosody to be fully ready
    log_info "Waiting for Prosody to be ready..."
    sleep 5

    # Create admin user
    log_info "Creating admin user..."
    if docker compose -f "$DEV_COMPOSE_FILE" exec -T xmpp-prosody-dev prosodyctl adduser admin@localhost <<<"admin123"; then
        log_info "Admin user created: admin@localhost (password: admin123) ✓"
    else
        log_warn "Failed to create admin user (may already exist)"
    fi

    # Create test users
    log_info "Creating test users..."
    if docker compose -f "$DEV_COMPOSE_FILE" exec -T xmpp-prosody-dev prosodyctl adduser alice@localhost <<<"alice123"; then
        log_info "Test user created: alice@localhost (password: alice123) ✓"
    else
        log_warn "Failed to create alice user (may already exist)"
    fi

    if docker compose -f "$DEV_COMPOSE_FILE" exec -T xmpp-prosody-dev prosodyctl adduser bob@localhost <<<"bob123"; then
        log_info "Test user created: bob@localhost (password: bob123) ✓"
    else
        log_warn "Failed to create bob user (may already exist)"
    fi
}

show_development_info() {
    log_step "Development environment ready!"

    echo
    echo -e "${GREEN}${BOLD}🚀 Your XMPP development environment is running!${NC}"
    echo
    echo -e "${BLUE}Access URLs:${NC}"
    echo "  • Development Tools:    http://localhost:8081"
    echo "  • Admin Panel (HTTP):   http://localhost:5280/admin"
    echo "  • Admin Panel (HTTPS):  https://localhost:5281/admin"
    echo "  • Database Admin:       http://localhost:8080"
    echo "  • Log Viewer:          http://localhost:8082"
    echo "  • Metrics:             http://localhost:5280/metrics"
    echo "  • Static Files:        http://localhost:5280/files/"
    echo
    echo -e "${BLUE}Test Users:${NC}"
    echo "  • admin@localhost  (password: admin123)"
    echo "  • alice@localhost  (password: alice123)"
    echo "  • bob@localhost    (password: bob123)"
    echo
    echo -e "${BLUE}XMPP Connection:${NC}"
    echo "  • Server: localhost"
    echo "  • Ports: 5222 (STARTTLS), 5223 (Direct TLS)"
    echo "  • WebSocket: ws://localhost:5280/xmpp-websocket"
    echo "  • BOSH: http://localhost:5280/http-bind"
    echo
    echo -e "${BLUE}Management Commands:${NC}"
    echo "  • View logs:           docker compose -f docker-compose.dev.yml logs -f"
    echo "  • Stop environment:    docker compose -f docker-compose.dev.yml down"
    echo "  • Add user:           docker compose -f docker-compose.dev.yml exec xmpp-prosody-dev prosodyctl adduser user@localhost"
    echo "  • Check status:       docker compose -f docker-compose.dev.yml exec xmpp-prosody-dev prosodyctl status"
    echo
    echo -e "${GREEN}Happy testing! 🎉${NC}"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    echo -e "${BLUE}${BOLD}Professional Prosody XMPP Server - Development Setup${NC}"
    echo "Setting up localhost testing environment..."
    echo

    check_dependencies
    setup_environment
    setup_directories
    setup_dev_tools
    setup_static_files
    cleanup_previous
    start_development_environment
    create_test_users
    show_development_info
}

# Handle script interruption
trap 'echo -e "\n${RED}Setup interrupted${NC}"; exit 1' INT TERM

# Run main function
main "$@"
