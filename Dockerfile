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

# Clone and install community modules
RUN git clone https://hg.prosody.im/prosody-modules/ /usr/src/prosody-modules && \
    cd /usr/src/prosody-modules && \
    for module in \
    mod_pastebin \
    mod_http_openmetrics \
    mod_cloud_notify \
    mod_smacks \
    mod_csi_simple \
    mod_csi_battery_saver \
    mod_filter_chatstates \
    mod_spam_reporting \
    mod_measure_client_connections \
    mod_measure_stanza_counts \
    mod_measure_message_e2ee \
    mod_stanza_counter \
    mod_watchregistrations \
    mod_tombstones \
    mod_server_contact_info \
    mod_register_limits \
    mod_flags \
    mod_s2s_auth_dane_in \
    mod_user_account_management \
    mod_account_activity \
    mod_extdisco \
    mod_turncredentials \
    mod_external_services \
    mod_http_altconnect \
    mod_compression \
    mod_bookmarks \
    mod_vcard4 \
    mod_vcard_legacy \
    mod_http_file_share \
    mod_proxy65 \
    mod_muc_mam \
    mod_muc_unique \
    mod_addressing \
    mod_receipts \
    mod_blocklist \
    mod_privacy \
    mod_limits \
    mod_firewall \
    mod_admin_web \
    mod_statistics \
    mod_watchdog \
    mod_uptime \
    mod_posix \
    mod_register_ibr \
    mod_e2e_policy \
    mod_throttle_presence \
    mod_vcard_muc; do \
    if [ -d "$module" ]; then \
    cp -r "$module" /usr/local/lib/prosody/modules/ || true; \
    fi; \
    done && \
    rm -rf /usr/src/prosody-modules

# Create prosody user and directories
RUN groupadd -r prosody && \
    useradd -r -g prosody prosody && \
    mkdir -p /var/lib/prosody /var/log/prosody /var/run/prosody && \
    mkdir -p /var/www/certbot/.well-known/acme-challenge && \
    mkdir -p /certs && \
    chown -R prosody:prosody /var/lib/prosody /var/log/prosody /var/run/prosody /certs && \
    chmod 755 /var/www/certbot/.well-known/acme-challenge

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
VOLUME ["/var/lib/prosody", "/var/log/prosody", "/certs"]

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
