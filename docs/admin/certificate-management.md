# 🔐 Certificate Management Guide

This guide provides comprehensive certificate management for Professional Prosody XMPP Server, following official Prosody documentation and security best practices.

## 📋 Overview

Prosody requires SSL/TLS certificates for secure XMPP connections. This guide covers:

- **Certificate Sources**: Let's Encrypt, commercial CAs, self-signed
- **Automatic Discovery**: Prosody's built-in certificate location system
- **Manual Configuration**: Custom certificate paths and advanced setups
- **Security**: Proper permissions, certificate chains, and validation
- **Automation**: Certificate generation, renewal, and import workflows

## 🎯 Quick Reference

### Automatic Certificate Discovery

Prosody automatically searches for certificates in this order:

```
/etc/prosody/certs/
├── {hostname}.crt & {hostname}.key           # Standard format
├── {hostname}/fullchain.pem & {hostname}/privkey.pem  # Let's Encrypt format
└── {service}.crt & {service}.key             # Service certificates
```

### prosodyctl Commands

```bash
# Check certificate configuration
prosodyctl check certs

# Generate self-signed certificate
prosodyctl cert generate atl.chat

# Generate certificate signing request
prosodyctl cert request atl.chat

# Import certificate from external source
prosodyctl --root cert import /path/to/certificates

# Reload certificates without restart
prosodyctl reload
```

## 🏗️ Certificate Sources

### 1. Let's Encrypt (Recommended for Production)

#### Automatic Setup with Certbot

```bash
# Install certbot
sudo apt install certbot

# Generate certificate
sudo certbot certonly --standalone -d your-domain.com -d conference.your-domain.com -d upload.your-domain.com

# Verify certificate location
ls -la /etc/letsencrypt/live/your-domain.com/
```

#### Integration with Prosody

```bash
# Method 1: Using prosodyctl cert import
sudo prosodyctl --root cert import your-domain.com /etc/letsencrypt/live/

# Method 2: Manual copy with proper naming
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem /etc/prosody/certs/your-domain.com.crt
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem /etc/prosody/certs/your-domain.com.key

# Method 3: Let's Encrypt directory structure (automatic discovery)
sudo mkdir -p /etc/prosody/certs/your-domain.com/
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem /etc/prosody/certs/your-domain.com/
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem /etc/prosody/certs/your-domain.com/
```

#### Automated Renewal Hook

```bash
# Create renewal hook
sudo tee /etc/letsencrypt/renewal-hooks/deploy/prosody-reload.sh << 'EOF'
#!/bin/bash
# Import renewed certificates and reload Prosody

# Import certificates using prosodyctl
prosodyctl --root cert import "$RENEWED_LINEAGE/"

# Reload Prosody to use new certificates
prosodyctl reload

# Log the renewal
echo "$(date): Prosody certificates renewed for $RENEWED_DOMAINS" >> /var/log/prosody/cert-renewal.log
EOF

# Make executable
sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/prosody-reload.sh
```

### 2. Commercial Certificate Authorities

#### Generate Certificate Signing Request

```bash
# Using prosodyctl (recommended)
prosodyctl cert request your-domain.com

# Manual OpenSSL method
openssl req -new -newkey rsa:2048 -nodes \
    -keyout your-domain.com.key \
    -out your-domain.com.csr \
    -subj "/CN=your-domain.com"
```

#### Install CA-Provided Certificate

```bash
# Place certificates in Prosody certs directory
sudo cp your-domain.com.crt /etc/prosody/certs/
sudo cp your-domain.com.key /etc/prosody/certs/

# Handle certificate chains (if intermediate certificate provided)
cat your-domain.com.crt intermediate.crt > /etc/prosody/certs/your-domain.com.crt

# Or use fullchain if provided by CA
sudo cp fullchain.crt /etc/prosody/certs/your-domain.com.crt
```

### 3. Self-Signed Certificates (Development Only)

#### Using prosodyctl (Recommended)

```bash
# Generate self-signed certificate
prosodyctl cert generate your-domain.com

# Follow prompts, ensure Common Name matches your domain
```

#### Manual Generation

```bash
# Create self-signed certificate with SAN
openssl req -x509 -newkey rsa:4096 -keyout your-domain.com.key -out your-domain.com.crt \
    -days 365 -nodes \
    -subj "/CN=your-domain.com" \
    -addext "subjectAltName=DNS:your-domain.com,DNS:*.your-domain.com,DNS:conference.your-domain.com,DNS:upload.your-domain.com"
```

## ⚙️ Configuration Methods

### 1. Automatic Certificate Discovery (Recommended)

Prosody automatically finds certificates when using standard naming:

```lua
-- In config/stack/01-transport/tls.cfg.lua
certificates = "certs"  -- Directory for automatic discovery

-- Prosody will automatically find:
-- /etc/prosody/certs/your-domain.com.crt & .key
-- /etc/prosody/certs/your-domain.com/fullchain.pem & privkey.pem
```

### 2. Manual Certificate Paths

#### Per-VirtualHost Configuration

```lua
-- In config/domains/primary/domain.cfg.lua
VirtualHost "your-domain.com"
ssl = {
    key = "/etc/prosody/certs/your-domain.com.key";
    certificate = "/etc/prosody/certs/your-domain.com.crt";
}
```

#### Global SSL Configuration Override

```lua
-- In config/stack/01-transport/tls.cfg.lua
ssl = {
    c2s = {
        key = "/etc/prosody/certs/your-domain.com.key";
        certificate = "/etc/prosody/certs/your-domain.com.crt";
        -- Additional TLS options
        protocol = "tlsv1_2+";
        ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS";
    },
    s2s = {
        key = "/etc/prosody/certs/your-domain.com.key";
        certificate = "/etc/prosody/certs/your-domain.com.crt";
        protocol = "tlsv1_2+";
        verify = "optional";
    }
}
```

### 3. Service-Specific Certificates

#### HTTPS Service Certificate

```lua
-- For HTTP services (BOSH, WebSocket, file upload)
https_certificate = "/etc/prosody/certs/https.crt"
-- Prosody will automatically look for https.key

-- Or per-port configuration
https_certificate = {
    [5281] = "/etc/prosody/certs/web.crt";
    [6281] = "/etc/prosody/certs/admin.crt";
}
```

#### Legacy SSL Certificate

```lua
-- For legacy SSL connections (deprecated but sometimes needed)
legacy_ssl_ssl = {
    certificate = "/etc/prosody/certs/legacy.crt";
    key = "/etc/prosody/certs/legacy.key";
}
```

### 4. Certificate with Passphrase

```lua
-- If your private key is protected with a passphrase
ssl = {
    certificate = "/etc/prosody/certs/your-domain.com.crt";
    key = "/etc/prosody/certs/your-domain.com.key";
    password = "your-secure-passphrase";
}
```

**Security Note**: Including passwords in config files requires careful permission management.

#### Remove Passphrase from Key

```bash
# Backup original key
cp your-domain.com.key your-domain.com.key.orig

# Remove passphrase
openssl rsa -in your-domain.com.key.orig -out your-domain.com.key

# Secure the unprotected key
chmod 600 your-domain.com.key
```

## 🔒 Security and Permissions

### File Permissions

Following Prosody documentation recommendations:

```bash
# Certificate files (public) - readable by prosody
sudo chmod 644 /etc/prosody/certs/*.crt
sudo chown root:prosody /etc/prosody/certs/*.crt

# Private key files - readable only by prosody and root
sudo chmod 640 /etc/prosody/certs/*.key
sudo chown root:prosody /etc/prosody/certs/*.key

# Certificate directory
sudo chmod 750 /etc/prosody/certs/
sudo chown root:prosody /etc/prosody/certs/

# Verify permissions
sudo -u prosody cat /etc/prosody/certs/your-domain.com.key  # Should succeed
sudo -u nobody cat /etc/prosody/certs/your-domain.com.key   # Should fail
```

### Certificate Chain Validation

#### Handle Intermediate Certificates

Many CAs provide intermediate certificates that must be included:

```bash
# Method 1: Concatenate certificates (order matters)
cat your-domain.com.crt intermediate.crt ca-bundle.crt > fullchain.crt
cp fullchain.crt /etc/prosody/certs/your-domain.com.crt

# Method 2: Let's Encrypt provides fullchain.pem automatically
cp /etc/letsencrypt/live/your-domain.com/fullchain.pem /etc/prosody/certs/your-domain.com.crt

# Verify certificate chain
openssl verify -CApath /etc/ssl/certs /etc/prosody/certs/your-domain.com.crt
```

### Trusted Certificate Store

Configure trusted CA certificates for validating remote servers:

```lua
-- In config/stack/01-transport/tls.cfg.lua
ssl = {
    capath = "/etc/ssl/certs";  -- System CA store
    cafile = "/etc/ssl/certs/ca-certificates.crt";  -- CA bundle file
}
```

## 🛠️ Certificate Management Scripts

### Certificate Health Check Script

```bash
#!/bin/bash
# scripts/check-certificates.sh

CERT_DIR="/etc/prosody/certs"
DOMAIN="${PROSODY_DOMAIN:-localhost}"

echo "=== Certificate Health Check ==="

# Check if certificates exist
for cert in "${CERT_DIR}/${DOMAIN}.crt" "${CERT_DIR}/${DOMAIN}/fullchain.pem"; do
    if [[ -f "$cert" ]]; then
        echo "✅ Certificate found: $cert"
        
        # Check expiry (warn if < 30 days)
        if openssl x509 -in "$cert" -noout -checkend 2592000; then
            echo "✅ Certificate valid for >30 days"
        else
            echo "⚠️  Certificate expires within 30 days"
        fi
        
        # Check if it matches domain
        if openssl x509 -in "$cert" -noout -subject | grep -q "$DOMAIN"; then
            echo "✅ Certificate matches domain"
        else
            echo "❌ Certificate domain mismatch"
        fi
        break
    fi
done

# Check private key
for key in "${CERT_DIR}/${DOMAIN}.key" "${CERT_DIR}/${DOMAIN}/privkey.pem"; do
    if [[ -f "$key" ]]; then
        echo "✅ Private key found: $key"
        
        # Check permissions
        if [[ "$(stat -c %a "$key")" == "640" ]]; then
            echo "✅ Private key permissions correct (640)"
        else
            echo "⚠️  Private key permissions should be 640"
        fi
        break
    fi
done

# Check Prosody configuration
echo ""
echo "=== Prosody Certificate Check ==="
prosodyctl check certs
```

### Certificate Installation Script

```bash
#!/bin/bash
# scripts/install-certificates.sh

DOMAIN="${1:-${PROSODY_DOMAIN}}"
CERT_SOURCE="${2}"
CERT_DIR="/etc/prosody/certs"

if [[ -z "$DOMAIN" ]]; then
    echo "Usage: $0 <domain> [certificate_source_path]"
    exit 1
fi

echo "Installing certificates for domain: $DOMAIN"

if [[ -n "$CERT_SOURCE" ]]; then
    echo "Source: $CERT_SOURCE"
    
    # Use prosodyctl cert import for external certificates
    prosodyctl --root cert import "$DOMAIN" "$CERT_SOURCE"
else
    echo "Generating self-signed certificate..."
    
    # Generate self-signed certificate using prosodyctl
    prosodyctl cert generate "$DOMAIN"
fi

# Set proper permissions
echo "Setting certificate permissions..."
find "$CERT_DIR" -name "*.crt" -exec chmod 644 {} \; -exec chown root:prosody {} \;
find "$CERT_DIR" -name "*.pem" -name "*fullchain*" -exec chmod 644 {} \; -exec chown root:prosody {} \;
find "$CERT_DIR" -name "*.key" -exec chmod 640 {} \; -exec chown root:prosody {} \;
find "$CERT_DIR" -name "*privkey*" -exec chmod 640 {} \; -exec chown root:prosody {} \;

# Reload Prosody
echo "Reloading Prosody configuration..."
prosodyctl reload

echo "Certificate installation complete!"
```

## 🔄 Automation and Maintenance

### Automated Certificate Renewal

#### Systemd Timer for Certificate Check

```bash
# Create systemd service
sudo tee /etc/systemd/system/prosody-cert-check.service << 'EOF'
[Unit]
Description=Prosody Certificate Health Check
After=network.target

[Service]
Type=oneshot
User=prosody
ExecStart=/opt/prosody/scripts/check-certificates.sh
EOF

# Create systemd timer
sudo tee /etc/systemd/system/prosody-cert-check.timer << 'EOF'
[Unit]
Description=Run Prosody Certificate Check Daily
Requires=prosody-cert-check.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Enable and start timer
sudo systemctl enable prosody-cert-check.timer
sudo systemctl start prosody-cert-check.timer
```

### Integration with Docker Environment

Update the entrypoint script to check certificates:

```bash
# Add to scripts/entrypoint.sh
setup_ssl_certificates() {
    log_info "Setting up SSL certificates..."

    local cert_file="${PROSODY_CERT_DIR}/${PROSODY_DOMAIN}.crt"
    local key_file="${PROSODY_CERT_DIR}/${PROSODY_DOMAIN}.key"

    # Check for Let's Encrypt format first
    local le_cert="${PROSODY_CERT_DIR}/${PROSODY_DOMAIN}/fullchain.pem"
    local le_key="${PROSODY_CERT_DIR}/${PROSODY_DOMAIN}/privkey.pem"

    if [[ -f "$le_cert" ]] && [[ -f "$le_key" ]]; then
        log_info "Let's Encrypt certificates found"
        cert_file="$le_cert"
        key_file="$le_key"
    elif [[ -f "$cert_file" ]] && [[ -f "$key_file" ]]; then
        log_info "Standard certificates found"
    else
        log_warn "No certificates found, generating self-signed certificate..."
        
        # Use prosodyctl to generate certificate
        prosodyctl cert generate "${PROSODY_DOMAIN}"
        
        log_warn "Self-signed certificate generated. Replace with proper certificates for production."
    fi

    # Verify certificate
    if ! openssl x509 -in "$cert_file" -noout -checkend 86400 >/dev/null 2>&1; then
        log_warn "SSL certificate expires within 24 hours"
    fi

    # Set proper permissions
    chmod 644 "$cert_file" 2>/dev/null || true
    chmod 640 "$key_file" 2>/dev/null || true
    chown root:prosody "$cert_file" "$key_file" 2>/dev/null || true
}
```

## 🧪 Testing and Validation

### Certificate Validation Commands

```bash
# Check certificate details
openssl x509 -in /etc/prosody/certs/your-domain.com.crt -text -noout

# Verify certificate chain
openssl verify -CApath /etc/ssl/certs /etc/prosody/certs/your-domain.com.crt

# Test certificate matches private key
cert_md5=$(openssl x509 -noout -modulus -in your-domain.com.crt | openssl md5)
key_md5=$(openssl rsa -noout -modulus -in your-domain.com.key | openssl md5)
if [[ "$cert_md5" == "$key_md5" ]]; then
    echo "✅ Certificate and key match"
else
    echo "❌ Certificate and key do not match"
fi

# Test TLS connection
openssl s_client -connect your-domain.com:5222 -starttls xmpp -verify_hostname your-domain.com
```

### Prosody-Specific Validation

```bash
# Prosody's built-in certificate checker
prosodyctl check certs

# Test XMPP connection with specific certificate validation
prosodyctl check connectivity your-domain.com

# Monitor certificate usage in logs
tail -f /var/log/prosody/prosody.log | grep -i cert
```

## 📚 Troubleshooting

### Common Certificate Issues

#### "Certificate verification failed"

```bash
# Check certificate chain
openssl verify -verbose -CApath /etc/ssl/certs your-domain.com.crt

# Ensure intermediate certificates are included
openssl x509 -in your-domain.com.crt -text -noout | grep -A 5 "Issuer"
```

#### "No shared cipher"

Usually indicates certificate/key mismatch or wrong format:

```bash
# Verify certificate and key match
openssl x509 -noout -modulus -in your-domain.com.crt | openssl md5
openssl rsa -noout -modulus -in your-domain.com.key | openssl md5

# Check certificate format (should be PEM)
file your-domain.com.crt
```

#### "Permission denied" errors

```bash
# Fix certificate permissions
sudo chmod 644 /etc/prosody/certs/*.crt
sudo chmod 640 /etc/prosody/certs/*.key
sudo chown root:prosody /etc/prosody/certs/*

# Test prosody can read certificates
sudo -u prosody cat /etc/prosody/certs/your-domain.com.key
```

### Configuration Validation

```bash
# Test configuration syntax
prosodyctl check config

# Validate specific certificate settings
grep -r "ssl\|certificate\|tls" /etc/prosody/config/

# Check automatic certificate discovery
ls -la /etc/prosody/certs/
prosodyctl check certs
```

## 🔗 References

- **[Prosody Certificate Documentation](https://prosody.im/doc/certificates)**
- **[Let's Encrypt Integration](https://prosody.im/doc/letsencrypt)**
- **[TLS Configuration](https://prosody.im/doc/configure#ssl_config)**
- **[Security Best Practices](https://prosody.im/doc/security)**

---

*This certificate management guide ensures your XMPP server follows Prosody best practices for certificate handling, security, and automation.*
