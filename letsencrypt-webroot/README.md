# Let's Encrypt Webroot Directory

This directory serves as the webroot for Let's Encrypt HTTP-01 challenge validation.

## Purpose

When using Let's Encrypt with webroot validation, this directory is where:

1. Let's Encrypt places challenge files
2. Your web server serves these files for domain validation
3. Let's Encrypt retrieves the files to verify domain ownership

## Usage

### Automatic Certificate Generation

```bash
# Generate certificates using webroot validation
docker compose --profile letsencrypt run --rm certbot
```

### Manual Certificate Generation

```bash
# Run certbot with webroot validation
docker run --rm -it \
  -v ./certs:/etc/letsencrypt \
  -v ./letsencrypt-webroot:/var/www/certbot \
  certbot/certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email admin@your-domain.com \
  --agree-tos \
  --no-eff-email \
  -d your-domain.com
```

## Web Server Configuration

If you're using a reverse proxy (Nginx/Apache), configure it to serve this directory:

### Nginx Configuration

```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location /.well-known/acme-challenge/ {
        root /path/to/letsencrypt-webroot;
    }
    
    location / {
        return 301 https://$server_name$request_uri;
    }
}
```

### Apache Configuration

```apache
<VirtualHost *:80>
    ServerName your-domain.com
    DocumentRoot /path/to/letsencrypt-webroot
    
    <Location /.well-known/acme-challenge/>
        Require all granted
    </Location>
    
    Redirect permanent / https://your-domain.com/
</VirtualHost>
```

## Security

- This directory only contains temporary challenge files
- Files are automatically cleaned up after validation
- No sensitive data is stored here
