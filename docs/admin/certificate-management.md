# 🔐 SSL Certificate Management - Docker Setup

Complete SSL certificate management guide for the Professional Prosody XMPP Server Docker deployment.

## 📋 Overview

This Docker setup provides **automatic certificate management** with multiple options:

- **Let's Encrypt certificates** (recommended for production)
- **Manual certificate placement** (for existing certificates)
- **Self-signed certificates** (automatic fallback for development)

All certificates are stored in the `./certs` directory and automatically detected by Prosody.

## 🚀 Quick Start

### 1. Let's Encrypt (Recommended)

```bash
# Set up your domain in .env file
echo "PROSODY_DOMAIN=atl.chat" >> .env

# Create webroot directory for HTTP challenge
mkdir -p letsencrypt-webroot

# Generate certificate
docker compose --profile letsencrypt run --rm certbot

# Start Prosody (will automatically find and use certificates)
docker compose up -d prosody db
```

### 2. Manual Certificate

```bash
# Copy your existing certificates
cp your-certificate.crt certs/atl.chat.crt
cp your-private-key.key certs/atl.chat.key

# Start Prosody
docker compose up -d prosody db
```

### 3. Self-Signed (Development)

```bash
# Just start Prosody - it will generate self-signed certificates automatically
docker compose up -d prosody db
```

## 🔧 Certificate Detection

Prosody automatically detects certificates in this order:

1. **Let's Encrypt format**: `certs/{domain}/fullchain.pem` and `certs/{domain}/privkey.pem`
2. **Standard format**: `certs/{domain}.crt` and `certs/{domain}.key`
3. **Self-signed**: Generated automatically if none found

## 📁 Directory Structure

```
project/
├── certs/                          # Certificate directory
│   ├── atl.chat.crt               # Standard certificate
│   ├── atl.chat.key               # Private key
│   ├── atl.chat/                  # Let's Encrypt directory
│   │   ├── fullchain.pem          # Certificate chain
│   │   └── privkey.pem            # Private key
│   └── live/                      # Let's Encrypt live directory
│       └── atl.chat/              # Domain-specific certificates
│           ├── fullchain.pem
│           └── privkey.pem
├── letsencrypt-webroot/           # HTTP challenge directory
│   └── .well-known/
│       └── acme-challenge/
└── docker-compose.yml
```

## 🌐 Let's Encrypt Setup

### Standard Domain Certificate

```bash
# Set domain in .env
PROSODY_DOMAIN=atl.chat

# Create webroot directory
mkdir -p letsencrypt-webroot

# Generate certificate
docker compose --profile letsencrypt run --rm certbot

# Certificates will be placed in:
# - certs/live/atl.chat/fullchain.pem
# - certs/live/atl.chat/privkey.pem
```

### Wildcard Certificate (DNS Challenge)

For wildcard certificates, you need to use DNS challenge:

```bash
# Interactive DNS challenge (requires manual DNS record creation)
docker run --rm -it \
  -v $(pwd)/certs:/etc/letsencrypt \
  certbot/certbot certonly \
  --manual \
  --preferred-challenges=dns \
  --email admin@atl.chat \
  --agree-tos \
  --no-eff-email \
  -d "atl.chat,*.atl.chat"
```

**Note**: You'll need to create DNS TXT records during the process.

### HTTP Challenge Requirements

For HTTP challenge to work, ensure:

1. **Port 80 accessible**: Your server must be reachable on port 80
2. **Domain points to server**: DNS A record for your domain
3. **Webroot directory**: `letsencrypt-webroot` directory exists

## 🔄 Automatic Certificate Renewal

### Setup Automated Renewal

The easiest way to set up automatic renewal:

```bash
# Add to crontab (run daily at 3 AM)
(crontab -l 2>/dev/null; echo "0 3 * * * /path/to/xmpp.atl.chat/scripts/renew-certificates.sh") | crontab -

# Test the renewal script
./scripts/renew-certificates.sh
```

### Manual Renewal

```bash
# Renew certificates manually
docker compose --profile renewal run --rm certbot-renew

# Restart Prosody to use new certificates
docker compose restart prosody
```

### Renewal Process

The renewal script (`scripts/renew-certificates.sh`) automatically:

1. ✅ Checks if certificates need renewal
2. ✅ Runs Let's Encrypt renewal
3. ✅ Restarts Prosody if renewal succeeded
4. ✅ Logs all activities to `/var/log/prosody-cert-renewal.log`

## 📝 Manual Certificate Management

### Using Existing Certificates

```bash
# Copy certificates to the correct location
cp your-certificate.crt certs/atl.chat.crt
cp your-private-key.key certs/atl.chat.key

# Set proper permissions (optional, Docker handles this)
chmod 644 certs/atl.chat.crt
chmod 600 certs/atl.chat.key

# Restart Prosody to use new certificates
docker compose restart prosody
```

### Certificate Chain

If you have intermediate certificates:

```bash
# Combine certificate and intermediate chain
cat your-certificate.crt intermediate.crt > certs/atl.chat.crt

# Or use the provided fullchain if available
cp fullchain.crt certs/atl.chat.crt
```

## 🔍 Certificate Validation

### Check Certificate Status

```bash
# View certificate details
docker run --rm -v $(pwd)/certs:/certs debian:bookworm-slim \
  openssl x509 -in /certs/atl.chat.crt -text -noout

# Check expiration date
docker run --rm -v $(pwd)/certs:/certs debian:bookworm-slim \
  openssl x509 -in /certs/atl.chat.crt -noout -dates

# Verify certificate chain
docker run --rm -v $(pwd)/certs:/certs debian:bookworm-slim \
  openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt /certs/atl.chat.crt
```

### Test XMPP Connection

```bash
# Test TLS connection to your server
openssl s_client -connect atl.chat:5222 -starttls xmpp -verify_hostname atl.chat

# Test direct TLS connection
openssl s_client -connect atl.chat:5223 -verify_hostname atl.chat
```

### Check Prosody Logs

```bash
# Check certificate loading in Prosody logs
docker logs prosody 2>&1 | grep -i cert

# Monitor logs in real-time
docker logs -f prosody
```

## 🛠️ Troubleshooting

### Common Issues

#### "Certificate not found"

```bash
# Check if certificates exist
ls -la certs/

# Check Prosody logs
docker logs prosody 2>&1 | grep -i cert

# Verify certificate format
file certs/atl.chat.crt
```

#### "Permission denied"

```bash
# Docker handles permissions automatically, but if issues persist:
chmod 644 certs/*.crt
chmod 600 certs/*.key

# Restart Prosody
docker compose restart prosody
```

#### "Certificate expired"

```bash
# Check expiration
openssl x509 -in certs/atl.chat.crt -noout -dates

# Renew Let's Encrypt certificate
docker compose --profile renewal run --rm certbot-renew
docker compose restart prosody
```

#### "Domain mismatch"

```bash
# Check certificate subject and SAN
openssl x509 -in certs/atl.chat.crt -noout -subject -ext subjectAltName

# Ensure certificate matches your PROSODY_DOMAIN
grep PROSODY_DOMAIN .env
```

### Let's Encrypt Troubleshooting

#### HTTP Challenge Fails

```bash
# Check if webroot is accessible
curl -I http://your-domain.com/.well-known/acme-challenge/test

# Verify DNS resolution
nslookup your-domain.com

# Check port 80 accessibility
telnet your-domain.com 80
```

#### Rate Limiting

Let's Encrypt has rate limits:

- 50 certificates per domain per week
- 5 duplicate certificates per week

```bash
# Check rate limits at: https://letsencrypt.org/docs/rate-limits/
# Use staging environment for testing:
docker run --rm -it \
  -v $(pwd)/certs:/etc/letsencrypt \
  certbot/certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --staging \
  --email admin@your-domain.com \
  --agree-tos \
  --no-eff-email \
  -d your-domain.com
```

## 🔒 Security Best Practices

### Certificate Security

- **Use strong certificates**: RSA 2048-bit minimum, ECDSA P-256 preferred
- **Regular renewal**: Automate certificate renewal
- **Secure storage**: Keep private keys secure (Docker handles this)
- **Monitor expiration**: Set up alerts for certificate expiry

### Prosody Configuration

The Docker setup automatically configures secure TLS settings:

```lua
-- Automatic TLS configuration in prosody.cfg.lua
ssl = {
 protocol = "tlsv1_2+", -- TLS 1.2+ only
 ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS",
 curve = "secp384r1", -- Strong elliptic curve
 options = { "cipher_server_preference", "single_dh_use", "single_ecdh_use" },
}

-- Certificate auto-discovery
certificates = "certs"
```

## 📊 Monitoring

### Certificate Monitoring

```bash
# Check certificate expiry (30 days warning)
docker run --rm -v $(pwd)/certs:/certs debian:bookworm-slim bash -c '
  cert_file="/certs/atl.chat.crt"
  if [[ -f "$cert_file" ]]; then
    if ! openssl x509 -in "$cert_file" -noout -checkend 2592000; then
      echo "Certificate expires within 30 days"
    else
      echo "Certificate is valid"
    fi
  fi
'

# Check renewal logs
tail -f /var/log/prosody-cert-renewal.log
```

### Health Checks

```bash
# Prosody health check (includes certificate validation)
docker exec prosody /usr/local/bin/health-check.sh

# Check all container health
docker compose ps
```

## 🔗 Integration Examples

### Reverse Proxy (Nginx)

If using Nginx as reverse proxy, you can share certificates:

```nginx
server {
    listen 443 ssl http2;
    server_name xmpp.atl.chat;
    
    # Use the same certificates as Prosody
    ssl_certificate /path/to/xmpp.atl.chat/certs/atl.chat.crt;
    ssl_certificate_key /path/to/xmpp.atl.chat/certs/atl.chat.key;
    
    location /xmpp-websocket {
        proxy_pass http://localhost:5280;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### CI/CD Integration

```yaml
# .github/workflows/deploy.yml
- name: Renew certificates
  run: |
    cd /path/to/xmpp.atl.chat
    ./scripts/renew-certificates.sh
```

## 📚 Environment Variables

Key certificate-related environment variables:

```bash
# Required
PROSODY_DOMAIN=atl.chat                    # Your domain (certificate CN/SAN)

# Optional
PROSODY_CERT_DIR=/etc/prosody/certs       # Certificate directory (default)
PROSODY_ADMIN_JID=admin@atl.chat          # Admin contact for Let's Encrypt
```

## 🎯 Production Checklist

Before going to production:

- [ ] **Valid SSL certificate** (Let's Encrypt or commercial)
- [ ] **Automated renewal** set up via cron
- [ ] **Certificate monitoring** in place
- [ ] **Backup certificates** included in backup strategy
- [ ] **DNS properly configured** for your domain
- [ ] **Firewall allows** ports 80 (HTTP challenge) and 443 (HTTPS)
- [ ] **Test certificate renewal** process

---

This Docker setup provides a complete, automated certificate management solution that handles all the complexity of SSL certificates while maintaining security best practices. The automatic detection and renewal features ensure your XMPP server stays secure with minimal manual intervention.
