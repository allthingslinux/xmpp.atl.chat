# MUC Pastebin Configuration Guide

This guide covers the configuration and usage of the automatic pastebin feature for Multi-User Chat (MUC) rooms, which converts long messages into pastebin URLs to prevent chat spam.

## Overview

The MUC pastebin feature automatically intercepts long messages posted to chat rooms and converts them into URLs pointing to a built-in pastebin server. This prevents:

- Chat windows being flooded with long logs or code snippets
- Reduced readability due to excessive scrolling
- Bandwidth waste from repeatedly sending large messages
- Poor user experience in busy chat rooms

## How It Works

When someone posts a message that exceeds the configured thresholds:

1. **Prosody intercepts** the message before it reaches other users
2. **Creates a pastebin entry** with a randomly generated URL
3. **Replaces the original message** with the pastebin URL
4. **Other users see** just the URL instead of the long content
5. **Clicking the URL** shows the full message content in a web interface

## Quick Start

### Basic Configuration

The server comes with sensible defaults for pastebin functionality. To customize settings, add these to your `.env` file:

```bash
# Convert messages longer than 800 characters to pastebin
PROSODY_PASTEBIN_THRESHOLD=800

# Convert messages with more than 6 lines to pastebin
PROSODY_PASTEBIN_LINE_THRESHOLD=6

# Keep pastes for 1 week
PROSODY_PASTEBIN_EXPIRE_AFTER=168
```

### Accessing Pastebin

Pastebin URLs are available at: `http://your-domain:5280/pastebin/`

Example pastebin URL: `http://xmpp.atl.chat:5280/pastebin/abc123def456`

## Configuration Options

### Core Settings

#### `PROSODY_PASTEBIN_THRESHOLD`

- **Default**: `800`
- **Range**: `300-2000`
- **Description**: Maximum message length (characters) before pastebin conversion

```bash
# Conservative setting (shorter messages become pastebins)
PROSODY_PASTEBIN_THRESHOLD=500

# Balanced setting (default)
PROSODY_PASTEBIN_THRESHOLD=800

# Permissive setting (only very long messages become pastebins)
PROSODY_PASTEBIN_THRESHOLD=1500
```

#### `PROSODY_PASTEBIN_LINE_THRESHOLD`

- **Default**: `6`
- **Range**: `3-10`
- **Description**: Maximum number of lines before pastebin conversion

```bash
# Strict line limit
PROSODY_PASTEBIN_LINE_THRESHOLD=4

# Balanced line limit (default)
PROSODY_PASTEBIN_LINE_THRESHOLD=6

# Permissive line limit
PROSODY_PASTEBIN_LINE_THRESHOLD=8
```

#### `PROSODY_PASTEBIN_EXPIRE_AFTER`

- **Default**: `168` (1 week)
- **Values**: Hours, or `0` for permanent
- **Description**: How long pastes are stored before deletion

```bash
# Short retention (1 day)
PROSODY_PASTEBIN_EXPIRE_AFTER=24

# Medium retention (1 week, default)
PROSODY_PASTEBIN_EXPIRE_AFTER=168

# Long retention (1 month)
PROSODY_PASTEBIN_EXPIRE_AFTER=720

# Permanent storage (not recommended)
PROSODY_PASTEBIN_EXPIRE_AFTER=0
```

### Advanced Settings

#### `PROSODY_PASTEBIN_TRIGGER`

- **Default**: Not set
- **Examples**: `!paste`, `\`\`\``,`/paste`
- **Description**: Force pastebin regardless of message length

```bash
# Use !paste to force pastebin
PROSODY_PASTEBIN_TRIGGER=!paste

# Use markdown code blocks to force pastebin
PROSODY_PASTEBIN_TRIGGER=```

# Use slash command style
PROSODY_PASTEBIN_TRIGGER=/paste
```

**Usage Example:**

```
User types: "!paste This short message will become a pastebin"
Result: Message is converted to pastebin URL regardless of length
```

#### `PROSODY_PASTEBIN_PATH`

- **Default**: `/pastebin/`
- **Examples**: `/paste/`, `/$host-paste/`, `/p/`
- **Description**: Customize the URL path for pastebin service

```bash
# Short path
PROSODY_PASTEBIN_PATH=/p/

# Host-specific path
PROSODY_PASTEBIN_PATH=/$host-paste/

# Custom path
PROSODY_PASTEBIN_PATH=/code-share/
```

## Client Usage

### Automatic Conversion

Users don't need to do anything special - long messages are automatically converted:

#### Example Scenario

```
User posts: "Here's the error log:\n[500 lines of log output]"
Other users see: "Here's the error log: http://server:5280/pastebin/abc123"
```

### Manual Trigger

If a trigger is configured, users can force pastebin for any message:

```bash
# With PROSODY_PASTEBIN_TRIGGER=!paste
User types: "!paste SELECT * FROM users WHERE active = 1;"
Result: Short SQL becomes a pastebin for better formatting
```

### Viewing Pastebins

1. **Click the pastebin URL** in the chat
2. **View in web browser** - content is displayed with:
   - Syntax highlighting (if applicable)
   - Line numbers
   - Copy-to-clipboard functionality
   - Expiration information

### Common Use Cases

#### Code Sharing

```
User: "Here's the fix for the bug:"
User: "!paste
function fixBug() {
    // Implementation here
    return result;
}"
Result: Code becomes formatted pastebin with syntax highlighting
```

#### Log Analysis

```
User: "Check this error log:"
[Long log automatically becomes pastebin]
Result: Clean chat with clickable log URL
```

#### Configuration Files

```
User: "My prosody.cfg.lua settings:"
[Config file automatically becomes pastebin]
Result: Formatted configuration with line numbers
```

## Client Compatibility

### Supported Clients

All XMPP clients that support MUC will work with pastebin:

#### **Conversations (Android)**

- ✅ Automatically converts long messages
- ✅ Displays pastebin URLs as clickable links
- ✅ Opens pastebins in built-in browser

#### **Gajim (Desktop)**

- ✅ Full pastebin support
- ✅ Clickable URLs open in default browser
- ✅ Preview functionality for some content types

#### **Siskin IM (iOS)**

- ✅ Pastebin conversion works automatically
- ✅ URLs open in Safari or in-app browser
- ✅ Good integration with iOS sharing

#### **Web Clients (Converse.js, etc.)**

- ✅ Native browser integration
- ✅ Excellent pastebin viewing experience
- ✅ Copy-paste functionality

### Client Configuration

No special client configuration is required - pastebin works automatically with all XMPP clients.

## Monitoring and Maintenance

### Storage Usage

Monitor pastebin storage usage:

```bash
# Check pastebin storage directory
docker compose exec xmpp-prosody du -sh /var/lib/prosody/pastebin/

# Count active pastes
docker compose exec xmpp-prosody find /var/lib/prosody/pastebin/ -name "*.txt" | wc -l

# Check oldest pastes
docker compose exec xmpp-prosody find /var/lib/prosody/pastebin/ -name "*.txt" -printf '%T+ %p\n' | sort | head -10
```

### Performance Monitoring

Key metrics to monitor:

```bash
# HTTP requests to pastebin service
curl -s http://localhost:5280/metrics | grep http_requests | grep pastebin

# Pastebin creation rate
curl -s http://localhost:5280/metrics | grep pastebin_created

# Storage cleanup metrics
curl -s http://localhost:5280/metrics | grep pastebin_expired
```

### Manual Cleanup

Force cleanup of expired pastes:

```bash
# Clean up expired pastes manually
docker compose exec xmpp-prosody prosodyctl mod_pastebin cleanup

# Remove all pastes (emergency cleanup)
docker compose exec xmpp-prosody rm -rf /var/lib/prosody/pastebin/*
```

## Security Considerations

### Privacy and Access Control

- **Random URLs**: Pastebin URLs are randomly generated and difficult to guess
- **Room-only Access**: Only room participants can create pastes
- **No Public Listing**: Pastes cannot be discovered without the direct URL
- **Automatic Expiry**: Pastes are automatically deleted after expiration

### Content Security

```bash
# Recommended security settings
PROSODY_PASTEBIN_EXPIRE_AFTER=168  # Don't store permanently
PROSODY_PASTEBIN_THRESHOLD=800     # Reasonable threshold
```

### Network Security

- Pastebin service runs on HTTP (port 5280) by default
- Consider using HTTPS proxy for production:

```nginx
# Nginx configuration for HTTPS pastebin
location /pastebin/ {
    proxy_pass http://prosody:5280/pastebin/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

## Troubleshooting

### Common Issues

#### Messages Not Converting to Pastebin

1. **Check thresholds**:

   ```bash
   # Verify your settings
   echo "Threshold: $PROSODY_PASTEBIN_THRESHOLD characters"
   echo "Line threshold: $PROSODY_PASTEBIN_LINE_THRESHOLD lines"
   ```

2. **Verify module is loaded**:

   ```bash
   docker compose logs prosody | grep -i pastebin
   ```

3. **Test with known long message**:
   - Post a message with 1000+ characters
   - Should automatically become pastebin URL

#### Pastebin URLs Not Accessible

1. **Check HTTP service**:

   ```bash
   curl -I http://localhost:5280/pastebin/
   ```

2. **Verify port configuration**:

   ```bash
   # Ensure HTTP port is accessible
   docker compose ps prosody
   ```

3. **Check firewall rules**:

   ```bash
   # Ensure port 5280 is open
   sudo ufw status | grep 5280
   ```

#### Pastes Expiring Too Quickly

1. **Check expiry setting**:

   ```bash
   echo "Expiry: $PROSODY_PASTEBIN_EXPIRE_AFTER hours"
   ```

2. **Verify cleanup process**:

   ```bash
   docker compose logs prosody | grep -i "pastebin.*expir"
   ```

#### Trigger Not Working

1. **Verify trigger configuration**:

   ```bash
   echo "Trigger: '$PROSODY_PASTEBIN_TRIGGER'"
   ```

2. **Test trigger syntax**:
   - Message must start with exact trigger string
   - No spaces before trigger
   - Case-sensitive matching

### Debug Commands

```bash
# Check pastebin module status
docker compose exec xmpp-prosody prosodyctl about | grep -i pastebin

# View pastebin configuration
docker compose exec xmpp-prosody prosodyctl config get pastebin

# Test pastebin service manually
curl http://localhost:5280/pastebin/

# Monitor real-time pastebin activity
docker compose logs -f prosody | grep -i pastebin
```

## Performance Tuning

### Storage Optimization

```bash
# Optimize for high-volume rooms
PROSODY_PASTEBIN_THRESHOLD=600     # Lower threshold
PROSODY_PASTEBIN_EXPIRE_AFTER=72   # Shorter retention

# Optimize for low-volume rooms
PROSODY_PASTEBIN_THRESHOLD=1200    # Higher threshold
PROSODY_PASTEBIN_EXPIRE_AFTER=720  # Longer retention
```

### Network Optimization

```bash
# For high-traffic servers, consider CDN or caching
# Add to nginx/apache configuration:
location /pastebin/ {
    expires 1h;
    add_header Cache-Control "public, immutable";
    proxy_pass http://prosody:5280/pastebin/;
}
```

## Advanced Configuration

### Custom URL Paths

```bash
# Organization-specific paths
PROSODY_PASTEBIN_PATH=/company-paste/

# Environment-specific paths
PROSODY_PASTEBIN_PATH=/dev-paste/     # Development
PROSODY_PASTEBIN_PATH=/prod-paste/    # Production
```

### Integration with External Systems

For advanced setups, consider:

- External pastebin services (Pastebin.com API)
- Custom storage backends
- Integration with issue tracking systems
- Automated content analysis

## Related Documentation

- [MUC Archiving Guide](muc-archiving.md) - Message archiving for compliance
- [Monitoring Guide](monitoring.md) - Server monitoring and metrics
- [Security Guide](../admin/security.md) - Security best practices
- [HTTP Services Guide](configuration.md) - General HTTP configuration

## Examples

### Production Configuration

```bash
# High-volume production server
PROSODY_PASTEBIN_THRESHOLD=600
PROSODY_PASTEBIN_LINE_THRESHOLD=5
PROSODY_PASTEBIN_EXPIRE_AFTER=72
PROSODY_PASTEBIN_TRIGGER=```
```

### Development Configuration

```bash
# Development/testing server
PROSODY_PASTEBIN_THRESHOLD=1000
PROSODY_PASTEBIN_LINE_THRESHOLD=8
PROSODY_PASTEBIN_EXPIRE_AFTER=24
PROSODY_PASTEBIN_TRIGGER=!paste
PROSODY_PASTEBIN_PATH=/dev-paste/
```

### Community Server Configuration

```bash
# Community/open server
PROSODY_PASTEBIN_THRESHOLD=800
PROSODY_PASTEBIN_LINE_THRESHOLD=6
PROSODY_PASTEBIN_EXPIRE_AFTER=168
# No trigger (automatic only)
```
