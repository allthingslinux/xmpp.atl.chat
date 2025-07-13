# 🔍 Service Discovery (XEP-0030)

Service Discovery allows XMPP clients to automatically discover available services and features on your server. This guide covers configuration and usage of `mod_disco` in your Prosody XMPP server.

## 📋 Overview

Service Discovery (XEP-0030) enables:

- **Automatic service detection** by XMPP clients
- **Feature advertisement** (what your server supports)
- **Component discovery** (MUC, file upload, proxies, etc.)
- **External service integration** (gateways, bridges, etc.)

## ⚙️ Configuration

All service discovery settings are configured via environment variables in your `.env` file.

### Default Services

Your server automatically advertises these built-in services:

| Service | JID | Description |
|---------|-----|-------------|
| **Multi-User Chat** | `muc.yourdomain.com` | Group chat rooms (XEP-0045) |
| **File Upload** | `upload.yourdomain.com` | HTTP file sharing (XEP-0363) |
| **File Transfer Proxy** | `proxy.yourdomain.com` | SOCKS5 proxy (XEP-0065) |

### Admin Visibility

```bash
# Whether to expose admin accounts in service discovery
# Default: false (recommended for privacy and security)
PROSODY_DISCO_EXPOSE_ADMINS=false

# Set to true if you want abuse reporters to easily identify administrators
# PROSODY_DISCO_EXPOSE_ADMINS=true
```

**Security Note**: Enabling admin exposure makes it easier for users to report abuse, but also makes admin accounts more visible to potential attackers.

### Custom Services

Add external services that your users can discover:

```bash
# Format: "jid1,name1;jid2,name2"
PROSODY_DISCO_ITEMS="irc.example.com,IRC Gateway;channels.example.net,Public Channels"
```

#### Examples

**IRC Gateway Integration:**

```bash
PROSODY_DISCO_ITEMS="irc.yourserver.com,IRC Gateway to Freenode"
```

**Public Conference Servers:**

```bash
PROSODY_DISCO_ITEMS="conference.jabber.org,Public Conference Server;chat.jabberfr.org,French Chat Server"
```

**Multiple Services:**

```bash
PROSODY_DISCO_ITEMS="irc.example.com,IRC Gateway;sms.example.com,SMS Gateway;weather.example.com,Weather Bot"
```

## 🖥️ Client Usage

### Desktop Clients

**Gajim:**

1. Go to **Accounts** → **Discover Services**
2. Enter your domain name
3. Browse available services automatically

**Conversations (Android):**

1. Open **Settings** → **Expert Settings**
2. **Server Info** shows discovered services
3. Services appear automatically in relevant contexts

**Dino:**

1. Services are discovered automatically
2. MUC rooms appear in **Join Conference**
3. File upload works seamlessly

### Web Clients

**Converse.js:**

```javascript
// Services are discovered automatically
// MUC bookmark discovery
// File upload endpoint discovery
```

## 🔧 Advanced Configuration

### Component-Specific Settings

Each component can have its own discovery settings:

```lua
-- In prosody.cfg.lua (for advanced users)
Component "muc.example.com" "muc"
    disco_hidden = false  -- Show in discovery (default)
    name = "Public Chat Rooms"
    description = "Multi-user chat service"

Component "private.example.com" "muc"  
    disco_hidden = true   -- Hide from discovery
    name = "Private Rooms"
```

### Service Categories

Services are automatically categorized:

| Category | Service Type | Example |
|----------|-------------|---------|
| **conference** | Multi-User Chat | `muc.domain.com` |
| **proxy** | File Transfer | `proxy.domain.com` |
| **store** | File Upload | `upload.domain.com` |
| **gateway** | Protocol Bridge | `irc.domain.com` |

## 📱 Mobile Optimization

Service discovery is optimized for mobile clients:

### Battery Saving

- **Cached responses** reduce network requests
- **Efficient queries** minimize data usage
- **Background discovery** during idle time

### Automatic Configuration

- **Connection methods** discovered automatically
- **Upload endpoints** configured seamlessly
- **Push services** registered automatically

## 🛠️ Troubleshooting

### Common Issues

**Services not appearing in client:**

1. **Check client support:**

   ```bash
   # Test with a disco-capable client like Gajim
   ```

2. **Verify configuration:**

   ```bash
   docker compose logs prosody | grep -i disco
   ```

3. **Test manually:**

   ```bash
   # Using XMPP client with XML console
   <iq type='get' to='yourdomain.com'>
     <query xmlns='http://jabber.org/protocol/disco#items'/>
   </iq>
   ```

**Custom services not showing:**

1. **Check environment variable format:**

   ```bash
   # Correct format
   PROSODY_DISCO_ITEMS="jid1,name1;jid2,name2"
   
   # Incorrect (missing quotes, wrong separator)
   PROSODY_DISCO_ITEMS=jid1,name1,jid2,name2
   ```

2. **Restart required:**

   ```bash
   docker compose restart prosody
   ```

### Debug Commands

**Check discovered items:**

```bash
# From XMPP client XML console
<iq type='get' to='yourdomain.com'>
  <query xmlns='http://jabber.org/protocol/disco#items'/>
</iq>
```

**Check service features:**

```bash
# Query specific service
<iq type='get' to='muc.yourdomain.com'>
  <query xmlns='http://jabber.org/protocol/disco#info'/>
</iq>
```

**Server logs:**

```bash
# Check for disco-related errors
docker compose logs prosody | grep -E "(disco|discovery)"
```

## 🔒 Security Considerations

### Privacy Settings

**Admin Exposure:**

- Keep `PROSODY_DISCO_EXPOSE_ADMINS=false` unless you need public admin contact
- Consider dedicated abuse/contact addresses instead

**Service Visibility:**

- Only advertise services that should be publicly accessible
- Use `disco_hidden=true` for internal/private components

### Access Control

**Component Security:**

```lua
-- Restrict access to specific components
Component "admin.example.com" "muc"
    disco_hidden = true
    restrict_room_creation = "admin"
```

## 📖 Standards Compliance

This implementation supports:

- **XEP-0030**: Service Discovery (core)
- **XEP-0115**: Entity Capabilities (optimization)
- **XEP-0157**: Contact Addresses (admin discovery)
- **XEP-0215**: External Service Discovery (STUN/TURN)

## 🎯 Best Practices

### Service Naming

- Use **descriptive names** that users understand
- Keep names **concise** but informative
- Use **consistent naming** across related services

### Service Organization

- Group related services by subdomain
- Use logical naming patterns:
  - `muc.domain.com` for chat rooms
  - `upload.domain.com` for file sharing
  - `proxy.domain.com` for proxies

### Performance

- **Cache discovery results** in clients when possible
- **Minimize custom disco items** to reduce response size
- **Use efficient client implementations** that cache responses

## 🔗 Related Documentation

- [Multi-User Chat Configuration](muc-configuration.md)
- [File Upload Configuration](file-upload.md)
- [External Services](external-services.md)
- [Client Configuration Guide](client-configuration.md)

## 🆘 Support

If you encounter issues with service discovery:

1. **Check client compatibility** with XEP-0030
2. **Verify network connectivity** to your server
3. **Test with multiple clients** to isolate issues
4. **Review server logs** for configuration errors
5. **Contact support** with specific error messages
