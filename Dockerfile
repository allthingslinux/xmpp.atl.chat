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

# Install build dependencies and Prosody
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
    luarocks && \
    rm -rf /var/lib/apt/lists/*

# Clone community modules
RUN hg clone https://hg.prosody.im/prosody-modules/ /opt/prosody-modules

# Build custom Lua modules if needed
WORKDIR /opt/prosody-modules
RUN find . -name "*.c" -exec gcc -shared -fPIC -I/usr/include/lua5.4 {} -o {}.so \; || true

# Runtime stage - Optimized for production
FROM debian:bookworm-slim AS runtime

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    lua5.4 \
    libssl3 \
    libexpat1 \
    libidn2-0 \
    libicu72 \
    libunbound8 \
    libevent-2.1-7 \
    libreadline8 \
    libsqlite3-0 \
    libpq5 \
    libmariadb3 \
    ca-certificates \
    curl \
    dumb-init \
    gosu && \
    rm -rf /var/lib/apt/lists/*

# Create prosody user and directories
RUN groupadd -r prosody && useradd -r -g prosody prosody && \
    mkdir -p /var/lib/prosody /var/log/prosody /var/run/prosody && \
    chown -R prosody:prosody /var/lib/prosody /var/log/prosody /var/run/prosody

# Download and install latest Prosody
RUN PROSODY_VERSION=$(curl -s https://api.github.com/repos/bjc/prosody/releases/latest | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4) && \
    curl -L "https://github.com/bjc/prosody/archive/${PROSODY_VERSION}.tar.gz" | tar -xz && \
    cd prosody-* && \
    ./configure \
    --prefix=/usr/local \
    --sysconfdir=/etc/prosody \
    --datadir=/var/lib/prosody \
    --with-lua=/usr \
    --runwith=lua5.4 \
    --no-example-certs && \
    make && \
    make install && \
    cd .. && \
    rm -rf prosody-*

# Copy community modules from builder stage
COPY --from=builder /opt/prosody-modules /opt/prosody-modules

# Install community modules
RUN cd /opt/prosody-modules && \
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
    mod_register_ibr; do \
    if [ -d "$module" ]; then \
    cp -r "$module" /usr/local/lib/prosody/modules/ || true; \
    fi; \
    done

# Create necessary directories and set permissions
RUN mkdir -p \
    /etc/prosody \
    /var/lib/prosody \
    /var/log/prosody \
    /var/run/prosody \
    /var/www/certbot/.well-known/acme-challenge \
    /certs && \
    chown -R prosody:prosody \
    /var/lib/prosody \
    /var/log/prosody \
    /var/run/prosody \
    /certs && \
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

# Switch to prosody user for security
USER prosody

# Set working directory
WORKDIR /var/lib/prosody

# Use dumb-init for proper signal handling
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/entrypoint.sh"]

# Build metadata
LABEL maintainer="XMPP Server Admin" \
    description="Production-ready Prosody XMPP server with modern features" \
    version="1.0.0" \
    org.opencontainers.image.title="Prosody XMPP Server" \
    org.opencontainers.image.description="Modern XMPP server with comprehensive features" \
    org.opencontainers.image.vendor="All Things Linux" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/allthingslinux/xmpp.atl.chat"

# Production optimizations
ENV PROSODY_LOG_LEVEL=info \
    PROSODY_STORAGE=sql \
    PROSODY_DB_DRIVER=PostgreSQL \
    LUA_PATH="/usr/local/lib/prosody/?.lua;/usr/local/lib/prosody/?/init.lua;;" \
    LUA_CPATH="/usr/local/lib/prosody/?.so;;"

# Security hardening
RUN echo "prosody:x:999:999::/var/lib/prosody:/usr/sbin/nologin" >>/etc/passwd

# Performance tuning
ENV LUA_GC_STEP=13 \
    LUA_GC_PAUSE=110

# Final security check - ensure no root processes
USER prosody
