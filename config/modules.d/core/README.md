# Core Modules Configuration

This directory contains configuration for **Core Modules** - essential XMPP functionality that is always enabled.

## Stability Level: 🟢 Core

- **Status**: Always enabled
- **Risk**: Minimal - part of Prosody core
- **Description**: Essential XMPP functionality required for basic operation

## Modules Included

- `roster` - Contact list management
- `saslauth` - Authentication mechanism
- `tls` - Transport Layer Security
- `dialback` - Server-to-server authentication
- `disco` - Service discovery
- `private` - Private XML storage
- `vcard` - User profile information
- `version` - Software version queries
- `uptime` - Server uptime reporting
- `time` - Time synchronization
- `ping` - Connection keep-alive

## Configuration

Core modules are configured directly in the main `prosody.cfg.lua` file and cannot be disabled.
