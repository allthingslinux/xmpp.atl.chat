# 🧪 XMPP Development Environment

**One-command setup for localhost XMPP testing and development.**

## 🚀 Quick Start

```bash
# Clone and setup development environment
git clone https://github.com/allthingslinux/xmpp.atl.chat
cd xmpp.atl.chat
./scripts/setup-dev.sh
```

## 🎯 What You Get

- **Full XMPP Server** (Prosody) with all modern features
- **PostgreSQL Database** with web admin interface
- **TURN/STUN Server** for voice/video calls
- **Development Tools** - log viewer, metrics, admin panel
- **Test Users** automatically created
- **Self-signed certificates** for localhost testing

## 🌐 Access URLs

After setup completes:

| Service | URL | Purpose |
|---------|-----|---------|
| **Development Dashboard** | <http://localhost:8081> | Central hub with all links |
| **Admin Panel** | <http://localhost:5280/admin> | XMPP server management |
| **Database Admin** | <http://localhost:8080> | PostgreSQL web interface |
| **Log Viewer** | <http://localhost:8082> | Real-time log monitoring |
| **Metrics** | <http://localhost:5280/metrics> | Prometheus metrics |

## 📱 Connect XMPP Clients

Use any XMPP client with these settings:

```
Server: localhost
Domain: localhost
Port: 5222 (STARTTLS) or 5223 (Direct TLS)
```

**Test Users (created automatically):**

- `admin@localhost` (password: admin123)
- `alice@localhost` (password: alice123)
- `bob@localhost` (password: bob123)

## 🛠️ Development Tools

```bash
# Show environment status
./scripts/dev-tools.sh status

# Test all connectivity
./scripts/dev-tools.sh test

# Create more users
./scripts/dev-tools.sh adduser newuser password123

# View logs
./scripts/dev-tools.sh logs

# Show all URLs
./scripts/dev-tools.sh urls

# Get help
./scripts/dev-tools.sh help
```

## 🧪 Test Features

✅ **All XMPP features enabled:**

- Message Archive Management (MAM)
- File Upload (XEP-0363) - up to 100MB
- Multi-User Chat (MUC)
- Push Notifications
- WebSocket/BOSH support
- Voice/Video calling (TURN/STUN)
- Modern security (SCRAM-SHA-256)

## 🔧 Management

```bash
# Stop environment
docker compose -f docker-compose.dev.yml down

# View logs
docker compose -f docker-compose.dev.yml logs -f

# Restart services
./scripts/dev-tools.sh restart

# Complete cleanup (removes all data)
./scripts/dev-tools.sh cleanup
```

## 📚 Documentation

- **Complete Guide**: [docs/dev/localhost-testing.md](docs/dev/localhost-testing.md)
- **Production Setup**: [docs/user/getting-started.md](docs/user/getting-started.md)
- **Architecture**: [docs/dev/architecture.md](docs/dev/architecture.md)

## ⚠️ Security Notice

**This development environment is NOT secure:**

- Open registration enabled
- Debug logging active
- Self-signed certificates
- Relaxed security settings

**Never expose to the internet!** Use only for localhost testing.

## 🎯 Next Steps

1. **Connect XMPP clients** and test messaging
2. **Upload files** via clients or <https://localhost:5281/upload>
3. **Create chat rooms** at `conference.localhost`
4. **Monitor logs** at <http://localhost:8082>
5. **Check database** at <http://localhost:8080>

For production deployment, see the main [README.md](README.md) and [documentation](docs/).

---

**Happy testing! 🎉**
