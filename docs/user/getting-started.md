# 🚀 Getting Started

Deploy a professional Prosody XMPP server in 5 minutes using Docker Compose. This guide covers everything from initial setup to connecting your first client.

## ⚡ Quick Deploy

### 1. Prerequisites

- **Docker** 20.10+ and **Docker Compose** 2.0+
- **Domain name** with DNS control (e.g., `chat.example.com`)
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
PROSODY_DOMAIN=chat.example.com
PROSODY_ADMINS=admin@chat.example.com
PROSODY_DB_PASSWORD=ChangeMe123!
```

### 4. Deploy

```bash
# Start the server (minimal deployment)
docker-compose up -d prosody db

# Check status
docker-compose logs -f prosody
```

### 5. Create Users

```bash
# Create admin user
docker-compose exec prosody prosodyctl adduser admin@chat.example.com

# Create regular users
docker-compose exec prosody prosodyctl adduser alice@chat.example.com
docker-compose exec prosody prosodyctl adduser bob@chat.example.com
```

### 6. Connect

Your XMPP server is ready! Connect with any XMPP client using:

- **Server**: `chat.example.com`
- **Port**: `5222` (STARTTLS) or `5223` (Direct TLS)
- **Username**: `alice@chat.example.com`
- **Password**: (what you set when creating the user)

## 🌐 DNS Setup

### Required DNS Records

Add these DNS records for your domain:

```
# SRV records for client discovery
_xmpp-client._tcp.chat.example.com.  3600  IN  SRV  5 0 5222 chat.example.com.
_xmpps-client._tcp.chat.example.com. 3600  IN  SRV  5 0 5223 chat.example.com.

# SRV records for server-to-server
_xmpp-server._tcp.chat.example.com.  3600  IN  SRV  5 0 5269 chat.example.com.
_xmpps-server._tcp.chat.example.com. 3600  IN  SRV  5 0 5270 chat.example.com.

# A record pointing to your server
chat.example.com.                    3600  IN  A    YOUR.SERVER.IP.ADDRESS
```

## 🔒 SSL Certificates

### Option 1: Let's Encrypt (Recommended)

```bash
# Install certbot
sudo apt install certbot

# Get certificate
sudo certbot certonly --standalone -d chat.example.com

# Copy certificates to prosody
sudo cp /etc/letsencrypt/live/chat.example.com/fullchain.pem /path/to/prosody/certs/
sudo cp /etc/letsencrypt/live/chat.example.com/privkey.pem /path/to/prosody/certs/
sudo chown prosody:prosody /path/to/prosody/certs/*
```

### Option 2: Existing Certificates

```bash
# Copy your certificates
cp your-cert.pem /path/to/prosody/certs/chat.example.com.crt
cp your-key.pem /path/to/prosody/certs/chat.example.com.key

# Set permissions
sudo chown prosody:prosody /path/to/prosody/certs/*
sudo chmod 600 /path/to/prosody/certs/*.key
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
Server: chat.example.com
Port: 5222 (STARTTLS) or 5223 (Direct TLS)
Username: alice@chat.example.com
Password: [your password]
```

## 🌐 Web Access

### Admin Panel

Access the web admin panel at:

- **URL**: `https://chat.example.com:5281/admin`
- **Username**: `admin@chat.example.com`
- **Password**: [admin password]

### File Upload

Users can upload files at:

- **URL**: `https://chat.example.com:5281/upload`

### WebSocket (for web clients)

Web clients can connect via WebSocket:

- **URL**: `wss://chat.example.com:5281/xmpp-websocket`

## 🔧 Additional Services

### Add Voice/Video Support

```bash
# Deploy with TURN/STUN server for voice/video calls
docker-compose up -d prosody db coturn
```

### Add Monitoring

```bash
# Deploy with monitoring stack
docker-compose up -d prosody db prometheus grafana
```

### Full Deployment

```bash
# Deploy everything
docker-compose up -d
```

## ✅ Verify Your Setup

### Check Server Status

```bash
# Check if prosody is running
docker-compose exec prosody prosodyctl status

# Test connectivity
docker-compose exec prosody prosodyctl check connectivity chat.example.com

# Check configuration
docker-compose exec prosody prosodyctl check config
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
docker-compose exec prosody prosodyctl list users chat.example.com

# Change password
docker-compose exec prosody prosodyctl passwd alice@chat.example.com

# Delete user
docker-compose exec prosody prosodyctl deluser bob@chat.example.com
```

### Server Management

```bash
# Restart prosody
docker-compose restart prosody

# View logs
docker-compose logs -f prosody

# Update prosody
docker-compose pull && docker-compose up -d
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

- **Logs**: `docker-compose logs prosody`
- **Test connectivity**: `prosodyctl check connectivity yourdomain.com`
- **Configuration test**: `prosodyctl check config`
- **Issues**: [GitHub Issues](https://github.com/allthingslinux/xmpp.atl.chat/issues)

## 🎯 Next Steps

- **[Configuration Guide](configuration.md)** - Customize your server settings
- **[Security Guide](../admin/security.md)** - Harden your deployment
- **[Certificate Management](../admin/certificate-management.md)** - Automate SSL certificates
- **[WebSocket Configuration](../admin/websocket-configuration.md)** - Set up reverse proxy

---

**🎉 Congratulations!** Your XMPP server is ready. Start chatting with modern, secure, federated messaging!
