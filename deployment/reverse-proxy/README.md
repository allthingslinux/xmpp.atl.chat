# Reverse Proxy Configuration

This directory contains reverse proxy configurations for production deployments of the Prosody XMPP server.

## When to Use Reverse Proxy

Use a reverse proxy when you want to:

1. **Run on standard ports** (80/443) instead of Prosody's default ports (5280/5281)
2. **Serve static files efficiently** - nginx/Apache can serve files faster than Prosody
3. **Handle SSL termination** - Let the reverse proxy manage SSL/TLS certificates
4. **Add security features** - Rate limiting, DDoS protection, security headers
5. **Load balancing** - Distribute traffic across multiple Prosody instances
6. **Integration** - Run other web services on the same server

## Architecture

```
Client → Reverse Proxy (80/443) → Prosody Container (5280/5281)
```

## Available Configurations

### nginx/nginx-websocket.conf

- **Purpose**: nginx reverse proxy configuration
- **Features**: WebSocket support, SSL termination, security headers
- **Best for**: High-performance deployments

### apache/apache-websocket.conf  

- **Purpose**: Apache reverse proxy configuration
- **Features**: WebSocket support, SSL termination, security headers
- **Best for**: Environments already using Apache

## Setup Instructions

1. **Choose your reverse proxy** (nginx or Apache)
2. **Copy the configuration** to your reverse proxy's configuration directory
3. **Update domains and paths** in the configuration file
4. **Configure SSL certificates** (Let's Encrypt recommended)
5. **Start/reload your reverse proxy**
6. **Update firewall rules** to allow ports 80/443

## Without Reverse Proxy

If you don't need a reverse proxy, the Docker setup works perfectly on its own:

```bash
# Direct access to Prosody
https://your-domain.com:5281/admin
wss://your-domain.com:5281/xmpp-websocket
```

## With Reverse Proxy

After setting up the reverse proxy:

```bash
# Standard ports via reverse proxy
https://your-domain.com/admin
wss://your-domain.com/xmpp-websocket
```

## Security Considerations

- **Keep reverse proxy updated** - Security patches are critical
- **Configure rate limiting** - Prevent abuse and DDoS attacks
- **Use strong SSL settings** - Modern TLS versions and cipher suites
- **Monitor logs** - Watch for suspicious activity
- **Firewall rules** - Block direct access to Prosody ports from external networks
