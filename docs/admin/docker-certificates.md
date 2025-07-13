# Certificate Management for Docker Deployments

This guide explains how to manage SSL/TLS certificates for your Prosody XMPP server running in Docker.

## Overview

The Docker setup supports multiple certificate deployment methods:

1. **Let's Encrypt certificates** (recommended for production)
2. **Manual certificate placement**
3. **Self-signed certificates** (development only)

## Certificate Volume Structure

Certificates are stored in the `prosody_certs` Docker volume, mapped to `/etc/prosody/certs` inside the container:

```
/etc/prosody/certs/
├── atl.chat.crt              # Standard certificate format
├── atl.chat.key              # Private key
├── atl.chat/                 # Let's Encrypt format
│   ├── fullchain.pem         # Certificate chain
│   └── privkey.pem           # Private key
└── dhparam.pem               # Diffie-Hellman parameters (optional)
```

## Method 1: Let's Encrypt Integration (Recommended)

### Using Certbot with Docker

1. **For standard domains** (HTTP validation):

   ```bash
   # Create certificates using Certbot with webroot
   docker run --rm -it \
     -v prosody_certs:/etc/letsencrypt \
     -v $(pwd)/letsencrypt-webroot:/var/www/certbot \
     certbot/certbot certonly \
     --webroot \
     --webroot-path=/var/www/certbot \
     --email admin@atl.chat \
     --agree-tos \
     --no-eff-email \
     -d atl.chat \
     -d xmpp.atl.chat
   ```

2. **For wildcard domains** (DNS validation):

   ```bash
   # Create wildcard certificates using manual DNS validation
   docker run --rm -it \
     -v prosody_certs:/etc/letsencrypt \
     certbot/certbot certonly \
     --manual \
     --preferred-challenges=dns \
     --email admin@atl.chat \
     --agree-tos \
     --no-eff-email \
     -d "atl.chat,*.atl.chat"
   ```

   **Note**: Wildcard certificates require manual DNS TXT record creation during the process.

3. **Set up certificate linking**:

   ```bash
   # Link Let's Encrypt certificates to expected location
   docker run --rm -it \
     -v prosody_certs:/certs \
     debian:bookworm-slim \
     bash -c "
       mkdir -p /certs/atl.chat
       ln -sf /certs/live/atl.chat/fullchain.pem /certs/atl.chat/fullchain.pem
       ln -sf /certs/live/atl.chat/privkey.pem /certs/atl.chat/privkey.pem
       chown -R 999:999 /certs/atl.chat
     "
   ```

### Automatic Renewal

Add a renewal service to your Docker Compose:

```yaml
  certbot:
    image: certbot/certbot
    container_name: prosody-certbot
    volumes:
      - prosody_certs:/etc/letsencrypt
      - ./letsencrypt-webroot:/var/www/certbot
    command: renew --quiet
    profiles:
      - renewal
```

Run renewal with:

```bash
docker-compose --profile renewal up certbot
```

## Method 2: Manual Certificate Placement

### For existing certificates

1. **Copy certificates to volume**:

   ```bash
   # Create a temporary container to copy files
   docker create --name temp-cert -v prosody_certs:/certs debian:bookworm-slim
   docker cp your-certificate.crt temp-cert:/certs/atl.chat.crt
   docker cp your-private-key.key temp-cert:/certs/atl.chat.key
   docker rm temp-cert
   ```

2. **Set proper permissions**:

   ```bash
   docker run --rm -v prosody_certs:/certs debian:bookworm-slim \
     bash -c "
       chown 999:999 /certs/atl.chat.*
       chmod 644 /certs/atl.chat.crt
       chmod 600 /certs/atl.chat.key
     "
   ```

## Certificate Validation

### Check certificate status

```bash
# Inspect certificate details
docker run --rm -v prosody_certs:/certs debian:bookworm-slim \
  openssl x509 -in /certs/atl.chat.crt -text -noout

# Check expiration
docker run --rm -v prosody_certs:/certs debian:bookworm-slim \
  openssl x509 -in /certs/atl.chat.crt -noout -dates

# Verify certificate chain
docker run --rm -v prosody_certs:/certs debian:bookworm-slim \
  openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt /certs/atl.chat.crt
```

## Integration with Reverse Proxy

### Nginx Configuration

If using Nginx as a reverse proxy, you can share certificates:

```yaml
volumes:
  - prosody_certs:/etc/nginx/certs:ro  # Read-only access for Nginx
```

Example Nginx config:

```nginx
server {
    listen 443 ssl http2;
    server_name xmpp.atl.chat;
    
    ssl_certificate /etc/nginx/certs/atl.chat.crt;
    ssl_certificate_key /etc/nginx/certs/atl.chat.key;
    
    # Proxy WebSocket connections
    location /xmpp-websocket {
        proxy_pass http://prosody:5280;
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

## Troubleshooting

### Common Issues

1. **Permission errors**:

   ```bash
   # Fix certificate permissions
   docker run --rm -v prosody_certs:/certs debian:bookworm-slim \
     bash -c "chown -R 999:999 /certs && chmod 600 /certs/*.key"
   ```

2. **Certificate not found**:

   ```bash
   # List certificates in volume
   docker run --rm -v prosody_certs:/certs debian:bookworm-slim ls -la /certs/
   ```

3. **Wrong domain in certificate**:

   ```bash
   # Check certificate subject and SAN
   docker run --rm -v prosody_certs:/certs debian:bookworm-slim \
     openssl x509 -in /certs/atl.chat.crt -noout -subject -ext subjectAltName
   ```

### Container Logs

Check Prosody logs for certificate issues:

```bash
docker logs prosody 2>&1 | grep -i cert
```

### Health Check

The container includes a health check that validates certificate availability:

```bash
docker exec prosody /opt/prosody/scripts/health-check.sh
```

## Security Best Practices

1. **Use strong certificates**: RSA 4096-bit or ECDSA P-384
2. **Regular renewal**: Automate certificate renewal
3. **Secure storage**: Protect private keys with proper permissions
4. **Monitor expiration**: Set up alerts for certificate expiry
5. **Backup certificates**: Include certificates in backup strategy

## Environment Variables

Key certificate-related environment variables:

```bash
# Domain for certificate (must match certificate CN/SAN)
PROSODY_DOMAIN=atl.chat

# Certificate paths (auto-detected by entrypoint)
# /etc/prosody/certs/${PROSODY_DOMAIN}.crt
# /etc/prosody/certs/${PROSODY_DOMAIN}.key
# /etc/prosody/certs/${PROSODY_DOMAIN}/fullchain.pem (Let's Encrypt)
# /etc/prosody/certs/${PROSODY_DOMAIN}/privkey.pem (Let's Encrypt)
```

## Production Deployment

For production deployments:

1. Use wildcard certificates from a trusted CA
2. Set up automated renewal
3. Use certificate monitoring tools
4. Implement certificate rotation procedures
5. Test certificate changes in staging first

The Docker setup automatically detects and uses properly placed certificates, making certificate management seamless across different deployment scenarios.
