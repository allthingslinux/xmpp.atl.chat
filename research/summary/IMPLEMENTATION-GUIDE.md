# Prosody XMPP Server Implementation Guide

## Executive Summary

This comprehensive implementation guide synthesizes insights from analyzing 42 XMPP/Prosody implementations to provide actionable recommendations for building modern, secure, and scalable XMPP servers. The guide covers architecture decisions, security patterns, deployment strategies, and operational best practices derived from the most successful implementations in the ecosystem.

## Implementation Decision Tree

### 1. Deployment Scale Assessment

**Personal Server (1-50 users)**
- **Memory**: 64-128MB
- **CPU**: 1-2 cores
- **Storage**: SQLite
- **Deployment**: Docker Compose
- **Features**: Basic + modern XMPP

**Community Server (50-500 users)**
- **Memory**: 256-512MB
- **CPU**: 2-4 cores
- **Storage**: PostgreSQL
- **Deployment**: Docker + monitoring
- **Features**: Full feature set + anti-spam

**Enterprise Server (500+ users)**
- **Memory**: 512MB-2GB
- **CPU**: 4-8 cores
- **Storage**: PostgreSQL cluster
- **Deployment**: Kubernetes
- **Features**: All features + compliance

### 2. Architecture Selection Matrix

| Requirement           | Personal | Community   | Enterprise         |
| --------------------- | -------- | ----------- | ------------------ |
| **Base Image**        | Alpine   | Debian      | Debian             |
| **Module Management** | Static   | Environment | Dynamic            |
| **Database**          | SQLite   | PostgreSQL  | PostgreSQL Cluster |
| **Caching**           | None     | Redis       | Redis Cluster      |
| **Monitoring**        | Basic    | Prometheus  | Full APM           |
| **Security**          | Standard | Enhanced    | Comprehensive      |
| **Backup**            | Manual   | Automated   | Enterprise         |

## Reference Implementation Architecture

### 1. Security-First Foundation ⭐⭐⭐⭐⭐

**Based on**: SaraSmiseth/prosody, ichuan/prosody patterns

```lua
-- Security-first configuration template
-- /etc/prosody/prosody.cfg.lua

-- Global security settings
admins = { os.getenv("PROSODY_ADMINS") or "admin@domain.com" }

-- Enforce encryption
c2s_require_encryption = true
s2s_require_encryption = true
s2s_secure_auth = true
allow_unencrypted_plain_auth = false

-- Modern TLS configuration
ssl = {
    protocol = "tlsv1_2+";
    ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!SHA1:!AESCCM";
    curve = "secp384r1";
    options = { "no_sslv2", "no_sslv3", "no_tlsv1", "no_tlsv1_1" };
}

-- Anti-spam and security modules
security_modules = {
    "firewall", "limits", "blocklist", "spam_reporting",
    "watchregistrations", "block_registrations"
}

-- Modern XMPP features
modern_modules = {
    "carbons", "mam", "smacks", "csi_simple",
    "cloud_notify", "push", "bookmarks", "vcard4"
}

-- HTTP services
http_modules = {
    "bosh", "websocket", "http_upload", "http_file_share"
}

-- Administration and monitoring
admin_modules = {
    "admin_adhoc", "statistics", "prometheus"
}

-- Dynamic module loading
local function load_modules()
    local modules = {
        -- Core modules (always enabled)
        "roster", "saslauth", "tls", "dialback", "disco"
    }
    
    -- Add security modules
    for _, module in ipairs(security_modules) do
        table.insert(modules, module)
    end
    
    -- Conditionally add modern features
    if os.getenv("PROSODY_ENABLE_MODERN") ~= "false" then
        for _, module in ipairs(modern_modules) do
            table.insert(modules, module)
        end
    end
    
    -- Conditionally add HTTP services
    if os.getenv("PROSODY_ENABLE_HTTP") == "true" then
        for _, module in ipairs(http_modules) do
            table.insert(modules, module)
        end
    end
    
    -- Conditionally add admin modules
    if os.getenv("PROSODY_ENABLE_ADMIN") == "true" then
        for _, module in ipairs(admin_modules) do
            table.insert(modules, module)
        end
    end
    
    return modules
end

modules_enabled = load_modules()

-- Rate limiting configuration
limits = {
    c2s = { 
        rate = os.getenv("PROSODY_C2S_RATE") or "10kb/s"; 
        burst = os.getenv("PROSODY_C2S_BURST") or "25kb"; 
    };
    s2sin = { 
        rate = os.getenv("PROSODY_S2S_RATE") or "30kb/s"; 
        burst = os.getenv("PROSODY_S2S_BURST") or "100kb"; 
    };
}

-- Database configuration
default_storage = os.getenv("PROSODY_STORAGE") or "sql"
if default_storage == "sql" then
    sql = {
        driver = os.getenv("PROSODY_DB_DRIVER") or "PostgreSQL";
        database = os.getenv("PROSODY_DB_NAME") or "prosody";
        host = os.getenv("PROSODY_DB_HOST") or "localhost";
        port = tonumber(os.getenv("PROSODY_DB_PORT")) or 5432;
        username = os.getenv("PROSODY_DB_USER") or "prosody";
        password = os.getenv("PROSODY_DB_PASSWORD") or "prosody";
    }
end

-- Virtual host configuration
local domain = os.getenv("PROSODY_DOMAIN") or "domain.com"
VirtualHost (domain)
    enabled = true
    
    -- SSL configuration
    ssl = {
        key = "/etc/prosody/certs/" .. domain .. ".key";
        certificate = "/etc/prosody/certs/" .. domain .. ".crt";
    }
    
    -- Domain-specific settings
    allow_registration = os.getenv("PROSODY_ALLOW_REGISTRATION") == "true"
    
    -- File upload configuration
    if os.getenv("PROSODY_ENABLE_HTTP") == "true" then
        http_upload_file_size_limit = tonumber(os.getenv("PROSODY_UPLOAD_SIZE_LIMIT")) or 10485760 -- 10MB
        http_upload_expire_after = tonumber(os.getenv("PROSODY_UPLOAD_EXPIRE")) or 2592000 -- 30 days
    end

-- Multi-user chat component
local muc_domain = "conference." .. domain
Component (muc_domain) "muc"
    name = "Multi-user chat"
    modules_enabled = {
        "muc_mam", "muc_limits", "muc_log"
    }
    
    -- MUC-specific settings
    muc_log_expires_after = os.getenv("PROSODY_MUC_LOG_EXPIRE") or "1y"
    max_history_messages = tonumber(os.getenv("PROSODY_MUC_HISTORY")) or 50

-- HTTP upload component (if enabled)
if os.getenv("PROSODY_ENABLE_HTTP") == "true" then
    local upload_domain = "upload." .. domain
    Component (upload_domain) "http_upload"
        http_upload_file_size_limit = tonumber(os.getenv("PROSODY_UPLOAD_SIZE_LIMIT")) or 10485760
        http_upload_expire_after = tonumber(os.getenv("PROSODY_UPLOAD_EXPIRE")) or 2592000
end

-- Logging configuration
log = {
    { levels = { "error" }, to = "file", filename = "/var/log/prosody/error.log" };
    { levels = { "warn" }, to = "file", filename = "/var/log/prosody/prosody.log" };
    { levels = { "info" }, to = "file", filename = "/var/log/prosody/prosody.log" };
}

-- Include additional configuration files
Include "/etc/prosody/conf.d/*.cfg.lua"
```

### 2. Modern Docker Implementation ⭐⭐⭐⭐⭐

**Based on**: prose-im/prose-pod-server, tobi312/prosody patterns

```dockerfile
# Dockerfile
FROM debian:bookworm-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    lua5.4-dev \
    liblua5.4-dev \
    libssl-dev \
    libexpat1-dev \
    mercurial \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone and build community modules
RUN hg clone https://hg.prosody.im/prosody-modules/ /opt/prosody-modules

# Production stage
FROM debian:bookworm-slim AS runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    prosody \
    lua-dbi-postgresql \
    lua-dbi-sqlite3 \
    lua-sec \
    lua-bitop \
    lua-event \
    lua-zlib \
    lua-filesystem \
    lua-socket \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy community modules
COPY --from=builder /opt/prosody-modules /opt/prosody-modules

# Create prosody user and directories
RUN useradd -r -s /bin/false prosody || true && \
    mkdir -p /etc/prosody/conf.d /var/lib/prosody /var/log/prosody /etc/prosody/certs && \
    chown -R prosody:prosody /etc/prosody /var/lib/prosody /var/log/prosody

# Install community modules
RUN find /opt/prosody-modules -name "mod_*.lua" -exec ln -sf {} /usr/lib/prosody/modules/ \;

# Copy configuration and entrypoint
COPY prosody.cfg.lua /etc/prosody/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose ports
EXPOSE 5222 5269 5280 5281

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD prosodyctl status || exit 1

# Run as prosody user
USER prosody

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["prosody"]
```

```bash
#!/bin/bash
# entrypoint.sh

set -e

# Function to wait for database
wait_for_db() {
    if [ "$PROSODY_STORAGE" = "sql" ] && [ "$PROSODY_DB_DRIVER" = "PostgreSQL" ]; then
        echo "Waiting for PostgreSQL database..."
        while ! nc -z "$PROSODY_DB_HOST" "$PROSODY_DB_PORT"; do
            sleep 1
        done
        echo "PostgreSQL is ready"
    fi
}

# Function to initialize database
init_db() {
    if [ "$PROSODY_STORAGE" = "sql" ] && [ ! -f /var/lib/prosody/.db_initialized ]; then
        echo "Initializing database..."
        prosodyctl --config /etc/prosody/prosody.cfg.lua mod_storage_sql upgrade
        touch /var/lib/prosody/.db_initialized
    fi
}

# Function to create admin user
create_admin() {
    if [ -n "$PROSODY_ADMIN_PASSWORD" ] && [ -n "$PROSODY_ADMINS" ]; then
        echo "Creating admin user..."
        echo "$PROSODY_ADMIN_PASSWORD" | prosodyctl adduser "$PROSODY_ADMINS"
    fi
}

# Function to generate self-signed certificates if needed
generate_certs() {
    local domain="${PROSODY_DOMAIN:-domain.com}"
    local cert_dir="/etc/prosody/certs"
    
    if [ ! -f "$cert_dir/$domain.crt" ] && [ "$PROSODY_GENERATE_CERTS" = "true" ]; then
        echo "Generating self-signed certificates for $domain..."
        prosodyctl cert generate "$domain"
    fi
}

# Function to validate configuration
validate_config() {
    echo "Validating configuration..."
    prosodyctl check config
    if [ $? -ne 0 ]; then
        echo "Configuration validation failed"
        exit 1
    fi
}

# Main execution
main() {
    echo "Starting Prosody XMPP Server..."
    
    # Wait for dependencies
    wait_for_db
    
    # Initialize database
    init_db
    
    # Generate certificates if needed
    generate_certs
    
    # Create admin user
    create_admin
    
    # Validate configuration
    validate_config
    
    # Start Prosody
    exec "$@"
}

# Run main function
main "$@"
```

### 3. Production Docker Compose ⭐⭐⭐⭐⭐

**Based on**: Enterprise deployment patterns

```yaml
# docker-compose.yml
version: '3.8'

services:
  prosody:
    build: .
    container_name: prosody
    restart: unless-stopped
    ports:
      - "5222:5222"    # Client connections
      - "5269:5269"    # Server-to-server
      - "5280:5280"    # HTTP (BOSH/WebSocket)
    volumes:
      - prosody-config:/etc/prosody
      - prosody-data:/var/lib/prosody
      - prosody-logs:/var/log/prosody
      - prosody-certs:/etc/prosody/certs
    environment:
      # Domain configuration
      - PROSODY_DOMAIN=${PROSODY_DOMAIN:-domain.com}
      - PROSODY_ADMINS=${PROSODY_ADMINS:-admin@domain.com}
      
      # Database configuration
      - PROSODY_STORAGE=sql
      - PROSODY_DB_DRIVER=PostgreSQL
      - PROSODY_DB_HOST=postgres
      - PROSODY_DB_NAME=prosody
      - PROSODY_DB_USER=prosody
      - PROSODY_DB_PASSWORD_FILE=/run/secrets/db_password
      
      # Feature toggles
      - PROSODY_ENABLE_MODERN=true
      - PROSODY_ENABLE_HTTP=true
      - PROSODY_ENABLE_ADMIN=true
      
      # Security settings
      - PROSODY_ALLOW_REGISTRATION=false
      - PROSODY_C2S_RATE=10kb/s
      - PROSODY_C2S_BURST=25kb
      
      # File upload settings
      - PROSODY_UPLOAD_SIZE_LIMIT=10485760  # 10MB
      - PROSODY_UPLOAD_EXPIRE=2592000       # 30 days
      
      # Certificate settings
      - PROSODY_GENERATE_CERTS=false
    secrets:
      - db_password
      - admin_password
    depends_on:
      - postgres
      - redis
    networks:
      - prosody-network
    healthcheck:
      test: ["CMD", "prosodyctl", "status"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  postgres:
    image: postgres:15
    container_name: prosody-postgres
    restart: unless-stopped
    environment:
      - POSTGRES_DB=prosody
      - POSTGRES_USER=prosody
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    secrets:
      - db_password
    networks:
      - prosody-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U prosody"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: prosody-redis
    restart: unless-stopped
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis-data:/data
    networks:
      - prosody-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3

  nginx:
    image: nginx:alpine
    container_name: prosody-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - prosody-certs:/etc/nginx/certs
      - nginx-logs:/var/log/nginx
    depends_on:
      - prosody
    networks:
      - prosody-network

  prometheus:
    image: prom/prometheus:latest
    container_name: prosody-prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
    networks:
      - prosody-network

  grafana:
    image: grafana/grafana:latest
    container_name: prosody-grafana
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana-dashboards:/etc/grafana/provisioning/dashboards
    environment:
      - GF_SECURITY_ADMIN_PASSWORD_FILE=/run/secrets/grafana_password
    secrets:
      - grafana_password
    networks:
      - prosody-network

  backup:
    image: alpine:latest
    container_name: prosody-backup
    restart: unless-stopped
    volumes:
      - prosody-data:/data/prosody:ro
      - postgres-data:/data/postgres:ro
      - ./backups:/backups
      - ./backup-script.sh:/backup-script.sh
    command: |
      sh -c "
        chmod +x /backup-script.sh
        while true; do
          /backup-script.sh
          sleep 86400  # Daily backups
        done
      "
    depends_on:
      - prosody
      - postgres
    networks:
      - prosody-network

volumes:
  prosody-config:
  prosody-data:
  prosody-logs:
  prosody-certs:
  postgres-data:
  redis-data:
  nginx-logs:
  prometheus-data:
  grafana-data:

networks:
  prosody-network:
    driver: bridge

secrets:
  db_password:
    file: ./secrets/db_password.txt
  admin_password:
    file: ./secrets/admin_password.txt
  grafana_password:
    file: ./secrets/grafana_password.txt
```

### 4. Nginx Reverse Proxy Configuration ⭐⭐⭐⭐

```nginx
# nginx.conf
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;
    
    # Basic settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 10M;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=upload:10m rate=1r/s;
    
    # Upstream definitions
    upstream prosody_http {
        server prosody:5280;
        keepalive 32;
    }
    
    # HTTP to HTTPS redirect
    server {
        listen 80;
        server_name _;
        return 301 https://$host$request_uri;
    }
    
    # HTTPS server
    server {
        listen 443 ssl http2;
        server_name domain.com;
        
        # SSL configuration
        ssl_certificate /etc/nginx/certs/domain.com.crt;
        ssl_certificate_key /etc/nginx/certs/domain.com.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1d;
        ssl_session_tickets off;
        
        # HSTS
        add_header Strict-Transport-Security "max-age=63072000" always;
        
        # BOSH endpoint
        location /http-bind {
            proxy_pass http://prosody_http/http-bind;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_buffering off;
            tcp_nodelay on;
            
            # Rate limiting
            limit_req zone=api burst=20 nodelay;
        }
        
        # WebSocket endpoint
        location /xmpp-websocket {
            proxy_pass http://prosody_http/xmpp-websocket;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_read_timeout 86400;
            
            # Rate limiting
            limit_req zone=api burst=10 nodelay;
        }
        
        # File upload endpoint
        location /upload {
            proxy_pass http://prosody_http/upload;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            client_max_body_size 10M;
            
            # Rate limiting for uploads
            limit_req zone=upload burst=5 nodelay;
        }
        
        # Admin interface
        location /admin {
            proxy_pass http://prosody_http/admin;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Restrict access to admin interface
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            allow 172.16.0.0/12;
            allow 192.168.0.0/16;
            deny all;
        }
        
        # Health check endpoint
        location /health {
            proxy_pass http://prosody_http/health;
            access_log off;
        }
        
        # Well-known endpoints
        location /.well-known/host-meta {
            proxy_pass http://prosody_http/.well-known/host-meta;
            proxy_set_header Host $host;
        }
        
        location /.well-known/host-meta.json {
            proxy_pass http://prosody_http/.well-known/host-meta.json;
            proxy_set_header Host $host;
        }
    }
}

# Stream configuration for XMPP ports
stream {
    # Logging
    error_log /var/log/nginx/stream_error.log;
    
    # Rate limiting
    limit_conn_zone $binary_remote_addr zone=xmpp_conn:10m;
    
    # XMPP client connections
    server {
        listen 5222;
        proxy_pass prosody:5222;
        proxy_timeout 1s;
        proxy_responses 1;
        
        # Connection limiting
        limit_conn xmpp_conn 10;
    }
    
    # XMPP server-to-server connections
    server {
        listen 5269;
        proxy_pass prosody:5269;
        proxy_timeout 1s;
        proxy_responses 1;
        
        # Connection limiting
        limit_conn xmpp_conn 20;
    }
}
```

### 5. Monitoring Configuration ⭐⭐⭐⭐⭐

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "prosody_rules.yml"

scrape_configs:
  - job_name: 'prosody'
    static_configs:
      - targets: ['prosody:5280']
    metrics_path: '/metrics'
    scrape_interval: 30s
    
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']
    metrics_path: '/metrics'
    
  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']
    metrics_path: '/metrics'
    
  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx:80']
    metrics_path: '/metrics'
    
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [tcp_connect]
    static_configs:
      - targets:
        - prosody:5222
        - prosody:5269
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: blackbox-exporter:9115

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

### 6. Backup and Recovery Scripts ⭐⭐⭐⭐

```bash
#!/bin/bash
# backup-script.sh

set -e

BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

# Create backup directory
mkdir -p "$BACKUP_DIR/$DATE"

echo "Starting backup at $(date)"

# Backup Prosody configuration
echo "Backing up Prosody configuration..."
tar -czf "$BACKUP_DIR/$DATE/prosody-config.tar.gz" -C /data/prosody/config .

# Backup Prosody data
echo "Backing up Prosody data..."
tar -czf "$BACKUP_DIR/$DATE/prosody-data.tar.gz" -C /data/prosody .

# Backup PostgreSQL database
echo "Backing up PostgreSQL database..."
pg_dump -h postgres -U prosody prosody | gzip > "$BACKUP_DIR/$DATE/prosody-db.sql.gz"

# Create backup manifest
cat > "$BACKUP_DIR/$DATE/manifest.json" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "version": "1.0",
  "components": {
    "prosody-config": "prosody-config.tar.gz",
    "prosody-data": "prosody-data.tar.gz",
    "database": "prosody-db.sql.gz"
  },
  "retention_policy": {
    "days": $RETENTION_DAYS
  }
}
EOF

# Upload to S3 (if configured)
if [ -n "$AWS_S3_BUCKET" ]; then
    echo "Uploading backup to S3..."
    aws s3 sync "$BACKUP_DIR/$DATE/" "s3://$AWS_S3_BUCKET/prosody-backups/$DATE/"
fi

# Cleanup old backups
echo "Cleaning up old backups..."
find "$BACKUP_DIR" -type d -name "20*" -mtime +$RETENTION_DAYS -exec rm -rf {} \;

echo "Backup completed successfully at $(date)"
```

## Quick Start Deployment

### 1. Minimal Personal Server (5 minutes)

```bash
# Create project directory
mkdir prosody-server && cd prosody-server

# Create environment file
cat > .env << EOF
PROSODY_DOMAIN=your-domain.com
PROSODY_ADMINS=admin@your-domain.com
PROSODY_ADMIN_PASSWORD=secure-password
PROSODY_DB_PASSWORD=database-password
REDIS_PASSWORD=redis-password
EOF

# Create secrets directory
mkdir -p secrets
echo "database-password" > secrets/db_password.txt
echo "admin-password" > secrets/admin_password.txt
echo "grafana-password" > secrets/grafana_password.txt

# Download configuration files
curl -o docker-compose.yml https://raw.githubusercontent.com/example/prosody-config/main/docker-compose.yml
curl -o Dockerfile https://raw.githubusercontent.com/example/prosody-config/main/Dockerfile
curl -o prosody.cfg.lua https://raw.githubusercontent.com/example/prosody-config/main/prosody.cfg.lua

# Start services
docker-compose up -d

# Check status
docker-compose ps
docker-compose logs prosody
```

### 2. Production Deployment Checklist

**Pre-deployment**:
- [ ] Domain DNS configured (A, AAAA, SRV records)
- [ ] SSL certificates obtained (Let's Encrypt recommended)
- [ ] Firewall rules configured (ports 5222, 5269, 80, 443)
- [ ] Database server prepared (PostgreSQL recommended)
- [ ] Monitoring system ready (Prometheus + Grafana)
- [ ] Backup storage configured (S3 or equivalent)

**Security hardening**:
- [ ] Strong passwords for all accounts
- [ ] Rate limiting configured
- [ ] Anti-spam modules enabled
- [ ] Registration disabled or protected
- [ ] Admin interface restricted to trusted IPs
- [ ] SSL/TLS properly configured
- [ ] Security headers enabled

**Performance optimization**:
- [ ] Database connection pooling configured
- [ ] Caching enabled (Redis)
- [ ] Resource limits set appropriately
- [ ] Monitoring and alerting configured
- [ ] Log rotation configured
- [ ] Backup automation tested

**Post-deployment**:
- [ ] Admin user created and tested
- [ ] Client connections tested
- [ ] Federation tested (if applicable)
- [ ] File upload tested
- [ ] Monitoring dashboards configured
- [ ] Backup restoration tested
- [ ] Documentation updated

## Troubleshooting Guide

### Common Issues and Solutions

**1. Connection Issues**
```bash
# Check if Prosody is running
prosodyctl status

# Check port accessibility
telnet your-domain.com 5222
telnet your-domain.com 5269

# Check DNS configuration
dig SRV _xmpp-client._tcp.your-domain.com
dig SRV _xmpp-server._tcp.your-domain.com
```

**2. SSL Certificate Issues**
```bash
# Check certificate validity
prosodyctl check certs

# Generate new certificates
prosodyctl cert generate your-domain.com

# Check certificate expiration
openssl x509 -in /etc/prosody/certs/your-domain.com.crt -noout -dates
```

**3. Database Issues**
```bash
# Check database connection
prosodyctl check connectivity

# Upgrade database schema
prosodyctl mod_storage_sql upgrade

# Check database performance
prosodyctl check performance
```

**4. Performance Issues**
```bash
# Check resource usage
prosodyctl check resources

# Monitor connections
prosodyctl check connections

# Check module performance
prosodyctl check modules
```

## Maintenance Procedures

### Daily Tasks
- Monitor system health via Grafana dashboards
- Check error logs for unusual activity
- Verify backup completion
- Review security alerts

### Weekly Tasks
- Update system packages
- Review and rotate logs
- Check certificate expiration dates
- Analyze performance metrics

### Monthly Tasks
- Update Prosody and modules
- Review and update security configurations
- Test backup restoration procedures
- Audit user accounts and permissions

### Quarterly Tasks
- Security audit and penetration testing
- Capacity planning review
- Documentation updates
- Disaster recovery testing

## Conclusion

This implementation guide provides a comprehensive foundation for deploying modern, secure, and scalable Prosody XMPP servers. The configurations and patterns are derived from analyzing 42 real-world implementations and represent current best practices in the XMPP community.

Key takeaways:
1. **Security must be built-in from the start**, not added later
2. **Environment-driven configuration** enables flexible deployments
3. **Comprehensive monitoring** is essential for production systems
4. **Automated backups and recovery** procedures are critical
5. **Regular maintenance** ensures long-term stability and security

The reference implementation can be adapted for various deployment scenarios, from personal servers to enterprise-grade installations, while maintaining security and operational excellence. 