# 🔐 SSL Certificate Management

Automated SSL certificate management for the Professional Prosody XMPP Server Docker deployment using **Cloudflare DNS-01 challenges** for wildcard certificate support.

## 📋 Overview

This Docker setup provides **fully automated wildcard certificate management**:

- **Wildcard Let's Encrypt certificates** - Covers all subdomains (muc.atl.chat, upload.atl.chat, etc.)
- **DNS-01 challenges** - Uses Cloudflare API for domain validation
- **Self-signed certificates** - Automatic fallback for development
- **Certificate detection** - Automatic discovery and configuration

## 🚀 Setup

### 1. Set Your Domain and Email

```bash
# Edit .env file
PROSODY_DOMAIN=atl.chat
LETSENCRYPT_EMAIL=admin@allthingslinux.org
```

### 2. Configure Cloudflare API

```bash
# Copy the credentials template
cp examples/cloudflare-credentials.ini.example cloudflare-credentials.ini

# Edit with your Cloudflare API token
# Get token from: https://dash.cloudflare.com/profile/api-tokens
# Permissions needed: Zone:Zone:Read, Zone:DNS:Edit
```

### 3. Generate Wildcard Certificate

```bash
# Generate wildcard certificate for all subdomains
docker compose --profile letsencrypt run --rm xmpp-certbot

# Start the server
docker compose up -d
```

### 4. Set Up Automatic Renewal

```bash
# Add to crontab for daily renewal check
(crontab -l 2>/dev/null; echo "0 3 * * * /opt/xmpp.atl.chat/scripts/renew-certificates.sh") | crontab -
```

**That's it!** Everything else is automated.

## 🔧 How It Works

### Wildcard Certificate Coverage

The wildcard certificate (`*.atl.chat`) automatically covers:

- **Main domain**: `atl.chat`
- **MUC service**: `muc.atl.chat`
- **File upload**: `upload.atl.chat`
- **Proxy service**: `proxy.atl.chat`
- **Any future subdomains**: `anything.atl.chat`

### Automatic Certificate Detection

Prosody automatically detects certificates in this order:

1. **Let's Encrypt**: `certs/live/{domain}/fullchain.pem` and `certs/live/{domain}/privkey.pem`
2. **Standard format**: `certs/{domain}.crt` and `certs/{domain}.key`
3. **Self-signed**: Generated automatically if none found

### Directory Structure

```text
certs/
├── live/
│   └── atl.chat/
│       ├── fullchain.pem      # Wildcard certificate
│       └── privkey.pem        # Private key
├── archive/                   # Certificate history
├── renewal/                   # Renewal configuration
└── selfsigned/               # Auto-generated self-signed certs (fallback)
    ├── atl.chat.crt
    └── atl.chat.key
```

### DNS-01 Challenge Process

1. **Certbot** requests certificate from Let's Encrypt
2. **Let's Encrypt** provides DNS challenge
3. **Cloudflare plugin** automatically creates DNS TXT record
4. **Let's Encrypt** validates domain ownership via DNS
5. **Certificate** is issued and stored in `certs/live/`

### Automatic Renewal

The `scripts/renew-certificates.sh` script:

1. **Checks** for certificate expiry (30 days before expiry)
2. **Renews** certificates using DNS-01 challenges
3. **Restarts** Prosody only if certificates were actually renewed

## 🏥 Health Check

Check certificate status:

```bash
# Check certificate expiry and domains covered
docker compose exec xmpp-prosody openssl x509 -in /etc/prosody/certs/live/atl.chat/fullchain.pem -noout -dates -text | grep -A5 "Subject Alternative Name"

# Check if renewal is working
docker compose logs xmpp-prosody | grep -i cert
```

## 🔍 Troubleshooting

### Certificate Not Found

If Prosody can't find certificates, it will:

1. Log the issue
2. Generate self-signed certificates automatically
3. Continue running (no downtime)

### Cloudflare API Issues

Common issues:

- **Invalid API token**: Check token permissions (Zone:Zone:Read, Zone:DNS:Edit)
- **Wrong domain**: Ensure token is for the correct Cloudflare account/zone
- **Rate limits**: Cloudflare has API rate limits
- **DNS propagation**: Wait 60+ seconds for DNS changes to propagate

### Let's Encrypt Issues

Common issues:

- **Rate limits**: Let's Encrypt has rate limits (5 certificates per week)
- **DNS issues**: Domain must be managed by Cloudflare
- **API connectivity**: Ensure container can reach Cloudflare API

### Development Mode

For development, just start the server - self-signed certificates are generated automatically:

```bash
docker compose up -d
```

No Cloudflare setup needed for development.

## 🔐 Security Notes

- **Keep `cloudflare-credentials.ini` secure** - Contains sensitive API credentials
- **Use API tokens** instead of global API keys (more secure)
- **Rotate tokens regularly** for better security
- **Monitor certificate expiry** - Set up alerts if renewal fails

## 🎯 Why DNS-01 Challenges?

- **Wildcard support**: Only DNS-01 challenges can issue wildcard certificates
- **No port requirements**: No need to expose port 80 publicly
- **Cloudflare integration**: Seamless with Cloudflare-managed domains
- **Subdomain coverage**: Single certificate covers all current and future subdomains
