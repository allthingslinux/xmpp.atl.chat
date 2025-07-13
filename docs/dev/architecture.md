# 🏗️ Architecture Overview

This document provides a technical overview of the Professional Prosody XMPP Server architecture for developers and contributors.

## 🌟 Design Philosophy

### Single Configuration Approach

This project follows a **single, opinionated configuration** philosophy:

1. **Simplicity Over Complexity** - One comprehensive configuration file instead of complex layered systems
2. **Production-Ready Defaults** - All settings optimized for production use out of the box
3. **Docker-First Design** - Containerized deployment with Docker Compose orchestration
4. **Security by Default** - Enterprise-grade security features enabled from the start
5. **Modern XMPP Standards** - Full support for latest XEPs and Prosody 13.0+ features

### Why Single Configuration?

**Traditional approach:**

- Complex multi-file configurations
- Unclear dependencies between settings
- Difficult to troubleshoot and maintain
- Overwhelming for new users

**Our approach:**

- Single `prosody.cfg.lua` with comprehensive settings
- Clear, documented configuration sections
- Easy to understand and modify
- Production-ready without customization

## 🏗️ System Architecture

### Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                     Docker Compose Stack                    │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                         Load Balancer                       │
│                        (nginx/traefik)                      │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                    Prosody XMPP Server                      │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Core XMPP Engine                        │   │
│  │  • C2S (Client-to-Server) - Port 5222/5223           │   │
│  │  • S2S (Server-to-Server) - Port 5269/5270           │   │
│  │  • HTTP Services - Port 5280/5281                    │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Modern XMPP Features                    │   │
│  │  • Message Archive Management (MAM)                  │   │
│  │  • Message Carbons & Stream Management               │   │
│  │  • Push Notifications & CSI                          │   │
│  │  • HTTP File Upload & WebSocket                      │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Security Layer                          │   │
│  │  • TLS 1.3 with Perfect Forward Secrecy              │   │
│  │  • SCRAM-SHA-256 Authentication                      │   │
│  │  • Anti-spam & Rate Limiting                         │   │
│  │  • Firewall & DNS Blocklists                         │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                     PostgreSQL Database                     │
│  • User accounts & rosters                                  │
│  • Message archives & history                               │
│  • MUC rooms & configurations                               │
│  • PubSub nodes & subscriptions                             │
└─────────────────────────────────────────────────────────────┘
                                │
                   ┌────────────┼────────────┐
                   ▼            ▼            
┌──────────────────────┐ ┌─────────────┐ 
│    Coturn Server     │ │ Prometheus  │ 
│  TURN/STUN for A/V   │ │  Metrics    │ 
│  Ports 3478/5349     │ │ Port 9090   │ 
└──────────────────────┘ └─────────────┘
```

## 📁 Project Structure

### Directory Layout

```text
xmpp.atl.chat/
├── README.md                     # Main project documentation
├── docker/
│   ├── Dockerfile                # Multi-stage container build
│   └── docker-compose.yml        # Service orchestration
├── config/
│   ├── prosody.cfg.lua           # Single comprehensive configuration (685 lines)
│   └── README.md                 # Configuration documentation
├── scripts/
│   ├── entrypoint.sh             # Container initialization
│   ├── health-check.sh           # Service health monitoring
│   ├── prosodyctl-manager.sh     # Enhanced server management
│   ├── backup.sh                 # Database backup automation
│   ├── deploy.sh                 # Deployment automation
│   └── *.sh                      # Various utility scripts
├── docs/
│   ├── user/                     # End-user guides
│   ├── admin/                    # Administrator documentation
│   ├── dev/                      # Developer documentation
│   └── reference/                # Technical specifications
├── examples/
│   ├── env.example               # Environment configuration template
│   ├── nginx-websocket.conf      # Reverse proxy examples
│   └── apache-websocket.conf     # Alternative proxy config
└── research/                     # Development research and notes
```

### Configuration Architecture

Unlike complex multi-layered systems, this project uses a **single configuration file** approach:

```text
config/prosody.cfg.lua (685 lines)
├── Core Server Settings (lines 1-50)
│   ├── Process management & identity
│   ├── Network interfaces & ports
│   └── Administrator accounts
├── Module Configuration (lines 51-200)
│   ├── Core Prosody modules
│   ├── Community modules
│   └── Security modules
├── Virtual Host Setup (lines 201-300)
│   ├── Domain configuration
│   ├── SSL/TLS settings
│   └── Service discovery
├── Component Services (lines 301-500)
│   ├── Multi-User Chat (MUC)
│   ├── Publish-Subscribe (PubSub)
│   ├── HTTP file upload
│   └── External service discovery
├── Database Configuration (lines 501-550)
│   ├── PostgreSQL settings
│   ├── Archive management
│   └── Storage optimization
├── Security Configuration (lines 551-650)
│   ├── TLS/SSL settings
│   ├── Authentication methods
│   ├── Rate limiting & anti-spam
│   └── Firewall rules
└── Advanced Features (lines 651-685)
    ├── Push notifications
    ├── WebSocket configuration
    └── Monitoring integration
```

## 🔧 Core Components

### 1. Prosody XMPP Server

**Primary Container**: `prosody`

- **Base Image**: `prosody/prosody:0.12` (with Prosody 13.0+ features)
- **Configuration**: Single comprehensive config file
- **Modules**: 50+ enabled modules for maximum compatibility
- **Ports**: 5222 (C2S), 5269 (S2S), 5280/5281 (HTTP/HTTPS)

### 2. PostgreSQL Database

**Primary Container**: `db`

- **Base Image**: `postgres:15-alpine`
- **Purpose**: Persistent storage for all XMPP data
- **Optimization**: Production-tuned PostgreSQL settings
- **Backup**: Automated backup scripts included

### 3. Coturn TURN/STUN Server

**Optional Container**: `coturn`

- **Base Image**: `coturn/coturn:latest`
- **Purpose**: Voice/video call relay for NAT traversal
- **Integration**: Automatic discovery via XEP-0215
- **Ports**: 3478 (TURN), 5349 (TURNS), 49152-65535 (RTP relay)

### 4. Monitoring Integration

**External Monitoring**: Designed for centralized monitoring

- **Purpose**: Prosody metrics export for external Prometheus
- **Integration**: Native Prosody metrics endpoint at `/metrics`
- **Configuration**: See `examples/prometheus-scrape-config.yml`

## 🌐 Service Communication

### Internal Network

All services communicate via Docker's internal network:

```yaml
networks:
  prosody_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### Service Dependencies

```text
prosody → depends_on → db (PostgreSQL)
prosody → discovers → coturn (via XEP-0215)
external-prometheus → scrapes → prosody:5280/metrics
external-prometheus → scrapes → system-node-exporter:9100/metrics
```

### Port Mapping

| Service | Internal Port | External Port | Purpose |
|---------|---------------|---------------|---------|
| prosody | 5222 | 5222 | Client connections (STARTTLS) |
| prosody | 5223 | 5223 | Client connections (Direct TLS) |
| prosody | 5269 | 5269 | Server-to-server |
| prosody | 5280 | 5280 | HTTP services |
| prosody | 5281 | 5281 | HTTPS services |
| coturn | 3478 | 3478 | STUN/TURN |
| coturn | 5349 | 5349 | TURN over TLS |

| ~~prometheus~~ | ~~9090~~ | ~~9090~~ | ~~External monitoring~~ |

## 🔒 Security Architecture

### Transport Security

- **TLS 1.3 preferred** with TLS 1.2 fallback
- **Perfect Forward Secrecy** using ECDHE key exchange
- **Modern cipher suites** (ChaCha20-Poly1305, AES-GCM)
- **Certificate validation** with DANE/TLSA support
- **HSTS headers** for web interfaces

### Authentication & Authorization

- **SCRAM-SHA-256** secure authentication (XEP-0474)
- **Multi-factor authentication** support
- **SASL 2.0** with channel binding
- **Role-based access control** with admin privileges
- **Enterprise backends** (LDAP, OAuth) ready

### Network Security

- **Firewall integration** with mod_firewall
- **Rate limiting** per IP, user, and stanza type
- **DNS blocklists** (Spamhaus, SURBL)
- **JID reputation scoring** for abuse prevention
- **Intrusion detection** with real-time alerts

## 📊 Data Flow

### Message Processing

```text
Client → TLS Connection → SASL Auth → Resource Binding → Message Routing
                                                              ↓
Archive Storage ← Database ← Message Carbons ← Stream Management
```

### File Upload Flow

```text
Client → HTTP Upload Request → Prosody HTTP Module → File Storage → Database Record
                                      ↓
               Temporary URL ← Prosody ← File Validation ← Virus Scan (optional)
```

### Federation (S2S) Flow

```text
Local Server → DNS SRV Lookup → Remote Server Connection → TLS Verification → SASL External → Message Exchange
```

## 🛠️ Development & Deployment

### Container Build Process

**Multi-stage Dockerfile**:

1. **Base stage**: Install dependencies and Prosody
2. **Community modules**: Clone and install community modules
3. **Production stage**: Copy configuration and set up runtime
4. **Health checks**: Implement comprehensive health monitoring

### Configuration Management

**Environment-driven configuration**:

- All settings controlled via `.env` file
- Docker Compose variable substitution
- Runtime configuration validation
- Hot-reload capability for most settings

### Monitoring & Observability

- **Metrics export** - Native Prosody metrics endpoint for external monitoring
- **External monitoring** - Designed for centralized Prometheus/Grafana
- **Health checks** - Comprehensive service health monitoring
- **Log aggregation** - Structured logging with JSON format
- **Alert manager** - Real-time notification system

## 🔄 Development Workflow

### Local Development

```bash
# Clone repository
git clone https://github.com/allthingslinux/xmpp.atl.chat
cd xmpp.atl.chat

# Set up development environment
cp examples/env.example .env
# Edit .env with development settings

# Start development stack
docker compose up -d prosody db

# Access logs
docker compose logs -f prosody
```

### Testing

```bash
# Configuration validation
docker compose exec prosody prosodyctl check config

# Connectivity testing
docker compose exec prosody prosodyctl check connectivity

# Module testing
docker compose exec prosody prosodyctl check modules
```

### Deployment

```bash
# Production deployment
./scripts/deploy.sh

# Or manual deployment
docker compose -f docker-compose.yml up -d
```

## 📈 Scalability Considerations

### Horizontal Scaling

- **Multiple Prosody instances** behind load balancer
- **Shared database** for session persistence
- **Redis clustering** for real-time features
- **Geographic distribution** with DNS-based routing

### Vertical Scaling

- **Resource limits** configured in Docker Compose
- **Database optimization** with connection pooling
- **Memory management** with Lua garbage collection tuning
- **CPU optimization** with multi-threading support

### Performance Monitoring

- **Real-time metrics** via Prometheus
- **Resource usage tracking** with cAdvisor
- **Database performance** monitoring
- **Network latency** measurement

## 🤝 Contributing

### Architecture Changes

When proposing architecture changes:

1. **Maintain simplicity** - Avoid adding complexity without clear benefit
2. **Preserve security** - Ensure changes don't compromise security posture
3. **Document thoroughly** - Update architecture documentation
4. **Test extensively** - Verify changes work across deployment scenarios
5. **Consider backwards compatibility** - Minimize breaking changes

### Code Organization

- **Single configuration principle** - Keep configuration in one place
- **Clear separation** between configuration and implementation
- **Comprehensive documentation** for all features
- **Security-first approach** to all changes

---

**🎯 Key Takeaway**: This architecture prioritizes simplicity and security over flexibility, providing a production-ready XMPP server that works out of the box while remaining maintainable and scalable.
