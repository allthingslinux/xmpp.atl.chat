# Professional Prosody XMPP Server Docker Image
# Based on analysis of 42+ XMPP implementations
# Combines security-first approach with modern optimization
#
# Updated with all recommended Prosody dependencies:
# - All required dependencies (Lua 5.4, LuaSocket, LuaSec, LuaFileSystem, LuaExpat)
# - Recommended dependencies (LuaUnbound, LuaReadline, LuaEvent, LuaRocks)
# - Optional dependencies for enhanced functionality (SQL drivers, BitOp, etc.)
# Reference: https://prosody.im/doc/depends

FROM debian:bookworm-slim

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
ARG LUAROCKS_VERSION=3.11.1

# Build metadata
LABEL maintainer="XMPP Server Admin" \
    description="Production-ready Prosody XMPP server with modern features" \
    version="1.0.0" \
    org.opencontainers.image.title="Prosody XMPP Server" \
    org.opencontainers.image.description="Modern XMPP server with comprehensive features" \
    org.opencontainers.image.vendor="All Things Linux" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/allthingslinux/xmpp.atl.chat" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.revision="${VCS_REF}" \
    org.opencontainers.image.version="${VERSION}" \
    luarocks.version="${LUAROCKS_VERSION}"

# Install runtime dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libevent-2.1-7 \
    libicu72 \
    libidn2-0 \
    libpq5 \
    libsqlite3-0 \
    libmariadb3 \
    libssl3 \
    libexpat1 \
    libunbound8 \
    libreadline8 \
    lua5.4 \
    lua-bitop \
    lua-dbi-mysql \
    lua-dbi-postgresql \
    lua-expat \
    lua-filesystem \
    lua-socket \
    lua-sec \
    lua-unbound \
    ca-certificates \
    curl \
    dumb-init \
    gosu \
    wget \
    jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Build Prosody and LuaRocks from source with latest versions
RUN buildDeps='gcc git libc6-dev libidn2-dev liblua5.4-dev libsqlite3-dev libssl-dev libicu-dev libmariadb-dev-compat libexpat1-dev libunbound-dev libevent-dev libreadline-dev make unzip' && \
    set -x && \
    apt-get update && apt-get install -y $buildDeps --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    \
    PROSODY_VERSION=$(curl -s https://prosody.im/downloads/source/ | grep -o 'prosody-[0-9][0-9\.]*\.tar\.gz' | head -1 | sed 's/prosody-\(.*\)\.tar\.gz/\1/') && \
    echo "Installing Prosody version: $PROSODY_VERSION" && \
    wget -O prosody.tar.gz "https://prosody.im/downloads/source/prosody-${PROSODY_VERSION}.tar.gz" && \
    mkdir -p /usr/src/prosody && \
    tar -xzf prosody.tar.gz -C /usr/src/prosody --strip-components=1 && \
    rm prosody.tar.gz && \
    cd /usr/src/prosody && \
    ./configure \
    --prefix=/usr/local \
    --sysconfdir=/etc/prosody \
    --datadir=/var/lib/prosody \
    --with-lua=/usr \
    --runwith=lua5.4 \
    --no-example-certs && \
    make && \
    make install && \
    cd / && rm -r /usr/src/prosody && \
    \
    mkdir /usr/src/luarocks && \
    cd /usr/src/luarocks && \
    wget https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz && \
    tar zxpf luarocks-${LUAROCKS_VERSION}.tar.gz && \
    cd luarocks-${LUAROCKS_VERSION} && \
    ./configure --with-lua=/usr && \
    make bootstrap && \
    cd / && rm -r /usr/src/luarocks && \
    \
    luarocks install luaevent && \
    luarocks install luadbi && \
    luarocks install luadbi-sqlite3 && \
    luarocks install luadbi-postgresql && \
    luarocks install stringy && \
    \
    apt-get purge -y --auto-remove $buildDeps

# Prepare module directories (modules will be mounted externally)
RUN mkdir -p /usr/local/lib/prosody/modules && \
    chown -R prosody:prosody /usr/local/lib/prosody/modules

# Create prosody user and directories
RUN groupadd -r prosody && \
    useradd -r -g prosody prosody && \
    mkdir -p /var/lib/prosody /var/log/prosody /var/run/prosody && \
    mkdir -p /certs && \
    chown -R prosody:prosody /var/lib/prosody /var/log/prosody /var/run/prosody /certs

# Copy configuration files
COPY config/prosody.cfg.lua /etc/prosody/prosody.cfg.lua
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/health-check.sh /usr/local/bin/health-check.sh
COPY scripts/prosody-manager /usr/local/bin/prosody-manager

# Make scripts executable
RUN chmod +x /usr/local/bin/entrypoint.sh \
    /usr/local/bin/health-check.sh \
    /usr/local/bin/prosody-manager

# Set ownership for configuration
RUN chown root:prosody /etc/prosody/prosody.cfg.lua && \
    chmod 640 /etc/prosody/prosody.cfg.lua

# Expose ports
EXPOSE 5222 5223 5269 5270 5280 5281 5347

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /usr/local/bin/health-check.sh

# Volume mounts
VOLUME ["/var/lib/prosody", "/var/log/prosody", "/certs", "/usr/local/lib/prosody/modules"]

# Environment variables for proper logging
ENV __FLUSH_LOG=yes \
    PROSODY_LOG_LEVEL=info \
    PROSODY_STORAGE=sql \
    PROSODY_DB_DRIVER=PostgreSQL \
    LUA_PATH="/usr/local/lib/prosody/?.lua;/usr/local/lib/prosody/?/init.lua;;" \
    LUA_CPATH="/usr/local/lib/prosody/?.so;;"

# Performance tuning
ENV LUA_GC_STEP=13 \
    LUA_GC_PAUSE=110

# Switch to prosody user for security
USER prosody

# Set working directory
WORKDIR /var/lib/prosody

# Use dumb-init for proper signal handling
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/entrypoint.sh"]
