# Prosody Dependencies Update

## Overview

Updated the Docker image to include all recommended Prosody dependencies based on the official [Prosody Dependencies documentation](https://prosody.im/doc/depends).

## Dependencies Added

### Required Dependencies ✅

All required dependencies were already included or have been verified:

- **Lua 5.4** - Runtime for majority of Prosody code (recommended version)
- **LuaSec** - SSL/TLS support (version 0.7+)
- **LuaSocket** - Network connections (version 3.x)  
- **LuaFileSystem** - Data store management (version 1.6.2+)
- **LuaExpat** - XML/XMPP stream parsing (version 1.2.x+, 1.4.x+ recommended)

### Recommended Dependencies Added ✅

- **lua-unbound** - Secure asynchronous DNS lookups (version 0.5+)
- **lua-readline** - Console history and editing capabilities
- **luarocks** - Plugin installer (version 2.x, 3.x recommended)

### Optional Dependencies Included ✅

- **lua-dbi-postgresql** - PostgreSQL database support
- **lua-dbi-mysql** - MySQL database support  
- **lua-dbi-sqlite3** - SQLite3 database support via LuaDBI
- **lua-sqlite3** - Alternative SQLite3 support
- **lua-event** - Efficient scaling for hundreds+ concurrent connections
- **lua-bitop** - Bit manipulation (required for mod_websocket)
- **lua-zlib** - Compression support

## Build Stage Improvements

### Enhanced Build Dependencies

Added development packages needed for potential module compilation:

- `libunbound-dev` - For lua-unbound compilation
- `libevent-dev` - For lua-event compilation  
- `libreadline-dev` - For lua-readline compilation
- `libsqlite3-dev`, `libpq-dev`, `libmysqlclient-dev` - Database development headers

### Dependency Verification

Added runtime verification step that checks all critical dependencies are properly installed and accessible to Lua.

### LuaRocks Configuration

Configured LuaRocks for Lua 5.4 with proper include and library paths for plugin management.

## Benefits

1. **Complete Compatibility** - All Prosody features now have their dependencies available
2. **Enhanced Security** - lua-unbound provides secure DNS lookups
3. **Better Performance** - lua-event enables scaling to hundreds of concurrent connections
4. **Plugin Support** - LuaRocks enables easy plugin installation via prosodyctl
5. **Development Ready** - All build dependencies included for module compilation
6. **Console Features** - lua-readline provides history and editing in the Prosody console

## Verification

The Docker build now includes verification steps that confirm all dependencies are properly installed and accessible. This ensures the image will work correctly with all Prosody features.

## Usage

No changes required to existing configurations. The enhanced dependencies are automatically available to Prosody and will enable additional features where applicable.

For plugin installation using LuaRocks:

```bash
docker exec prosody prosodyctl install <module-name>
```

## References

- [Prosody Dependencies Documentation](https://prosody.im/doc/depends)
- [LuaRocks Plugin Installation](https://prosody.im/doc/plugins#installing)
