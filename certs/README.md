# SSL/TLS Certificates Directory

This directory contains SSL/TLS certificates for the Prosody XMPP server.

## Wildcard Certificate Setup

The server uses **wildcard certificates** generated via **Cloudflare DNS-01 challenges**:

- **Domain coverage**: `*.atl.chat` covers all subdomains automatically
- **Security**: No need to expose port 80 publicly
- **Management**: Automated renewal via DNS API

## Structure

```
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
cp cloudflare-credentials.ini.example cloudflare-credentials.ini
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

### Manual Certificate Placement

If using custom certificates:

```bash
# Place certificates in Let's Encrypt format
mkdir -p certs/live/atl.chat/
cp your-fullchain.pem certs/live/atl.chat/fullchain.pem
cp your-privkey.pem certs/live/atl.chat/privkey.pem
```

## Environment Variables

- `PROSODY_DOMAIN`: Main domain (default: `atl.chat`)
- `LETSENCRYPT_EMAIL`: Certificate notification email (default: `admin@allthingslinux.org`)

## Security

- **Permissions**: Container runs as prosody user (UID 999)
- **Private keys**: Automatically secured with 600 permissions
- **Certificate files**: Readable by Prosody process
- **Volume mount**: Read-write for certificate management and renewal

## Renewal

Certificates are automatically renewed via:

- **Cron job**: Set up via `scripts/renew-certificates.sh`
- **Docker profile**: `docker compose --profile letsencrypt run --rm certbot`
- **Automatic restart**: Prosody service reloads after renewal
