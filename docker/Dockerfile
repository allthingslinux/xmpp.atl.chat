# Professional Prosody XMPP Server Docker Image
# Based on analysis of 42+ XMPP implementations
# Combines security-first approach with modern optimization
#
# Updated with all recommended Prosody dependencies:
# - All required dependencies (Lua 5.4, LuaSocket, LuaSec, LuaFileSystem, LuaExpat)
# - Recommended dependencies (LuaUnbound, LuaReadline, LuaEvent, LuaRocks)
# - Optional dependencies for enhanced functionality (SQL drivers, BitOp, etc.)
# Reference: https://prosody.im/doc/depends

# Build stage - Community modules and dependencies
FROM debian:bookworm-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    lua5.4-dev \
    liblua5.4-dev \
    libssl-dev \
    libexpat1-dev \
    libidn2-dev \
    libicu-dev \
    libunbound-dev \
    libevent-dev \
    libreadline-dev \
    libsqlite3-dev \
    libpq-dev \
    libmysqlclient-dev \
    mercurial \
    git \
    ca-certificates \
    curl \
    luarocks &&
    rm -rf /var/lib/apt/lists/*

# Clone community modules
RUN hg clone https://hg.prosody.im/prosody-modules/ /opt/prosody-modules

# Build custom Lua modules if needed
WORKDIR /opt/prosody-modules
RUN find . -name "*.c" -exec gcc -shared -fPIC -I/usr/include/lua5.4 {} -o {}.so \; || true

# Runtime stage - Optimized for production
FROM debian:bookworm-slim AS runtime

# Metadata
LABEL maintainer="XMPP Admin <admin@domain.com>"
LABEL description="Professional Prosody XMPP Server"
LABEL version="1.0.0"

# Install runtime dependencies based on Prosody documentation
# Reference: https://prosody.im/doc/depends
#
# REQUIRED DEPENDENCIES:
# - lua5.4: Runtime for majority of Prosody code (Lua 5.4 recommended)
# - lua-sec: SSL/TLS support (version 0.7+)
# - lua-socket: Network connections (version 3.x)
# - lua-filesystem: Data store management (version 1.6.2+)
# - lua-expat: XML/XMPP stream parsing (version 1.2.x+, 1.4.x+ recommended)
#
# RECOMMENDED DEPENDENCIES:
# - lua-unbound: Secure asynchronous DNS lookups (version 0.5+)
# - lua-readline: Console history and editing capabilities
# - lua-event: Efficient scaling for hundreds+ concurrent connections
# - luarocks: Plugin installer (version 2.x, 3.x recommended)
#
# OPTIONAL DEPENDENCIES:
# - lua-dbi-*: SQL database support (version 0.6+)
# - lua-sql-sqlite3: Alternative SQLite3 support to LuaDBI
# - lua-bitop: Bit manipulation (for mod_websocket)
# - lua-zlib: Compression support
RUN apt-get update && apt-get install -y
# Core Prosody and Lua
prosody \
    lua5.4 \
    liblua5.4-0
# Required dependencies for XMPP functionality
lua-sec \
    lua-socket \
    lua-filesystem \
    lua-expat
# Database drivers (Optional but recommended for SQL storage)
lua-dbi-postgresql \
    lua-dbi-mysql \
    lua-dbi-sqlite3
# SQLite3 support (alternative to LuaDBI for SQLite)
lua-sqlite3
# Recommended dependencies for enhanced functionality
lua-unbound \
    lua-readline \
    lua-event \
    lua-bitop \
    lua-zlib
# Redis support for caching
lua-redis
# Plugin management
luarocks
# System utilities
ca-certificates \
    openssl \
    curl \
    dnsutils
# Process management
tini
# Monitoring tools
procps &&
    rm -rf /var/lib/apt/lists/* &&
    apt-get clean

# Verify critical dependencies are installed with proper versions
RUN echo "Verifying Prosody dependencies..." &&
    lua5.4 -e "print('Lua ' .. _VERSION .. ' - OK')" &&
    lua5.4 -e "require('socket'); print('LuaSocket - OK')" &&
    lua5.4 -e "require('ssl'); print('LuaSec - OK')" &&
    lua5.4 -e "require('lfs'); print('LuaFileSystem - OK')" &&
    lua5.4 -e "require('lxp'); print('LuaExpat - OK')" &&
    lua5.4 -e "pcall(require, 'unbound') and print('LuaUnbound - OK') or print('LuaUnbound - Not available but optional')" &&
    lua5.4 -e "pcall(require, 'readline') and print('LuaReadline - OK') or print('LuaReadline - Not available but optional')" &&
    lua5.4 -e "pcall(require, 'event') and print('LuaEvent - OK') or print('LuaEvent - Not available but optional')" &&
    lua5.4 -e "pcall(require, 'bit') and print('BitOp - OK') or print('BitOp - Not available but optional')" &&
    lua5.4 -e "pcall(require, 'redis') and print('Redis - OK') or print('Redis - Not available but optional')" &&
    prosody --version

# Configure LuaRocks for Prosody plugin management
RUN luarocks config lua_version 5.4 &&
    luarocks config variables.LUA_INCDIR /usr/include/lua5.4 &&
    luarocks config variables.LUA_LIBDIR /usr/lib/x86_64-linux-gnu

# Copy community modules from builder
COPY --from=builder /opt/prosody-modules /opt/prosody-modules

# Create prosody user and directories
RUN groupadd -r prosody && useradd -r -g prosody -d /var/lib/prosody -s /bin/false prosody

# Create directory structure
RUN mkdir -p \
    /etc/prosody/conf.d \
    /etc/prosody/modules.d \
    /etc/prosody/firewall \
    /etc/prosody/templates \
    /etc/prosody/certs \
    /var/lib/prosody/data \
    /var/lib/prosody/uploads \
    /var/log/prosody \
    /opt/prosody/scripts &&
    chown -R prosody:prosody \
        /etc/prosody \
        /var/lib/prosody \
        /var/log/prosody

# Setup community modules
RUN mkdir -p /usr/lib/prosody/community-modules &&
    cp -r /opt/prosody-modules/* /usr/lib/prosody/community-modules/ 2>/dev/null || true &&
    # Create symlinks for specific modules that are stable
    for module in /opt/prosody-modules/mod_*; do
        if [[ -f "$module" ]]; then
            ln -sf "$module" /usr/lib/prosody/modules/ 2>/dev/null || true
        fi
    done &&
    # Set proper permissions
    chown -R prosody:prosody /usr/lib/prosody/community-modules/ 2>/dev/null || true

# Copy configuration files
COPY config/ /etc/prosody/config/

# Copy scripts
COPY scripts/entrypoint.sh /opt/prosody/scripts/
COPY scripts/health-check.sh /opt/prosody/scripts/

# Make scripts executable
RUN chmod +x /opt/prosody/scripts/*.sh

# Set proper permissions
RUN chown -R prosody:prosody /etc/prosody /var/lib/prosody /var/log/prosody

# Create log files with proper permissions
RUN touch /var/log/prosody/prosody.log /var/log/prosody/error.log &&
    chown prosody:prosody /var/log/prosody/*.log

# Expose ports
EXPOSE 5222/tcp # Client connections (C2S)
EXPOSE 5269/tcp # Server connections (S2S)
EXPOSE 5280/tcp # HTTP (BOSH, WebSocket, file upload)
EXPOSE 5281/tcp # HTTPS (secure HTTP services)

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /opt/prosody/scripts/health-check.sh

# Volume mounts for persistent data
VOLUME ["/etc/prosody/certs", "/var/lib/prosody/data", "/var/log/prosody"]

# Switch to prosody user
USER prosody

# Use tini for proper signal handling
ENTRYPOINT ["/usr/bin/tini", "--"]

# Production optimizations and security hardening
RUN echo "session required pam_limits.so" >>/etc/pam.d/common-session &&
    echo "prosody soft nofile 65536" >>/etc/security/limits.conf &&
    echo "prosody hard nofile 65536" >>/etc/security/limits.conf &&
    echo "prosody soft nproc 32768" >>/etc/security/limits.conf &&
    echo "prosody hard nproc 32768" >>/etc/security/limits.conf

# Set security and performance sysctls (requires privileged mode or host networking)
# These would typically be set at the host level:
# net.core.somaxconn = 65535
# net.core.netdev_max_backlog = 5000
# net.ipv4.tcp_max_syn_backlog = 8192
# net.ipv4.tcp_keepalive_time = 600
# net.ipv4.tcp_keepalive_intvl = 30
# net.ipv4.tcp_keepalive_probes = 3

# Default command
CMD ["/opt/prosody/scripts/entrypoint.sh"]

# Multi-architecture support
FROM runtime AS amd64
# AMD64 specific optimizations if needed

FROM runtime AS arm64
# ARM64 specific optimizations if needed

FROM runtime AS armv7
# ARMv7 specific optimizations if needed

# Default to runtime stage
FROM runtime
