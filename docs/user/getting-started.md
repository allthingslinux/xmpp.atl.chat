# 🚀 Getting Started

Deploy a professional Prosody XMPP server in 5 minutes using Docker Compose. This guide covers everything from initial setup to connecting your first client.

## ⚡ Quick Deploy

### 1. Prerequisites

- **Docker** 20.10+ and **Docker Compose** 2.0+
- **Domain name** with DNS control (e.g., `atl.chat`)
- **2GB RAM** minimum (4GB+ recommended)

### 2. Clone and Configure

```bash
# Clone the repository
git clone https://github.com/allthingslinux/xmpp.atl.chat
cd xmpp.atl.chat

# Copy and edit configuration
cp examples/env.example .env
nano .env  # Edit with your settings
```

### 3. Set Your Domain

Edit `.env` file with your domain:

```bash
# Required settings
PROSODY_DOMAIN=atl.chat
PROSODY_ADMINS=admin@atl.chat
PROSODY_DB_PASSWORD=ChangeMe123!
LETSENCRYPT_EMAIL=admin@allthingslinux.org
```

### 4. Deploy

```bash
# Start the server (minimal deployment)
docker compose up -d prosody db

# Check status
docker compose logs -f prosody
```

### 5. Create Users

```bash
# Create admin user
docker compose exec prosody prosodyctl adduser admin@atl.chat

# Create regular users
docker compose exec prosody prosodyctl adduser alice@atl.chat
docker compose exec prosody prosodyctl adduser bob@atl.chat
```

### 6. Connect

Your XMPP server is ready! Connect with any XMPP client using:

- **Server**: `atl.chat`
- **Port**: `5222` (STARTTLS) or `5223` (Direct TLS)
- **Username**: `alice@atl.chat`
- **Password**: (what you set when creating the user)

## 🌐 DNS Setup

### Required DNS Records

Add these DNS records for your domain:

```
# SRV records for client discovery
_xmpp-client._tcp.atl.chat.  3600  IN  SRV  5 0 5222 xmpp.atl.chat.
_xmpps-client._tcp.atl.chat. 3600  IN  SRV  5 0 5223 xmpp.atl.chat.

# SRV records for server-to-server
_xmpp-server._tcp.atl.chat.  3600  IN  SRV  5 0 5269 xmpp.atl.chat.
_xmpps-server._tcp.atl.chat. 3600  IN  SRV  5 0 5270 xmpp.atl.chat.

# A record pointing to your server
xmpp.atl.chat.               3600  IN  A    YOUR.SERVER.IP.ADDRESS
```

## 🔒 SSL Certificates

### Wildcard Certificate with Cloudflare DNS-01 (Recommended)

The easiest and most secure approach uses Cloudflare's DNS API to automatically generate wildcard certificates:

```bash
# 1. Configure Cloudflare API
cp cloudflare-credentials.ini.example cloudflare-credentials.ini
# Edit with your Cloudflare API token
# Get token from: https://dash.cloudflare.com/profile/api-tokens
# Permissions needed: Zone:Zone:Read, Zone:DNS:Edit

# 2. Generate wildcard certificate
docker compose --profile letsencrypt run --rm certbot

# 3. Start the server
docker compose up -d prosody db
```

**Benefits:**

- **Wildcard coverage**: `*.atl.chat` covers all subdomains automatically
- **No port 80 needed**: Uses DNS validation instead of HTTP
- **Automatic renewal**: Set up once and forget
- **More secure**: No need to expose HTTP port publicly

### Manual Certificate (Advanced)

If you have existing certificates:

```bash
# Copy your certificates to the certs directory
cp your-wildcard.crt ./certs/atl.chat.crt
cp your-wildcard.key ./certs/atl.chat.key

# Set proper permissions
chmod 644 ./certs/atl.chat.crt
chmod 600 ./certs/atl.chat.key

# Start the server
docker compose up -d prosody db
```

### Development Mode

For development, no certificate setup is needed:

```bash
# Start server - self-signed certificates generated automatically
docker compose up -d prosody db
```

## 📱 Connect XMPP Clients

### Popular XMPP Clients

| Platform | Client | Download |
|----------|--------|----------|
| **Android** | Conversations | [F-Droid](https://f-droid.org/packages/eu.siacs.conversations/) / [Play Store](https://play.google.com/store/apps/details?id=eu.siacs.conversations) |
| **iOS** | Monal | [App Store](https://apps.apple.com/app/monal/id317711500) |
| **Desktop** | Gajim | [gajim.org](https://gajim.org/) |
| **Desktop** | Pidgin | [pidgin.im](https://pidgin.im/) |
| **Web** | Converse.js | Built-in web client |

### Connection Settings

All clients use these settings:

```
Server: atl.chat
Port: 5222 (STARTTLS) or 5223 (Direct TLS)
Username: alice@atl.chat
Password: [your password]
```

## 🌐 Web Access

### Admin Panel

Access the web admin panel at:

- **URL**: `https://xmpp.atl.chat:5281/admin`
- **Username**: `admin@atl.chat`
- **Password**: [admin password]

### File Upload

Users can upload files at:

- **URL**: `https://xmpp.atl.chat:5281/upload`

### WebSocket (for web clients)

Web clients can connect via WebSocket:

- **URL**: `wss://xmpp.atl.chat:5281/xmpp-websocket`

## 🔧 Additional Services

### Add Voice/Video Support

```bash
# Deploy with TURN/STUN server for voice/video calls
docker compose up -d prosody db coturn
```

### External Monitoring

```bash
# This deployment is designed for external monitoring
# Prosody metrics available at: http://your-domain:5280/metrics
# See examples/prometheus-scrape-config.yml for Prometheus configuration
```

### Full Deployment

```bash
# Deploy everything
docker compose up -d
```

## ✅ Verify Your Setup

### Check Server Status

```bash
# Check if prosody is running
docker compose exec prosody prosodyctl status

# Test connectivity
docker compose exec prosody prosodyctl check connectivity atl.chat

# Check configuration
docker compose exec prosody prosodyctl check config
```

### Test External Connectivity

Visit [XMPP Compliance Tester](https://compliance.conversations.im/) and enter your domain to verify:

- DNS SRV records
- TLS certificate validity
- XEP compliance
- Security configuration

## 🔄 Basic Management

### User Management

```bash
# List users
docker compose exec prosody prosodyctl list users atl.chat

# Change password
docker compose exec prosody prosodyctl passwd alice@atl.chat

# Delete user
docker compose exec prosody prosodyctl deluser bob@atl.chat
```

### Server Management

```bash
# Restart prosody
docker compose restart prosody

# View logs
docker compose logs -f prosody

# Update prosody
docker compose pull && docker compose up -d
```

## 🛟 Troubleshooting

### Common Issues

**Can't connect to server:**

- Check DNS records are correct
- Verify firewall allows ports 5222, 5223, 5269
- Check certificates are valid

**Certificate errors:**

- Ensure certificate matches domain name
- Check certificate hasn't expired
- Verify proper file permissions

**Can't create users:**

- Ensure prosody container is running
- Check database connection
- Verify admin privileges

### Get Help

- **Logs**: `docker compose logs prosody`
- **Test connectivity**: `prosodyctl check connectivity atl.chat`
- **Configuration test**: `prosodyctl check config`
- **Issues**: [GitHub Issues](https://github.com/allthingslinux/xmpp.atl.chat/issues)

## 🎯 Next Steps

- **[Configuration Guide](configuration.md)** - Customize your server settings
- **[Security Guide](../admin/security.md)** - Harden your deployment
- **[Certificate Management](../admin/certificate-management.md)** - Automate SSL certificates
- **[WebSocket Configuration](../admin/websocket-configuration.md)** - Set up reverse proxy

---

**🎉 Congratulations!** Your XMPP server is ready. Start chatting with modern, secure, federated messaging!
