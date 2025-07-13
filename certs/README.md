# SSL/TLS Certificates Directory

This directory contains SSL/TLS certificates for the Prosody XMPP server.

## Structure

```
certs/
├── your-domain.com.crt        # Certificate file
├── your-domain.com.key        # Private key file
├── your-domain.com/           # Let's Encrypt format
│   ├── fullchain.pem          # Certificate chain
│   └── privkey.pem            # Private key
└── dhparam.pem                # Diffie-Hellman parameters (optional)
```

## Certificate Formats

The server supports multiple certificate formats:

1. **Standard format**: `domain.crt` and `domain.key`
2. **Let's Encrypt format**: `domain/fullchain.pem` and `domain/privkey.pem`

## Management

- **Manual placement**: Copy certificates directly to this directory
- **Let's Encrypt**: Use `docker compose --profile letsencrypt run --rm certbot`
- **Permissions**: Ensure proper ownership (UID 999 for container)

## Security

- Private keys should have 600 permissions
- Certificate files should have 644 permissions
- This directory is mounted read-write for certificate management
