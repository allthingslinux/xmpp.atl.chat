# SSL/TLS Certificates Directory

This directory contains SSL/TLS certificates for the Prosody XMPP server.

## Wildcard Certificate Setup

The server uses **wildcard certificates** generated via **Cloudflare DNS-01 challenges**:

- **Domain coverage**: `*.atl.chat` covers all subdomains automatically
- **Security**: No need to expose port 80 publicly
- **Management**: Automated renewal via DNS API

## Structure

```text
certs/
├── live/
│   └── atl.chat/              # Let's Encrypt wildcard certificate
│       ├── fullchain.pem      # Certificate chain (cert + intermediate)
│       ├── privkey.pem        # Private key
│       ├── cert.pem           # Certificate only
│       └── chain.pem          # Intermediate certificate
├── archive/                   # Certificate history/backups
└── renewal/                   # Let's Encrypt renewal configuration
```

## Certificate Management

### Automatic Generation (Recommended)

**⚠️ Important**: Generate certificates **before** starting Prosody for production use.

```bash
# 1. Configure Cloudflare API credentials
cp examples/cloudflare-credentials.ini.example cloudflare-credentials.ini
# Edit with your Cloudflare API token

# 2. Generate wildcard certificate (ONE-TIME SETUP)
docker compose --profile letsencrypt run --rm certbot

# 3. Start Prosody with real certificates
docker compose up -d prosody db
```

**Why this separate step?**

- **Security**: Avoids self-signed certificates in production
- **DNS-01 challenges**: Requires Cloudflare API setup first
- **One-time setup**: After this, renewals are automated

## Environment Variables

- `PROSODY_DOMAIN`: Main domain (default: `atl.chat`)
- `LETSENCRYPT_EMAIL`: Certificate notification email (default: `admin@allthingslinux.org`)

## Security

- **Permissions**: Container runs as prosody user (UID 999)
- **Private keys**: Automatically secured with 600 permissions
- **Certificate files**: Readable by Prosody process
- **Volume mount**: Read-write for certificate management and renewal

## Renewal

### Automated Renewal (Recommended)

**Production setup** - Use the renewal script with cron:

```bash
# Set up cron job (runs daily at 3 AM)
0 3 * * * /path/to/xmpp.atl.chat/scripts/renew-certificates.sh

# Manual run for testing
./scripts/renew-certificates.sh
```

**Benefits of the renewal script:**

- ✅ **Automatic Prosody reload** after successful renewal
- ✅ **Comprehensive logging** to `/var/log/prosody-cert-renewal.log`
- ✅ **Error handling** and validation checks
- ✅ **Cron-friendly** with proper exit codes

### Manual Renewal

**For testing or troubleshooting:**

```bash
# Renew certificates only (no Prosody reload)
docker compose --profile renewal run --rm certbot-renew

# Manual Prosody reload (if needed)
docker compose restart prosody
```

**Note:** Manual renewal requires you to restart Prosody manually to apply new certificates.
