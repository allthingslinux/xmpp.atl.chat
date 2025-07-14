# DNS Setup Guide

Complete DNS configuration for Professional Prosody XMPP Server, including service delegation and security records.

## Overview

This guide covers all DNS records needed for a production XMPP deployment:

- **SRV Records** - Service delegation (e.g., `@atl.chat` → `xmpp.atl.chat`)
- **A/AAAA Records** - Basic domain resolution
- **DNSSEC** - DNS Security Extensions
- **CAA Records** - Certificate Authority Authorization
- **TLSA Records** - Transport Layer Security Authentication

## 1. Service Delegation with SRV Records

### Use Case: Clean Domain Separation

You want users to have `@atl.chat` addresses but run XMPP services on `xmpp.atl.chat`. This keeps your main domain clean:

- **User addresses**: `user@atl.chat`
- **XMPP server**: `xmpp.atl.chat`
- **Web services**: `xmpp.atl.chat/metrics`, `xmpp.atl.chat/admin`
- **Main domain**: `atl.chat` remains available for other services

### Required SRV Records

Add these records to your `atl.chat` DNS zone:

```dns
; Client-to-server (users connecting)
_xmpp-client._tcp.atl.chat.    3600  IN  SRV  0  5  5222  xmpp.atl.chat.

; Server-to-server (federation)
_xmpp-server._tcp.atl.chat.    3600  IN  SRV  0  5  5269  xmpp.atl.chat.

; Direct TLS client connections (XEP-0368)
_xmpps-client._tcp.atl.chat.   3600  IN  SRV  0  5  5223  xmpp.atl.chat.

; Direct TLS server connections (XEP-0368)
_xmpps-server._tcp.atl.chat.   3600  IN  SRV  0  5  5270  xmpp.atl.chat.
```

### Configuration Changes

Update your environment variables:

```bash
# .env file
PROSODY_DOMAIN=atl.chat                    # Users get @atl.chat addresses
PROSODY_ADMINS=admin@atl.chat             # Admin uses clean domain
LETSENCRYPT_EMAIL=admin@allthingslinux.org # Certificate notifications
```

### A Record for Target

Ensure `xmpp.atl.chat` has an A record pointing to your server:

```dns
; A record for the actual server
xmpp.atl.chat.    3600  IN  A     YOUR.SERVER.IP.ADDRESS

; AAAA record if you have IPv6
xmpp.atl.chat.    3600  IN  AAAA  YOUR:SERVER:IPV6:ADDRESS
```

### Subdomain Services

For MUC (Multi-User Chat) and other components:

```dns
; MUC service delegation
_xmpp-server._tcp.muc.atl.chat.         3600  IN  SRV  0  5  5269  xmpp.atl.chat.

; Upload service (if using separate subdomain)
_xmpp-server._tcp.upload.atl.chat.      3600  IN  SRV  0  5  5269  xmpp.atl.chat.
```

### Verification

Test your SRV records:

```bash
# Check client SRV record
dig SRV _xmpp-client._tcp.atl.chat

# Check server SRV record  
dig SRV _xmpp-server._tcp.atl.chat

# Test with Prosody's built-in checker
prosodyctl check dns atl.chat
```

## 2. DNSSEC Configuration

### What is DNSSEC?

DNSSEC provides cryptographic authentication for DNS responses, preventing DNS spoofing attacks.

### Setup Steps

1. **Enable DNSSEC at your DNS provider**
   - Most major providers (Cloudflare, Route53, etc.) support DNSSEC
   - Enable DNSSEC in your DNS management interface
   - Your provider will generate DS records

2. **Configure DS records at your domain registrar**
   - Copy the DS records from your DNS provider
   - Add them to your domain registrar's DNS settings

### Verification

```bash
# Check if DNSSEC is working
dig +dnssec your-domain.com

# Should show RRSIG records if DNSSEC is enabled
dig +dnssec +multi your-domain.com
```

## 3. CAA Records

### What are CAA Records?

CAA (Certificate Authority Authorization) records specify which Certificate Authorities are allowed to issue certificates for your domain.

### Required CAA Records

```dns
; Basic CAA record for Let's Encrypt
your-domain.com. CAA 0 issue "letsencrypt.org"

; Report violations to your abuse contact
your-domain.com. CAA 0 iodef "mailto:abuse@your-domain.com"

; Optional: Restrict to specific account (if supported by CA)
your-domain.com. CAA 0 issuewild "letsencrypt.org; accounturi=https://acme-v02.api.letsencrypt.org/acme/acct/YOUR_ACCOUNT_ID"
```

### Setup Steps

1. **Determine your Certificate Authority**
   - Let's Encrypt: `letsencrypt.org`
   - DigiCert: `digicert.com`
   - Sectigo: `sectigo.com`

2. **Add CAA records to your DNS**

   ```dns
   # Replace 'your-domain.com' with your actual domain
   your-domain.com. CAA 0 issue "letsencrypt.org"
   your-domain.com. CAA 0 issuewild "letsencrypt.org"
   your-domain.com. CAA 0 iodef "mailto:admin@your-domain.com"
   ```

### Verification

```bash
# Check CAA records
dig CAA your-domain.com

# Should show your CAA records
```

## 4. TLSA Records

### What are TLSA Records?

TLSA records provide certificate fingerprints for DANE (DNS-based Authentication of Named Entities), allowing clients to verify certificate authenticity.

**Note:** With wildcard certificates (`*.atl.chat`), the same certificate is used for all subdomains, so the TLSA record hash will be the same for all services.

### Required TLSA Records

```dns
; TLSA record for C2S port (5222)
_5222._tcp.your-domain.com. TLSA 3 1 1 <certificate-sha256-hash>

; TLSA record for S2S port (5269)
_5269._tcp.your-domain.com. TLSA 3 1 1 <certificate-sha256-hash>

; TLSA record for HTTPS port (5281) if HTTP services enabled
_5281._tcp.your-domain.com. TLSA 3 1 1 <certificate-sha256-hash>
```

### Setup Steps

1. **Generate certificate fingerprints**

   ```bash
   # Get certificate fingerprint (SHA-256) from wildcard certificate
   docker compose exec xmpp-prosody openssl x509 -in /etc/prosody/certs/live/atl.chat/fullchain.pem -pubkey -noout | \
   openssl pkey -pubin -outform der | \
   openssl dgst -sha256 -binary | \
   xxd -p -u -c 32
   
   # Alternative: From local certificate file
   openssl x509 -in ./certs/atl.chat.crt -pubkey -noout | \
   openssl pkey -pubin -outform der | \
   openssl dgst -sha256 -binary | \
   xxd -p -u -c 32
   ```

2. **Alternative: Use online TLSA generator**
   - <https://www.huque.com/bin/gen_tlsa>
   - Enter your domain and port
   - Copy the generated TLSA record

3. **Add TLSA records to DNS**

   ```dns
   # Example TLSA records (replace with your actual hash)
   _5222._tcp.your-domain.com. TLSA 3 1 1 ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890
   _5269._tcp.your-domain.com. TLSA 3 1 1 ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890
   ```

### TLSA Record Format

- **Usage (3)**: Domain-issued certificate
- **Selector (1)**: Subject Public Key Info
- **Matching Type (1)**: SHA-256 hash

### Verification

```bash
# Check TLSA records
dig TLSA _5222._tcp.your-domain.com
dig TLSA _5269._tcp.your-domain.com

# Test TLSA validation
openssl s_client -connect your-domain.com:5222 -verify_hostname your-domain.com
```

## 4. Complete DNS Zone Example

Here's a complete example of security-enhanced DNS records:

```dns
; Basic domain records
your-domain.com.                IN A     192.0.2.1
your-domain.com.                IN AAAA  2001:db8::1
your-domain.com.                IN MX    10 your-domain.com.

; XMPP SRV records
_xmpp-client._tcp.your-domain.com. IN SRV 5 0 5222 your-domain.com.
_xmpp-server._tcp.your-domain.com. IN SRV 5 0 5269 your-domain.com.

; Security records
your-domain.com.                IN CAA   0 issue "letsencrypt.org"
your-domain.com.                IN CAA   0 iodef "mailto:admin@your-domain.com"
_5222._tcp.your-domain.com.     IN TLSA  3 1 1 ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890
_5269._tcp.your-domain.com.     IN TLSA  3 1 1 ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890

; Additional security (optional)
your-domain.com.                IN TXT   "v=spf1 -all"
_dmarc.your-domain.com.         IN TXT   "v=DMARC1; p=reject; rua=mailto:dmarc@your-domain.com"
```

## 5. Automation Scripts

### Certificate Renewal Hook

Create a script to update TLSA records when certificates are renewed:

```bash
#!/bin/bash
# /opt/xmpp.atl.chat/scripts/update-tlsa-records.sh
# Hook script to update TLSA records after certificate renewal

DOMAIN="atl.chat"
CERT_PATH="./certs/live/$DOMAIN/fullchain.pem"

# Generate new TLSA hash from wildcard certificate
NEW_HASH=$(docker compose exec xmpp-prosody openssl x509 -in /etc/prosody/certs/live/$DOMAIN/fullchain.pem -pubkey -noout | \
           openssl pkey -pubin -outform der | \
           openssl dgst -sha256 -binary | \
           xxd -p -u -c 32)

# Update DNS (example for Cloudflare API)
# Replace with your DNS provider's API
curl -X PUT "https://api.cloudflare.com/client/v4/zones/ZONE_ID/dns_records/RECORD_ID" \
     -H "Authorization: Bearer YOUR_API_TOKEN" \
     -H "Content-Type: application/json" \
     --data "{\"type\":\"TLSA\",\"name\":\"_5222._tcp.$DOMAIN\",\"content\":\"3 1 1 $NEW_HASH\"}"

echo "TLSA records updated with new certificate hash: $NEW_HASH"
```

## 6. Testing and Validation

### Comprehensive DNS Security Test

```bash
#!/bin/bash
DOMAIN="your-domain.com"

echo "=== DNS Security Validation ==="
echo "Domain: $DOMAIN"
echo

echo "1. DNSSEC Status:"
dig +short +dnssec $DOMAIN | grep -q RRSIG && echo "✅ DNSSEC enabled" || echo "❌ DNSSEC not found"

echo "2. CAA Records:"
dig +short CAA $DOMAIN | grep -q issue && echo "✅ CAA records found" || echo "❌ CAA records missing"

echo "3. TLSA Records:"
dig +short TLSA _5222._tcp.$DOMAIN | grep -q "3 1 1" && echo "✅ C2S TLSA found" || echo "❌ C2S TLSA missing"
dig +short TLSA _5269._tcp.$DOMAIN | grep -q "3 1 1" && echo "✅ S2S TLSA found" || echo "❌ S2S TLSA missing"

echo "4. XMPP SRV Records:"
dig +short SRV _xmpp-client._tcp.$DOMAIN | grep -q 5222 && echo "✅ C2S SRV found" || echo "❌ C2S SRV missing"
dig +short SRV _xmpp-server._tcp.$DOMAIN | grep -q 5269 && echo "✅ S2S SRV found" || echo "❌ S2S SRV missing"
```

## 7. Common DNS Providers

### Cloudflare

- DNSSEC: Available in DNS settings
- CAA/TLSA: Supported via dashboard or API
- API: Full automation support

### AWS Route53

- DNSSEC: Supported with KSK management
- CAA/TLSA: Full support
- API: CloudFormation/Terraform compatible

### Google Cloud DNS

- DNSSEC: Supported with managed keys
- CAA/TLSA: Full support
- API: Full automation support

### Traditional Registrars

- DNSSEC: Usually supported
- CAA/TLSA: Check with provider
- API: Limited automation

## 8. Monitoring and Maintenance

### Regular Checks

1. **DNSSEC validation** - Monthly
2. **CAA record accuracy** - When changing CAs
3. **TLSA record updates** - When renewing certificates
4. **SRV record functionality** - Quarterly

### Automated Monitoring

- Set up monitoring for DNS record changes
- Alert on DNSSEC validation failures
- Monitor certificate expiration dates
- Test TLSA record validation regularly

## Next Steps

1. **Choose your DNS provider** that supports all required record types
2. **Enable DNSSEC** at your DNS provider and registrar
3. **Add CAA records** for your certificate authority
4. **Generate and add TLSA records** for your certificates
5. **Set up automation** for certificate renewal
6. **Test everything** using the validation scripts
7. **Monitor regularly** to ensure continued security

## 9. Integration with Wildcard Certificate Setup

This DNS configuration works seamlessly with the wildcard Cloudflare certificate setup:

### Certificate Generation

```bash
# 1. Configure Cloudflare API
cp examples/cloudflare-credentials.ini.example cloudflare-credentials.ini
# Edit with your Cloudflare API token

# 2. Generate wildcard certificate
docker compose --profile letsencrypt run --rm certbot

# 3. Extract TLSA hash for DNS records
docker compose exec xmpp-prosody openssl x509 -in /etc/prosody/certs/live/atl.chat/fullchain.pem -pubkey -noout | \
openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | xxd -p -u -c 32
```

### Automatic Renewal Integration

The certificate renewal script automatically handles:

- Wildcard certificate renewal via DNS-01 challenges
- Prosody service restart
- TLSA record updates (with additional scripting)

```bash
# Set up automatic renewal
(crontab -l 2>/dev/null; echo "0 3 * * * /opt/xmpp.atl.chat/scripts/renew-certificates.sh") | crontab -
```

Remember to update TLSA records whenever you renew your SSL certificates!
