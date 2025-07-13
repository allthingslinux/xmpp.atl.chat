# WebSocket Configuration Guide

This guide covers WebSocket configuration for Prosody XMPP server based on the official Prosody WebSocket documentation. WebSocket support provides bi-directional XMPP communication with less overhead than BOSH, ideal for web-based XMPP clients.

## Overview

XMPP over WebSocket is a method of providing bi-directional communication, similar to BOSH but with less overhead. It's implemented via RFC 7395 and supported natively by Prosody through the `mod_websocket` module.

## Basic Configuration

### Module Activation

WebSocket support is provided by `mod_websocket`, which should be enabled in your configuration:

```lua
-- In config/stack/07-interfaces/websocket.cfg.lua or modules_enabled
modules_enabled = {
    "websocket", -- RFC 7395: WebSocket XMPP Subprotocol
    -- ... other modules
}
```

### Default Endpoints

With default HTTP settings, WebSocket connection endpoints are available at:

- **HTTP WebSocket**: `ws://example.com:5280/xmpp-websocket`
- **HTTPS WebSocket**: `wss://example.com:5281/xmpp-websocket`

### Custom Endpoint Configuration

You can customize the WebSocket path using HTTP path configuration:

```lua
-- Custom WebSocket path
http_paths = {
    websocket = "/xmpp-websocket", -- Standard path (default)
    -- Alternative: websocket = "/websocket", -- Shorter path
}
```

## Network Timeout Settings

### Critical: network_settings.read_timeout

Prosody 0.12.0+ defaults to a `network_settings.read_timeout` of 840 seconds (14 minutes). This setting is critical for proxy configurations:

```lua
-- In config/stack/01-transport/connections.cfg.lua
network_settings = {
    read_timeout = 840, -- 14 minutes (official Prosody 0.12.0+ default)
}
```

**Important**: All reverse proxy timeouts must be set **HIGHER** than this value to prevent premature connection closure.

## Reverse Proxy Configuration

### Nginx Configuration

Complete Nginx configuration for WebSocket proxying:

```nginx
# /etc/nginx/sites-available/your-domain.com
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    # SSL configuration
    ssl_certificate /path/to/your/certificate.crt;
    ssl_certificate_key /path/to/your/private.key;

    # WebSocket location
    location /xmpp-websocket {
        # Proxy settings
        proxy_pass http://localhost:5280/xmpp-websocket;
        proxy_http_version 1.1;
        
        # WebSocket upgrade headers
        proxy_set_header Connection "Upgrade";
        proxy_set_header Upgrade $http_upgrade;
        
        # Essential headers for Prosody
        proxy_set_header Host $host;                    # For VirtualHost mapping
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # Real IP detection
        proxy_set_header X-Forwarded-Proto $scheme;    # Protocol detection
        
        # CRITICAL: Timeout must be > network_settings.read_timeout (840s)
        proxy_read_timeout 900s;  # 15 minutes (MUST be > 840s)
        proxy_send_timeout 900s;
        
        # Optional optimizations
        proxy_buffering off;
        proxy_cache off;
    }

    # Optional: Redirect HTTP to HTTPS
    location /xmpp-websocket-http {
        return 301 https://$server_name$request_uri;
    }
}

# HTTP server (optional redirect)
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

### Apache Configuration

Complete Apache configuration for WebSocket proxying:

```apache
# /etc/apache2/sites-available/your-domain.com.conf
<VirtualHost *:443>
    ServerName your-domain.com
    
    # SSL configuration
    SSLEngine on
    SSLCertificateFile /path/to/your/certificate.crt
    SSLCertificateKeyFile /path/to/your/private.key
    
    # Enable required modules
    <IfModule mod_proxy.c>
        <IfModule mod_proxy_wstunnel.c>
            # CRITICAL: Timeout must be > network_settings.read_timeout (840s)
            ProxyTimeout 900  # 15 minutes (MUST be > 840s)
            
            # WebSocket location
            <Location "/xmpp-websocket">
                ProxyPass "ws://localhost:5280/xmpp-websocket"
                
                # Optional: Set headers for better logging
                ProxyPreserveHost On
                ProxyPassReverse "ws://localhost:5280/xmpp-websocket"
            </Location>
        </IfModule>
    </IfModule>
</VirtualHost>

# HTTP redirect (optional)
<VirtualHost *:80>
    ServerName your-domain.com
    Redirect permanent / https://your-domain.com/
</VirtualHost>
```

## VirtualHost Mapping

### Host Header Forwarding

The `Host` header must be forwarded to allow Prosody to find the correct VirtualHost:

```nginx
# In Nginx
proxy_set_header Host $host;
```

```apache
# In Apache (automatic with ProxyPreserveHost On)
ProxyPreserveHost On
```

### Multiple Domain Configuration

For multi-domain setups, ensure each domain has proper WebSocket configuration:

```lua
-- config/domains/primary/domain.cfg.lua
VirtualHost "domain1.com"
http_host = "domain1.com"
http_external_url = "https://domain1.com/"

-- config/domains/secondary/domain.cfg.lua  
VirtualHost "domain2.com"
http_host = "domain2.com"
http_external_url = "https://domain2.com/"
```

## Security Configuration

### Trusted Proxies

Configure trusted proxies for real IP detection:

```lua
-- config/stack/07-interfaces/http.cfg.lua
trusted_proxies = {
    "127.0.0.1",        -- Local
    "::1",              -- Local IPv6
    "192.168.1.0/24",   -- Local network (example)
    "10.0.0.0/8",       -- Private network (example)
    "172.16.0.0/12",    -- Private network (example)
}
```

### Proxy Security Settings

Enable proxy security for HTTPS proxy setups:

```lua
-- Set to true if behind HTTPS proxy
consider_websocket_secure = true
```

### CORS Configuration

Disable CORS for WebSocket security (default):

```lua
-- config/stack/07-interfaces/http.cfg.lua
http_cors_override = {
    websocket = {
        enabled = false, -- Disable CORS for WebSocket security
    },
}
```

## Advanced Configuration

### Connection Limits

Configure WebSocket-specific connection limits:

```lua
-- config/stack/07-interfaces/websocket.cfg.lua
websocket_config = {
    -- Frame and buffer limits
    websocket_frame_buffer_limit = 2 * 1024 * 1024, -- 2MB frame buffer
    websocket_frame_fragment_limit = 8, -- Maximum fragments per frame
    websocket_max_frame_size = 1024 * 1024, -- 1MB max frame size
    
    -- Connection settings
    websocket_ping_interval = 30, -- Send ping every 30 seconds
    websocket_pong_timeout = 10, -- Wait 10 seconds for pong response
    websocket_close_timeout = 5, -- Wait 5 seconds for close confirmation
}
```

### Origin Validation

Enable origin checking for additional security:

```lua
websocket_origin_check = true
allowed_origins = {
    "https://yourwebclient.com",
    "https://app.yourdomain.com",
}
```

### Custom Response for HTTP GET

Configure custom response when someone accesses the WebSocket endpoint via HTTP:

```lua
websocket_get_response_text = "XMPP WebSocket endpoint - point your XMPP client here"
websocket_get_response_body = [[
<!DOCTYPE html>
<html>
<head>
    <title>XMPP WebSocket Endpoint</title>
</head>
<body>
    <h1>XMPP WebSocket Endpoint</h1>
    <p>This is an XMPP WebSocket endpoint.</p>
    <p>Point your XMPP client to: <code>wss://yourdomain.com/xmpp-websocket</code></p>
</body>
</html>
]]
```

## Client Configuration Examples

### JavaScript Web Client

```javascript
// Connect to WebSocket endpoint
const connection = new WebSocket('wss://yourdomain.com/xmpp-websocket');

// Handle connection events
connection.onopen = function(event) {
    console.log('WebSocket connected');
    // Start XMPP stream
    connection.send('<?xml version="1.0"?><stream:stream to="yourdomain.com" xmlns="jabber:client" xmlns:stream="http://etherx.jabber.org/streams" version="1.0">');
};

connection.onmessage = function(event) {
    console.log('Received:', event.data);
    // Handle XMPP stanzas
};

connection.onerror = function(error) {
    console.error('WebSocket error:', error);
};

connection.onclose = function(event) {
    console.log('WebSocket closed:', event.code, event.reason);
};
```

### Strophe.js Configuration

```javascript
// Using Strophe.js with WebSocket
const connection = new Strophe.Connection('wss://yourdomain.com/xmpp-websocket');

connection.connect('user@yourdomain.com', 'password', function(status) {
    if (status === Strophe.Status.CONNECTED) {
        console.log('Connected via WebSocket');
    } else if (status === Strophe.Status.DISCONNECTED) {
        console.log('Disconnected');
    }
});
```

## Monitoring and Troubleshooting

### Connection Testing

Test WebSocket connectivity:

```bash
# Test WebSocket endpoint
curl -H "Connection: Upgrade" \
     -H "Upgrade: websocket" \
     -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
     -H "Sec-WebSocket-Version: 13" \
     http://yourdomain.com:5280/xmpp-websocket

# Expected response: HTTP 101 Switching Protocols
```

### Log Analysis

Enable WebSocket logging for troubleshooting:

```lua
-- Enable debug logging for WebSocket
log = {
    { levels = { min = "debug" }, to = "file", filename = "/var/log/prosody/websocket.log" };
}

-- Module-specific logging
modules_enabled = {
    "websocket",
    -- Enable for debugging:
    -- "log_auth",
    -- "log_events",
}
```

### Common Issues and Solutions

#### 1. Connection Timeout Issues

**Problem**: WebSocket connections timing out

**Solution**: Check proxy timeout configuration:

```nginx
# Ensure proxy timeout > network_settings.read_timeout (840s)
proxy_read_timeout 900s;
```

#### 2. VirtualHost Not Found

**Problem**: Prosody can't find the correct VirtualHost

**Solution**: Ensure Host header is forwarded:

```nginx
proxy_set_header Host $host;
```

#### 3. Real IP Not Detected

**Problem**: Prosody logs show proxy IP instead of client IP

**Solution**: Configure trusted proxies and X-Forwarded-For:

```lua
trusted_proxies = { "proxy.ip.address" }
```

```nginx
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

#### 4. CORS Errors

**Problem**: Web client shows CORS errors

**Solution**: Enable CORS for WebSocket (security consideration):

```lua
http_cors_override = {
    websocket = {
        enabled = true,
        origins = { "https://yourwebclient.com" }, -- Restrict to your domains
    },
}
```

## Performance Optimization

### Connection Pooling

Configure connection pooling for better performance:

```lua
-- config/stack/01-transport/connections.cfg.lua
connection_pooling = {
    enabled = true,
    max_pool_size = 50,
    pool_timeout = 300, -- 5 minutes
}
```

### Buffer Optimization

Optimize buffers for WebSocket traffic:

```lua
-- Adjust based on your traffic patterns
websocket_frame_buffer_limit = 4 * 1024 * 1024 -- 4MB for high-traffic
websocket_max_frame_size = 2 * 1024 * 1024 -- 2MB for large messages
```

### Mobile Client Optimization

Special settings for mobile clients:

```lua
-- Longer ping intervals for battery saving
websocket_ping_interval = 60 -- 1 minute for mobile clients
websocket_pong_timeout = 15 -- Longer timeout for mobile networks
```

## Security Best Practices

### 1. Use HTTPS/WSS Only in Production

```lua
-- Redirect HTTP to HTTPS
https_redirect = true
```

### 2. Restrict Origins

```lua
-- Only allow specific origins
allowed_origins = {
    "https://yourapp.com",
    "https://webapp.yourdomain.com",
}
```

### 3. Enable Rate Limiting

```lua
-- WebSocket-specific rate limiting
limits = {
    websocket = {
        rate = "10kb/s",
        burst = "50kb",
    },
}
```

### 4. Monitor Connections

```lua
-- Enable connection monitoring
connection_monitoring = {
    enabled = true,
    track_latency = true,
    track_bandwidth = true,
    max_error_rate = 0.05, -- Alert at 5% error rate
}
```

## Complete Example Configuration

Here's a complete configuration example for a production WebSocket setup:

```lua
-- config/stack/07-interfaces/websocket.cfg.lua
modules_enabled = {
    "websocket",
    "http",
    "limits",
}

-- HTTP configuration
http_ports = { 5280 }
https_ports = { 5281 }
http_paths = {
    websocket = "/xmpp-websocket",
}

-- WebSocket configuration
websocket_frame_buffer_limit = 2 * 1024 * 1024
websocket_ping_interval = 30
websocket_pong_timeout = 10
consider_websocket_secure = true -- If behind HTTPS proxy

-- Security
trusted_proxies = { "127.0.0.1", "::1", "proxy.ip.here" }
websocket_origin_check = true
allowed_origins = { "https://yourapp.com" }

-- Rate limiting
limits = {
    websocket = {
        rate = "10kb/s",
        burst = "50kb",
    },
}
```

## References

- [Official Prosody WebSocket Documentation](https://prosody.im/doc/websocket)
- [RFC 7395: An Extensible Messaging and Presence Protocol (XMPP) Subprotocol for WebSocket](https://tools.ietf.org/html/rfc7395)
- [Nginx WebSocket Documentation](https://nginx.org/en/docs/http/websocket.html)
- [Apache mod_proxy_wstunnel Documentation](https://httpd.apache.org/docs/current/mod/mod_proxy_wstunnel.html)
