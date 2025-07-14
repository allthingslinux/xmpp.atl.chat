# 🔐 SSL Certificate Management

Automated SSL certificate management for the Professional Prosody XMPP Server Docker deployment.

## 📋 Overview

This Docker setup provides **fully automated certificate management**:

- **Let's Encrypt certificates** - Automatic generation and renewal
- **Self-signed certificates** - Automatic fallback for development
- **Certificate detection** - Automatic discovery and configuration

## 🚀 Setup

### 1. Set Your Domain

```bash
# Edit .env file
PROSODY_DOMAIN=atl.chat
```

### 2. Generate Let's Encrypt Certificate

```bash
# One command to get certificates
docker compose --profile letsencrypt run --rm certbot

# Start the server
docker compose up -d
```

### 3. Set Up Automatic Renewal

```bash
# Add to crontab for daily renewal check
(crontab -l 2>/dev/null; echo "0 3 * * * /path/to/xmpp.atl.chat/scripts/renew-certificates.sh") | crontab -
```

**That's it!** Everything else is automated.

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
├── atl.chat.crt              # Standard certificate (if used)
├── atl.chat.key              # Standard private key (if used)
└── selfsigned/               # Auto-generated self-signed certs
    ├── atl.chat.crt
    └── atl.chat.key
```

### Automatic Renewal

The `scripts/renew-certificates.sh` script:

1. **Checks** for certificate expiry
2. **Renews** certificates if needed (30 days before expiry)
3. **Restarts** Prosody only if certificates were actually renewed

## 🏥 Health Check

Check certificate status:

```bash
# Check certificate expiry
docker compose exec prosody openssl x509 -in /etc/prosody/certs/atl.chat.crt -noout -dates

# Check if renewal is working
docker compose logs prosody | grep -i cert
```

## 🔍 Troubleshooting

### Certificate Not Found

If Prosody can't find certificates, it will:

1. Log the issue
2. Generate self-signed certificates automatically
3. Continue running (no downtime)

### Let's Encrypt Issues

Common issues:

- **Domain not accessible**: Ensure port 80 is open for HTTP challenge
- **Rate limits**: Let's Encrypt has rate limits (5 certificates per week)
- **DNS issues**: Domain must resolve to your server

### Development Mode

For development, just start the server - self-signed certificates are generated automatically:

```bash
docker compose up -d
```

No additional setup needed.
