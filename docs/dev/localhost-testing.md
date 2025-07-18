# 🧪 Localhost Testing & Development Environment

Complete guide for setting up and using the Professional Prosody XMPP Server development environment for localhost testing, feature development, and debugging.

## 🚀 Quick Start

### 1. Prerequisites

- **Docker** 20.10+ and **Docker Compose** 2.0+
- **2GB RAM** minimum (4GB+ recommended)
- **Available ports**: 5222, 5223, 5269, 5270, 5280, 5281, 3478, 5349, 8080, 8081, 8082

### 2. One-Command Setup

```bash
# Clone and setup development environment
git clone https://github.com/allthingslinux/xmpp.atl.chat
cd xmpp.atl.chat
./prosody-manager setup --dev
```

**That's it!** The script will:

- Create development configuration files
- Set up development tools
- Start all services
- Create test users
- Show you all access URLs

### 3. Access Your Development Environment

After setup completes:

- **Development Dashboard**: <http://localhost:8081>
- **Admin Panel**: <http://localhost:5280/admin>
- **Database Admin**: <http://localhost:8080>
- **Log Viewer**: <http://localhost:8082>

## 🏗️ Architecture Overview

### Development vs Production

| Aspect | Development | Production |
|--------|-------------|------------|
| **Domain** | `localhost` | `atl.chat` |
| **Certificates** | Self-signed (auto-generated) | Let's Encrypt wildcard |
| **Registration** | Open (enabled) | Closed (disabled) |
| **Logging** | Debug level | Info level |
| **Security** | Relaxed for testing | Hardened |
| **Monitoring** | Local tools included | External Prometheus |
| **Data Persistence** | Named volumes | Production volumes |

### Services Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  Development Environment                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐    │
│  │   Prosody   │  │ PostgreSQL   │  │  TURN/STUN      │    │
│  │ XMPP Server │  │   Database   │  │  (Coturn)       │    │
│  │ :5222-5281  │  │    :5432     │  │ :3478,:5349     │    │
│  └─────────────┘  └──────────────┘  └─────────────────┘    │
│                                                             │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐    │
│  │   Adminer   │  │  Web Client  │  │  Log Viewer     │    │
│  │ DB Admin    │  │  Dashboard   │  │   (Dozzle)      │    │
│  │   :8080     │  │    :8081     │  │    :8082        │    │
│  └─────────────┘  └──────────────┘  └─────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Configuration

### Environment Configuration

Development configuration is stored in `.env.dev` (created from `examples/env.dev.example`):

```bash
# Key development settings
PROSODY_DOMAIN=localhost
PROSODY_ALLOW_REGISTRATION=true
PROSODY_LOG_LEVEL=debug
PROSODY_UPLOAD_SIZE_LIMIT=104857600  # 100MB

# Simple credentials
PROSODY_DB_PASSWORD=devpassword
TURN_PASSWORD=devpassword
```

### Service Configuration

Development services use the `docker-compose.dev.yml` file with:

- **Localhost-friendly settings** - No external dependencies
- **Self-signed certificates** - Automatically generated
- **Development tools** - Included for testing
- **Relaxed security** - Easier testing and debugging
- **Verbose logging** - Debug-level information

## 🛠️ Development Tools

### Built-in Management Tools

Use the development tools script for common tasks:

```bash
# Show environment status
./prosody-manager dev status

# Test all connectivity
./prosody-manager dev test

# Create test users
./prosody-manager dev adduser alice alice123
./prosody-manager dev adduser bob bob123

# View logs
./prosody-manager dev logs

# Show all access URLs
./prosody-manager dev urls
```

### Web-based Tools

| Tool | URL | Purpose |
|------|-----|---------|
| **Development Dashboard** | <http://localhost:8081> | Central hub with links and information |
| **Admin Panel** | <http://localhost:5280/admin> | XMPP server administration |
| **Database Admin** | <http://localhost:8080> | PostgreSQL database management |
| **Log Viewer** | <http://localhost:8082> | Real-time log viewing |
| **Metrics** | <http://localhost:5280/metrics> | Prometheus metrics endpoint |

### Command-line Tools

```bash
# Direct prosodyctl access
docker compose -f docker-compose.dev.yml exec xmpp-prosody-dev prosodyctl status

# Database access
docker compose -f docker-compose.dev.yml exec xmpp-postgres-dev psql -U prosody

# View logs
docker compose -f docker-compose.dev.yml logs -f xmpp-prosody-dev
```

## 🧪 Testing XMPP Features

### User Management

```bash
# Create users (automated in setup)
./prosody-manager dev adduser admin admin123
./prosody-manager dev adduser alice alice123
./prosody-manager dev adduser bob bob123

# List all users
./prosody-manager dev users

# Change passwords
./prosody-manager dev passwd alice

# Delete users
./prosody-manager dev deluser testuser
```

### Connection Testing

```bash
# Test all connectivity
./prosody-manager dev test

# Test Prosody configuration
./prosody-manager dev config

# Performance testing
./prosody-manager dev perf
```

### XMPP Client Testing

Connect with any XMPP client using:

```
Server: localhost
Domain: localhost
Port: 5222 (STARTTLS) or 5223 (Direct TLS)
Username: alice@localhost
Password: alice123
```

**Recommended clients:**

- **Android**: Conversations
- **iOS**: Monal
- **Desktop**: Gajim, Dino, Pidgin
- **Web**: Converse.js (can be integrated)

### Feature Testing

Test all major XMPP features:

#### Message Archive Management (MAM)

- Send messages between users
- Check archive retrieval in clients
- View in database: <http://localhost:8080>

#### File Upload (XEP-0363)

- Upload files via XMPP clients
- Access upload endpoint: <https://localhost:5281/upload>
- Files stored in development volumes

#### Multi-User Chat (MUC)

- Create chat rooms: `conference.localhost`
- Test room persistence and archiving
- Check room configuration

#### Push Notifications

- Configure push endpoints in clients
- Test offline message delivery
- Monitor push attempts in logs

#### WebSocket/BOSH

- Web clients via WebSocket: `ws://localhost:5280/xmpp-websocket`
- BOSH endpoint: `http://localhost:5280/http-bind`

#### Voice/Video (TURN/STUN)

- STUN server: `localhost:3478`
- TURN server: `localhost:3478` (user: prosody, pass: devpassword)
- Test with WebRTC-capable clients

## 🔧 Development Workflows

### Configuration Changes

1. **Edit configuration**:

   ```bash
   # Edit development environment
   nano .env.dev
   
   # Or edit Prosody config directly
   nano config/prosody.cfg.lua
   ```

2. **Apply changes**:

   ```bash
   # Restart specific service
   ./scripts/dev-tools.sh restart xmpp-prosody-dev
   
   # Or restart all services
   docker compose -f docker-compose.dev.yml restart
   ```

### Module Development

1. **Add custom modules**:

   ```bash
   # Place modules in project directory
   mkdir -p custom-modules
   
   # Mount in docker-compose.dev.yml
   volumes:
     - ./custom-modules:/usr/local/lib/prosody/custom:ro
   ```

2. **Test module loading**:

   ```bash
   # Check module status
   ./scripts/dev-tools.sh config
   
   # View module logs
   ./scripts/dev-tools.sh logs xmpp-prosody-dev
   ```

### Database Development

1. **Access database**:

   ```bash
   # Via Adminer web interface
   open http://localhost:8080
   
   # Via command line
   docker compose -f docker-compose.dev.yml exec xmpp-postgres-dev psql -U prosody
   ```

2. **Backup/restore data**:

   ```bash
   # Backup development data
   ./scripts/dev-tools.sh backup
   
   # Reset development data
   ./scripts/dev-tools.sh cleanup
   ./scripts/setup-dev.sh
   ```

### Log Analysis

1. **Real-time logs**:

   ```bash
   # All services
   ./scripts/dev-tools.sh logs
   
   # Specific service
   ./scripts/dev-tools.sh logs xmpp-prosody-dev
   
   # Web-based log viewer
   open http://localhost:8082
   ```

2. **Log filtering**:

   ```bash
   # Error logs only
   docker compose -f docker-compose.dev.yml logs | grep -i error
   
   # Authentication logs
   docker compose -f docker-compose.dev.yml logs | grep -i auth
   ```

## 🐛 Troubleshooting

### Common Issues

#### Services Won't Start

```bash
# Check service status
./scripts/dev-tools.sh status

# Check for port conflicts
netstat -tulpn | grep -E ':(5222|5280|8080|8081|8082)'

# View startup logs
docker compose -f docker-compose.dev.yml logs xmpp-prosody-dev
```

#### Certificate Warnings

This is expected in development! Self-signed certificates will show warnings in:

- XMPP clients (accept the certificate)
- Web browsers (proceed anyway)
- Command-line tools (use `-k` flag for curl)

#### Database Connection Issues

```bash
# Check database status
docker compose -f docker-compose.dev.yml exec xmpp-postgres-dev pg_isready

# Reset database
docker compose -f docker-compose.dev.yml down
docker volume rm xmpp_postgres_data_dev
docker compose -f docker-compose.dev.yml up -d xmpp-postgres-dev
```

#### XMPP Client Connection Issues

1. **Check connectivity**:

   ```bash
   ./scripts/dev-tools.sh test
   ```

2. **Verify user exists**:

   ```bash
   ./scripts/dev-tools.sh users
   ```

3. **Check server logs**:

   ```bash
   ./scripts/dev-tools.sh logs xmpp-prosody-dev | grep -i "auth\|login\|connect"
   ```

### Performance Issues

```bash
# Check resource usage
docker stats

# Run performance test
./scripts/dev-tools.sh perf

# Check for memory leaks
docker compose -f docker-compose.dev.yml exec xmpp-prosody-dev prosodyctl check memory
```

### Reset Development Environment

```bash
# Complete reset
./scripts/dev-tools.sh cleanup  # Choose to remove volumes
./scripts/setup-dev.sh          # Fresh setup
```

## 📊 Monitoring & Metrics

### Development Metrics

Access Prometheus metrics at: <http://localhost:5280/metrics>

Key metrics to monitor:

- `prosody_connections` - Active connections
- `prosody_memory_usage` - Memory consumption
- `prosody_cpu_usage` - CPU utilization
- `prosody_messages_total` - Message throughput

### Log Analysis

Use the web-based log viewer: <http://localhost:8082>

Filter logs by:

- Container name
- Log level
- Time range
- Search terms

### Database Monitoring

Via Adminer: <http://localhost:8080>

Monitor:

- Connection counts
- Table sizes
- Query performance
- Archive storage usage

## 🔄 Automation & CI/CD

### Automated Testing

```bash
# Create test script
cat > test-dev-environment.sh << 'EOF'
#!/bin/bash
set -e

# Setup development environment
./scripts/setup-dev.sh

# Wait for services
sleep 30

# Run tests
./scripts/dev-tools.sh test
./scripts/dev-tools.sh config

# Create test users
./scripts/dev-tools.sh adduser testuser1 testpass1
./scripts/dev-tools.sh adduser testuser2 testpass2

# Verify users exist
./scripts/dev-tools.sh users | grep testuser

echo "✅ Development environment tests passed!"
EOF

chmod +x test-dev-environment.sh
```

### Integration with IDEs

#### VS Code Configuration

```json
{
  "tasks": [
    {
      "label": "Start XMPP Dev Environment",
      "type": "shell",
      "command": "./scripts/setup-dev.sh",
      "group": "build"
    },
    {
      "label": "Stop XMPP Dev Environment", 
      "type": "shell",
      "command": "docker compose -f docker-compose.dev.yml down",
      "group": "build"
    },
    {
      "label": "View XMPP Logs",
      "type": "shell", 
      "command": "./scripts/dev-tools.sh logs",
      "group": "test"
    }
  ]
}
```

## 🎯 Best Practices

### Development Workflow

1. **Start fresh** - Use `./scripts/setup-dev.sh` for clean environment
2. **Test incrementally** - Use `./scripts/dev-tools.sh test` after changes
3. **Monitor logs** - Keep log viewer open during development
4. **Backup data** - Use `./scripts/dev-tools.sh backup` before major changes
5. **Reset when needed** - Don't hesitate to reset and start fresh

### Security Considerations

⚠️ **Development environment is NOT secure by design:**

- Open registration enabled
- Relaxed authentication
- Self-signed certificates
- Debug logging (may expose sensitive data)
- All IPs allowed for metrics

**Never expose development environment to the internet!**

### Performance Optimization

- Use `./scripts/dev-tools.sh perf` to identify bottlenecks
- Monitor resource usage with `docker stats`
- Limit development to essential services only
- Clean up unused volumes and containers regularly

## 🚀 Next Steps

### Moving to Production

1. **Review production configuration**: `examples/env.example`
2. **Set up proper domain and DNS**: See `docs/admin/dns-setup.md`
3. **Configure SSL certificates**: See `docs/admin/certificate-management.md`
4. **Harden security settings**: See `docs/admin/security.md`
5. **Set up monitoring**: See `docs/user/monitoring.md`

### Advanced Development

1. **Custom module development**: Create modules in `custom-modules/`
2. **Integration testing**: Automate client connection tests
3. **Load testing**: Use tools like `ejabberdctl` or custom scripts
4. **Monitoring integration**: Connect to external Prometheus/Grafana

---

**Happy developing! 🎉**

For questions or issues, check the troubleshooting section above or open an issue on GitHub.
