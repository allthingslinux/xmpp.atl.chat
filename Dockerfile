# --- 1. Builder stage: Build Prosody and LuaRocks ---
FROM debian:bookworm-slim AS builder

ARG LUAROCKS_VERSION=3.11.1

# Set shell options for better error handling
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential gcc git libc6-dev libidn2-dev liblua5.4-dev libsqlite3-dev libssl-dev libicu-dev libmariadb-dev-compat libexpat1-dev libunbound-dev libevent-dev libreadline-dev make unzip \
    lua5.4 lua-bitop lua-dbi-mysql lua-dbi-postgresql lua-expat lua-filesystem lua-socket lua-sec lua-unbound \
    ca-certificates curl dumb-init gosu wget jq mercurial rsync && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Build Prosody
WORKDIR /usr/src
RUN set -x && \
    PROSODY_VERSION="13.0.2" && \
    curl -fsSL -o prosody.tar.gz "https://prosody.im/downloads/source/prosody-${PROSODY_VERSION}.tar.gz" && \
    mkdir -p prosody && \
    tar -xzf prosody.tar.gz -C prosody --strip-components=1 && \
    rm prosody.tar.gz

WORKDIR /usr/src/prosody
RUN ./configure \
    --prefix=/usr/local \
    --sysconfdir=/etc/prosody \
    --datadir=/var/lib/prosody \
    --with-lua=/usr \
    --runwith=lua5.4 \
    --no-example-certs && \
    make && \
    make install

# Build LuaRocks
WORKDIR /usr/src/luarocks
RUN curl -fsSL -o luarocks-${LUAROCKS_VERSION}.tar.gz https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz && \
    tar zxpf luarocks-${LUAROCKS_VERSION}.tar.gz && \
    rm luarocks-${LUAROCKS_VERSION}.tar.gz

WORKDIR /usr/src/luarocks/luarocks-${LUAROCKS_VERSION}
RUN ./configure --with-lua=/usr && \
    make bootstrap

# --- 2. Runtime stage: Minimal image ---
FROM debian:bookworm-slim

# Set shell options for better error handling
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install runtime dependencies only
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    lua5.4 lua-bitop lua-dbi-mysql lua-dbi-postgresql lua-dbi-sqlite3 \
    lua-expat lua-filesystem lua-socket lua-sec lua-unbound \
    lua-readline lua-event lua-ldap lua-luaossl \
    libicu72 libidn2-0 \
    ca-certificates curl dumb-init gosu jq rsync wget tar unzip \
    libssl-dev build-essential gcc liblua5.4-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Prosody and LuaRocks from builder
COPY --from=builder /usr/local /usr/local
COPY --from=builder /usr/bin/luarocks* /usr/bin/

# --- Community modules ---
COPY scripts/setup/install-community-modules.sh /usr/local/bin/install-community-modules.sh
RUN chmod +x /usr/local/bin/install-community-modules.sh

# Copy configs early so prosodyctl has a config to read during build
COPY core/config/prosody.cfg.lua /etc/prosody/prosody.cfg.lua
COPY core/config/conf.d /etc/prosody/conf.d

## Defer community module installation until after prosody user/log dirs exist

# --- Configs, entrypoint, and scripts ---
COPY --chown=prosody:prosody scripts/setup/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chown=prosody:prosody scripts/maintenance/health-check.sh /usr/local/bin/health-check.sh
COPY --chown=prosody:prosody prosody-manager /usr/local/bin/prosody-manager

RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/health-check.sh /usr/local/bin/prosody-manager

# --- User, permissions, and entrypoint ---
RUN groupadd -r prosody && useradd -r -g prosody prosody && \
    mkdir -p /var/lib/prosody /var/lib/prosody/custom_plugins /var/log/prosody /var/run/prosody /certs /usr/local/lib/prosody/community-modules /etc/prosody/certs && \
    chown -R prosody:prosody /var/lib/prosody /var/log/prosody /var/run/prosody /certs /usr/local/lib/prosody/community-modules /etc/prosody/certs

# --- Ownership for configuration ---
RUN chown root:prosody /etc/prosody/prosody.cfg.lua && \
    chmod 640 /etc/prosody/prosody.cfg.lua && \
    chown -R root:prosody /etc/prosody/conf.d && \
    find /etc/prosody/conf.d -type f -name '*.lua' -exec chmod 640 {} +

# --- Install community modules via plugin installer (after prosody user/logs exist) ---
WORKDIR /tmp
RUN mkdir -p /usr/local/lib/prosody/community-modules && \
    /usr/local/bin/install-community-modules.sh \
    mod_anti_spam \
    mod_admin_blocklist \
    mod_spam_reporting \
    mod_cloud_notify \
    mod_cloud_notify_extensions \
    mod_csi_battery_saver \
    mod_invites \
    mod_muc_notifications \
    mod_muc_offline_delivery \
    mod_vcard_muc \
    mod_http_upload \
    mod_http_status \
    mod_compliance_latest \
    mod_s2s_status \
    mod_log_slow_events \
    mod_pastebin \
    mod_reload_modules \
    mod_pubsub_subscription && \
    echo "Community modules installed successfully"

# --- Expose all relevant ports ---
EXPOSE 5222 5223 5269 5270 5280 5281 5347 5000

# --- Healthcheck, volumes, environment, and entrypoint ---
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 CMD /usr/local/bin/health-check.sh
VOLUME ["/var/lib/prosody", "/var/log/prosody", "/certs"]

ENV __FLUSH_LOG=yes \
    PROSODY_LOG_LEVEL=info \
    PROSODY_STORAGE=sql \
    PROSODY_DB_DRIVER=PostgreSQL \
    LUA_PATH="/usr/lib/prosody/?.lua;/usr/lib/prosody/?/init.lua;/usr/local/lib/prosody/?.lua;/usr/local/lib/prosody/?/init.lua;/var/lib/prosody/custom_plugins/?.lua;/var/lib/prosody/custom_plugins/?/init.lua;/var/lib/prosody/custom_plugins/share/lua/5.4/?.lua;/var/lib/prosody/custom_plugins/share/lua/5.4/?/init.lua;;" \
    LUA_CPATH="/usr/lib/prosody/?.so;/usr/local/lib/prosody/?.so;;" \
    LUA_GC_STEP=13 \
    LUA_GC_PAUSE=110

WORKDIR /var/lib/prosody

# --- Entrypoint as PID 1 for signal handling ---
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/entrypoint.sh"]

# ---
# To install official modules at build or runtime, use:
#   prosodyctl install --server=https://modules.prosody.im/rocks/ mod_example
# This is available in the image and can be used in Dockerfile or at runtime.
# ---
