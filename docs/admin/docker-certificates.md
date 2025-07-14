# 🔐 Docker Certificate Management

Automated certificate management for the Professional Prosody XMPP Server Docker deployment.

## 📋 Overview

The Docker setup provides **fully automated certificate management**:

1. **Let's Encrypt certificates** - Automatic generation and renewal
2. **Self-signed certificates** - Automatic fallback for development

## 🚀 Quick Setup

### Let's Encrypt (Production)

```bash
# Set domain in .env
PROSODY_DOMAIN=atl.chat

# Generate certificate
docker compose --profile letsencrypt run --rm certbot

# Start server
docker compose up -d
```

### Self-Signed (Development)

```bash
# Just start - certificates are generated automatically
docker compose up -d
```

## 🔧 How It Works

### Automatic Certificate Detection

Prosody automatically detects certificates in this order:

1. **Let's Encrypt**: `certs/{domain}/fullchain.pem` and `certs/{domain}/privkey.pem`
2. **Standard format**: `certs/{domain}.crt` and `certs/{domain}.key`
3. **Self-signed**: Generated automatically if none found

### Directory Structure

```
certs/
├── live/
│   └── atl.chat/
│       ├── fullchain.pem      # Let's Encrypt certificate
│       └── privkey.pem        # Let's Encrypt private key
└── atl.chat.crt               # Self-signed (if no Let's Encrypt)
└── atl.chat.key               # Self-signed private key
```

## 🔄 Automatic Renewal

### Setup

```bash
# Add to crontab for daily renewal check
(crontab -l 2>/dev/null; echo "0 3 * * * /path/to/xmpp.atl.chat/scripts/renew-certificates.sh") | crontab -
```

### How It Works

The renewal script runs daily and:

1. ✅ Checks if certificates need renewal
2. ✅ Renews certificates if needed
3. ✅ Restarts Prosody automatically
4. ✅ Logs to `/var/log/prosody-cert-renewal.log`

## 🔍 Checking Status

```bash
# Check certificate expiration
docker run --rm -v $(pwd)/certs:/certs debian:bookworm-slim \
  openssl x509 -in /certs/live/atl.chat/fullchain.pem -noout -dates

# Check Prosody logs
docker logs prosody 2>&1 | grep -i cert

# Check renewal logs
tail -f /var/log/prosody-cert-renewal.log
```

## 🛠️ Troubleshooting

**Certificate not found:**

- Check `ls -la certs/` - certificates should be there
- Check `docker logs prosody` for certificate loading messages

**Let's Encrypt fails:**

- Ensure port 80 is open and accessible
- Verify DNS points to your server
- Check rate limits (50 certs per domain per week)

**Renewal fails:**

- Check `/var/log/prosody-cert-renewal.log`
- Test renewal manually: `./scripts/renew-certificates.sh`

## 📚 Environment Variables

```bash
# Required
PROSODY_DOMAIN=atl.chat                    # Your domain

# Optional
PROSODY_ADMIN_JID=admin@atl.chat          # Admin contact for Let's Encrypt
```

## 🎯 Production Checklist

- [ ] **Domain configured** in `.env` file
- [ ] **DNS points to server** (A record)
- [ ] **Port 80 open** for Let's Encrypt HTTP challenge
- [ ] **Cron job set up** for automatic renewal
- [ ] **Test renewal** with `./scripts/renew-certificates.sh`

---

This Docker setup handles all certificate complexity automatically. Just set your domain, run the Let's Encrypt command once, and set up the cron job for renewal. Everything else is automated.
