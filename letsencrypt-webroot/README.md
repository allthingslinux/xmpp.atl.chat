# Let's Encrypt Webroot Directory (DEPRECATED)

⚠️ **This directory is no longer needed with the new DNS-01 challenge setup.**

## Migration to DNS-01 Challenges

This setup now uses **Cloudflare DNS-01 challenges** for wildcard certificate support, which is:

- **More secure**: No need to expose port 80 publicly
- **Simpler**: No webroot directory management needed
- **Better coverage**: Wildcard certificates cover all subdomains
- **More reliable**: No dependency on HTTP accessibility

## New Certificate Setup

Use the new DNS-01 approach instead:

```bash
# 1. Configure Cloudflare API
cp cloudflare-credentials.ini.example cloudflare-credentials.ini
# Edit with your Cloudflare API token

# 2. Generate wildcard certificate
docker compose --profile letsencrypt run --rm certbot

# 3. Start the server
docker compose up -d
```

## Legacy Information

This directory was previously used for Let's Encrypt HTTP-01 challenge validation. The HTTP-01 challenge required:

1. **Let's Encrypt placing challenge files** in this directory during domain validation
2. **Prosody serving these files** via HTTP on port 5280
3. **Let's Encrypt retrieving the files** to verify domain ownership

**This approach had limitations:**

- Required port 80 to be publicly accessible
- Could not generate wildcard certificates
- More complex setup and maintenance
- Security concerns with HTTP exposure

## Removal

This directory will be removed in a future version. The new DNS-01 approach is recommended for all deployments.
