# 🔐 Docker Certificate Management

Complete certificate management guide for the Professional Prosody XMPP Server Docker deployment.

## 📋 Overview

The Docker setup provides **automatic certificate management** with multiple deployment options:

1. **Let's Encrypt certificates** (recommended for production)
2. **Manual certificate placement** (for existing certificates)
3. **Self-signed certificates** (automatic fallback for development)

## 📁 Certificate Storage

Certificates are stored in the `./certs` directory (mapped to `/etc/prosody/certs` inside the container):

```
certs/
├── atl.chat.crt              # Standard certificate format
├── atl.chat.key              # Private key
├── atl.chat/                 # Let's Encrypt directory format
│   ├── fullchain.pem         # Certificate chain
│   └── privkey.pem           # Private key
└── live/                     # Let's Encrypt live directory
    └── atl.chat/             # Domain-specific certificates
        ├── fullchain.pem
        └── privkey.pem
```

## 🚀 Quick Setup Methods

### Method 1: Let's Encrypt (Recommended)

**Standard HTTP Challenge:**

```bash
# Set up your domain in .env file
echo "PROSODY_DOMAIN=atl.chat" >> .env

# Create webroot directory for HTTP challenge
mkdir -p letsencrypt-webroot

# Generate certificate
docker compose --profile letsencrypt run --rm certbot

# Start Prosody (automatically detects certificates)
docker compose up -d prosody db
```

**Wildcard Certificate (DNS Challenge):**

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

### Method 2: Manual Certificate Placement

**For existing certificates:**

```bash
# Copy certificates to the correct location
cp your-certificate.crt certs/atl.chat.crt
cp your-private-key.key certs/atl.chat.key

# Start Prosody
docker compose up -d prosody db
```

**For certificate chains:**

```bash
# Combine certificate and intermediate chain
cat your-certificate.crt intermediate.crt > certs/atl.chat.crt

# Or use fullchain if provided
cp fullchain.crt certs/atl.chat.crt
```

### Method 3: Self-Signed (Development)

```bash
# Just start Prosody - it generates self-signed certificates automatically
docker compose up -d prosody db
```

## 🔄 Automatic Certificate Renewal

### Setup Automated Renewal

**Using the provided renewal script (recommended):**

```bash
# Add to crontab (runs daily at 3 AM)
(crontab -l 2>/dev/null; echo "0 3 * * * /path/to/xmpp.atl.chat/scripts/renew-certificates.sh") | crontab -

# Test the renewal script
./scripts/renew-certificates.sh
```

**Manual renewal commands:**

```bash
# Renew certificates manually
docker compose --profile renewal run --rm certbot-renew

# Restart Prosody to use new certificates
docker compose restart prosody
```

### Renewal Process

The renewal script (`scripts/renew-certificates.sh`) automatically:

1. ✅ Runs `certbot renew` to check and renew certificates
2. ✅ Restarts Prosody only if renewal succeeded
3. ✅ Logs all activities to `/var/log/prosody-cert-renewal.log`
4. ✅ Handles errors gracefully

## 🔧 Certificate Detection

Prosody automatically detects certificates in this order:

1. **Let's Encrypt format**: `certs/{domain}/fullchain.pem` and `certs/{domain}/privkey.pem`
2. **Standard format**: `certs/{domain}.crt` and `certs/{domain}.key`
3. **Self-signed**: Generated automatically if none found

This is handled by the entrypoint script (`scripts/entrypoint.sh`) in the `setup_certificates()` function.

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
# Test TLS connection
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

**"Certificate not found":**

```bash
# Check if certificates exist
ls -la certs/

# Check what Prosody is looking for
docker logs prosody 2>&1 | grep -i cert

# Verify certificate format
file certs/atl.chat.crt
```

**"Certificate expired":**

```bash
# Check expiration
docker run --rm -v $(pwd)/certs:/certs debian:bookworm-slim \
  openssl x509 -in /certs/atl.chat.crt -noout -dates

# Renew Let's Encrypt certificate
docker compose --profile renewal run --rm certbot-renew
docker compose restart prosody
```

**"Domain mismatch":**

```bash
# Check certificate subject and SAN
docker run --rm -v $(pwd)/certs:/certs debian:bookworm-slim \
  openssl x509 -in /certs/atl.chat.crt -noout -subject -ext subjectAltName

# Ensure certificate matches your PROSODY_DOMAIN
grep PROSODY_DOMAIN .env
```

### Let's Encrypt Troubleshooting

**HTTP Challenge Fails:**

```bash
# Check if webroot is accessible
curl -I http://your-domain.com/.well-known/acme-challenge/test

# Verify DNS resolution
nslookup your-domain.com

# Check port 80 accessibility
telnet your-domain.com 80
```

**Rate Limiting:**

Let's Encrypt has rate limits (50 certificates per domain per week). Use staging for testing:

```bash
# Test with staging environment
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

## 🔗 Integration with Reverse Proxy

### Nginx Configuration

If using Nginx as a reverse proxy, you can share certificates:

```nginx
server {
    listen 443 ssl http2;
    server_name xmpp.atl.chat;
    
    # Use the same certificates as Prosody
    ssl_certificate /path/to/xmpp.atl.chat/certs/atl.chat.crt;
    ssl_certificate_key /path/to/xmpp.atl.chat/certs/atl.chat.key;
    
    # WebSocket proxy for XMPP
    location /xmpp-websocket {
        proxy_pass http://localhost:5280;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Apache Configuration

```apache
<VirtualHost *:443>
    ServerName xmpp.atl.chat
    
    SSLEngine on
    SSLCertificateFile /path/to/xmpp.atl.chat/certs/atl.chat.crt
    SSLCertificateKeyFile /path/to/xmpp.atl.chat/certs/atl.chat.key
    
    # WebSocket proxy
    ProxyPreserveHost On
    ProxyRequests Off
    
    <Location /xmpp-websocket>
        ProxyPass http://localhost:5280/xmpp-websocket
        ProxyPassReverse http://localhost:5280/xmpp-websocket
        ProxyPass ws://localhost:5280/xmpp-websocket
        ProxyPassReverse ws://localhost:5280/xmpp-websocket
    </Location>
</VirtualHost>
```

## 📊 Monitoring Certificate Health

### Health Check Script

The container includes a health check that validates certificates:

```bash
# Run health check manually
docker exec prosody /usr/local/bin/health-check.sh

# Check all container health
docker compose ps
```

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

## 🔒 Security Best Practices

### Certificate Security

- **Use strong certificates**: RSA 2048-bit minimum, ECDSA P-256 preferred
- **Regular renewal**: Automate certificate renewal
- **Secure storage**: Docker handles permissions automatically
- **Monitor expiration**: Set up alerts for certificate expiry

### TLS Configuration

The Docker setup automatically configures secure TLS settings in `config/prosody.cfg.lua`:

```lua
-- Secure TLS configuration
ssl = {
 protocol = "tlsv1_2+", -- TLS 1.2+ only
 ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS",
 curve = "secp384r1", -- Strong elliptic curve
 options = { "cipher_server_preference", "single_dh_use", "single_ecdh_use" },
}

-- Automatic certificate discovery
certificates = "certs"
```

## 📚 Environment Variables

Key certificate-related environment variables:

```bash
# Required
PROSODY_DOMAIN=atl.chat                    # Your domain (certificate CN/SAN)

# Optional
PROSODY_ADMIN_JID=admin@atl.chat          # Admin contact for Let's Encrypt
```

## 🎯 Production Checklist

Before going to production:

- [ ] **Valid SSL certificate** (Let's Encrypt or commercial)
- [ ] **Automated renewal** set up via cron
- [ ] **Certificate monitoring** in place
- [ ] **DNS properly configured** for your domain
- [ ] **Firewall allows** ports 80 (HTTP challenge) and 443 (HTTPS)
- [ ] **Test certificate renewal** process
- [ ] **Backup certificates** included in backup strategy

---

This Docker setup provides a complete, automated certificate management solution that handles all the complexity of SSL certificates while maintaining security best practices. The automatic detection and renewal features ensure your XMPP server stays secure with minimal manual intervention.
