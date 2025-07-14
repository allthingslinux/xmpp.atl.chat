# Let's Encrypt Webroot Directory

This directory serves as the webroot for Let's Encrypt HTTP-01 challenge validation in the Docker setup.

## Purpose

When using Let's Encrypt with webroot validation, this directory is where:

1. **Let's Encrypt places challenge files** during domain validation
2. **Prosody serves these files** via HTTP on port 5280
3. **Let's Encrypt retrieves the files** to verify domain ownership

## How It Works

The Docker setup automatically:

1. **Mounts this directory** to `/var/www/certbot` inside containers
2. **Configures Prosody** to serve `/.well-known/acme-challenge/` from this location
3. **Runs certbot** with webroot validation using this directory

## Usage

### Generate Certificates

```bash
# Set your domain in .env file
PROSODY_DOMAIN=atl.chat

# Generate certificates (uses this webroot automatically)
docker compose --profile letsencrypt run --rm certbot
```

### Directory Structure During Validation

```
letsencrypt-webroot/
└── .well-known/
    └── acme-challenge/
        └── [challenge-token]    # Temporary file created by certbot
```

## Configuration

The setup is fully automated via:

- **Docker Compose**: Mounts `./letsencrypt-webroot:/var/www/certbot`
- **Prosody Config**: Serves `/.well-known/acme-challenge/` from `/var/www/certbot/.well-known/acme-challenge/`
- **Certbot**: Uses `--webroot-path=/var/www/certbot` for challenges

## Requirements

- **Port 80 must be open** for HTTP-01 challenges
- **Domain must resolve** to your server's IP address
- **Directory must be writable** by the certbot container

## Security

- This directory only contains **temporary challenge files**
- Files are **automatically cleaned up** after validation
- **No sensitive data** is stored here
- Directory is **ignored by git** (see `.gitignore`)

---

**Note**: This directory is essential for Let's Encrypt certificate generation. Do not delete it.
