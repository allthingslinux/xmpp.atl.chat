# TURN/STUN Server Setup for XMPP Audio/Video Calls

## Overview

This document describes the TURN/STUN server configuration for enabling reliable audio/video calls in your XMPP server. The setup uses COTURN (a TURN and STUN server) integrated with Prosody via the `mod_turn_external` module.

## What is TURN/STUN?

- **STUN (Session Traversal Utilities for NAT)**: Helps clients discover their public IP address and NAT type
- **TURN (Traversal Using Relays around NAT)**: Provides relay services when direct peer-to-peer connections fail
- **Purpose**: Enables reliable audio/video calls by handling NAT traversal and firewall restrictions

## Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   XMPP      │    │   COTURN    │    │   External  │
│  Clients    │◄──►│   Server    │◄──►│   Clients   │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │
       │                   │
       ▼                   ▼
┌─────────────┐    ┌─────────────┐
│  Prosody    │    │  TURN/STUN  │
│  Server     │    │   Service   │
└─────────────┘    └─────────────┘
```

## Configuration Files

### 1. Prosody Configuration

**File**: `core/config/prosody.cfg.lua`
- **Module**: `"turn_external"` is enabled in `modules_enabled`

**File**: `core/config/conf.d/05-network.cfg.lua`
```lua
-- TURN external configuration (XEP-0215)
turn_external_secret = os.getenv("TURN_SECRET") or "ChangeMe123!"
turn_external_host = os.getenv("TURN_DOMAIN") or "atl.chat"
turn_external_port = tonumber(os.getenv("TURN_PORT")) or 3478
turn_external_ttl = 86400
turn_external_tcp = true
```

### 2. Docker Compose Configuration

**File**: `docker-compose.yml`
- **Service**: `xmpp-coturn` (COTURN TURN/STUN server)
- **Ports**: 3478 (UDP/TCP), 5349 (TLS), 49152-65535 (RTP relay range)
- **Volume**: `xmpp_coturn_data` mounted to `.runtime/coturn`

### 3. Environment Variables

**File**: `.env`
```bash
# TURN server domain (should match your XMPP domain)
TURN_DOMAIN=atl.chat
TURN_REALM=atl.chat

# TURN server ports
TURN_PORT=3478                     # STUN/TURN port
TURNS_PORT=5349                    # STUN/TURN over TLS port
TURN_MIN_PORT=49152                # RTP relay port range start
TURN_MAX_PORT=65535                # RTP relay port range end

# TURN server authentication
TURN_USERNAME=prosody
TURN_PASSWORD=ChangeMe123!
TURN_SECRET=ChangeMe123!           # Must match turn_external_secret in Prosody
```

## Security Considerations

### 1. Authentication
- **Shared Secret**: `TURN_SECRET` must match between Prosody and COTURN
- **Credential Generation**: Prosody dynamically generates temporary credentials
- **TTL**: Credentials expire after 24 hours (configurable)

### 2. Network Security
- **No Loopback**: `TURN_NO_LOOPBACK_PEERS=true` prevents internal network abuse
- **No Multicast**: `TURN_NO_MULTICAST_PEERS=true` prevents multicast abuse
- **Port Range**: RTP relay ports (49152-65535) are restricted to TURN service

### 3. TLS Configuration
- **Modern Ciphers**: Only TLS 1.2+ with strong cipher suites
- **No Legacy**: Disabled SSLv2, SSLv3, TLS 1.0, TLS 1.1

## Deployment Steps

### 1. Pre-deployment Checklist
- [ ] DNS record for `turn.atl.chat` points to your server
- [ ] Firewall allows ports 3478 (UDP/TCP), 5349 (TLS)
- [ ] Firewall allows UDP ports 49152-65535 for RTP relay
- [ ] Strong, unique `TURN_SECRET` is set

### 2. Test Configuration
```bash
# Test configuration without starting services
./scripts/test-turn-config.sh

# Start only COTURN service first
docker compose up -d xmpp-coturn

# Check COTURN logs
docker compose logs xmpp-coturn
```

### 3. Start Full Stack
```bash
# Start all services including TURN/STUN
docker compose up -d

# Verify TURN service discovery
docker compose exec xmpp-prosody prosodyctl check turn
```

## Testing

### 1. Basic Connectivity
```bash
# Test STUN service
stunclient turn.atl.chat 3478

# Test TURN service (requires credentials)
# Use WebRTC test tools or XMPP clients
```

### 2. XMPP Integration
```bash
# Check TURN service discovery
docker compose exec xmpp-prosody prosodyctl check turn

# Test with verbose output
docker compose exec xmpp-prosody prosodyctl check turn -v
```

### 3. Client Testing
- **Conversations**: Enable audio/video calls
- **Gajim**: Test with audio/video plugin
- **Web clients**: Use Converse.js or similar

## Troubleshooting

### Common Issues

#### 1. TURN Service Not Discovered
- **Check**: `prosodyctl check turn`
- **Verify**: `turn_external_secret` matches `TURN_SECRET`
- **Confirm**: `turn_external_host` resolves correctly

#### 2. Connection Refused
- **Check**: Firewall allows TURN ports
- **Verify**: COTURN container is running
- **Confirm**: Port mappings in docker-compose.yml

#### 3. Authentication Failures
- **Check**: Shared secret configuration
- **Verify**: Environment variables are loaded
- **Confirm**: No typos in secret values

### Debug Commands
```bash
# Check COTURN logs
docker compose logs xmpp-coturn

# Check Prosody logs for TURN errors
docker compose logs xmpp-prosody | grep -i turn

# Test TURN service discovery
docker compose exec xmpp-prosody prosodyctl check turn -v

# Verify environment variables
docker compose exec xmpp-coturn env | grep TURN
```

## Performance Tuning

### 1. Resource Limits
- **Memory**: 256MB limit, 64MB reservation
- **CPU**: 1.0 core limit, 0.25 core reservation
- **Network**: Ephemeral port range 49152-65535

### 2. Network Optimization
- **UDP Priority**: Most clients prefer UDP for media
- **TCP Fallback**: Enabled for restrictive firewalls
- **TLS Support**: Available on port 5349

### 3. Monitoring
- **Logs**: JSON format with rotation
- **Metrics**: Available via Prosody's HTTP endpoints
- **Health Checks**: Built-in container health monitoring

## References

- [Prosody TURN Documentation](https://prosody.im/doc/turn)
- [COTURN GitHub Repository](https://github.com/coturn/coturn)
- [XEP-0215: External Service Discovery](https://xmpp.org/extensions/xep-0215.html)
- [WebRTC ICE and TURN](https://webrtc.github.io/webrtc-org/native-code/native-apis/)

## Support

For issues with this TURN/STUN setup:
1. Check the troubleshooting section above
2. Review container logs: `docker compose logs xmpp-coturn`
3. Verify configuration with: `./scripts/test-turn-config.sh`
4. Test TURN discovery: `docker compose exec xmpp-prosody prosodyctl check turn`
