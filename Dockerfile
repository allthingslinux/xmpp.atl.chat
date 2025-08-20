# --- 1. Builder stage: Build Prosody and LuaRocks ---
FROM debian:bookworm-slim AS builder

ARG LUAROCKS_VERSION=3.11.1
ARG PROSODY_VERSION=13.0.2

# Set shell options for better error handling
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install build dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    git \
    libc6-dev \
    libidn2-dev \
    liblua5.4-dev \
    libsqlite3-dev \
    libssl-dev \
    libicu-dev \
    libmariadb-dev-compat \
    libexpat1-dev \
    libunbound-dev \
    libevent-dev \
    libreadline-dev \
    make \
    unzip \
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
    jq \
    mercurial \
    rsync && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Build Prosody
WORKDIR /usr/src
RUN set -x && \
    curl -fsSL -o prosody.tar.gz "https://prosody.im/downloads/source/prosody-${PROSODY_VERSION}.tar.gz" && \
    mkdir -p prosody && \
    tar -xzf prosody.tar.gz -C prosody --strip-components=1 && \
    rm prosody.tar.gz && \
    cd prosody && \
    ./configure \
    --prefix=/usr/local \
    --sysconfdir=/etc/prosody \
    --datadir=/var/lib/prosody \
    --with-lua=/usr \
    --runwith=lua5.4 \
    --no-example-certs && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf prosody*

# Build LuaRocks
WORKDIR /usr/src/luarocks
RUN curl -fsSL -o luarocks-${LUAROCKS_VERSION}.tar.gz https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz && \
    tar zxf luarocks-${LUAROCKS_VERSION}.tar.gz && \
    rm luarocks-${LUAROCKS_VERSION}.tar.gz && \
    cd luarocks-${LUAROCKS_VERSION} && \
    ./configure --with-lua=/usr && \
    make bootstrap && \
    cd .. && \
    rm -rf luarocks*

# --- 2. Runtime stage: Minimal image ---
FROM debian:bookworm-slim

# Set shell options for better error handling
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install runtime dependencies only (no build tools)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    lua5.4 \
    lua-bitop \
    lua-dbi-mysql \
    lua-dbi-postgresql \
    lua-dbi-sqlite3 \
    lua-expat \
    lua-filesystem \
    lua-socket \
    lua-sec \
    lua-unbound \
    lua-readline \
    lua-event \
    lua-ldap \
    lua-luaossl \
    libicu72 \
    libidn2-0 \
    ca-certificates \
    curl \
    dumb-init \
    gosu \
    jq \
    rsync \
    wget \
    tar \
    unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy Prosody and LuaRocks from builder
COPY --from=builder /usr/local /usr/local
COPY --from=builder /usr/bin/luarocks* /usr/bin/

# --- User, permissions, and directories ---
RUN groupadd -r prosody && \
    useradd -r -g prosody prosody && \
    mkdir -p /var/lib/prosody /var/lib/prosody/custom_plugins /var/log/prosody /var/run/prosody /certs /usr/local/lib/prosody/community-modules /etc/prosody/certs && \
    chown -R prosody:prosody /var/lib/prosody /var/log/prosody /var/run/prosody /certs /usr/local/lib/prosody/community-modules /etc/prosody/certs

# Copy scripts and make executable
COPY --chown=prosody:prosody scripts/setup/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chown=prosody:prosody scripts/maintenance/health-check.sh /usr/local/bin/health-check.sh

COPY scripts/setup/install-community-modules.sh /usr/local/bin/install-community-modules.sh
COPY scripts/install-modules.sh /usr/local/bin/install-modules.sh

RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/health-check.sh /usr/local/bin/install-community-modules.sh /usr/local/bin/install-modules.sh

# --- Install community modules (optional - can be installed at runtime) ---
# Note: Community modules installation may hit rate limits during build
# They can be installed at runtime using: prosodyctl install --server=https://modules.prosody.im/rocks/ mod_name
# Or using the install-modules.sh script in the running container
WORKDIR /tmp
RUN mkdir -p /usr/local/lib/prosody/community-modules && \
    echo "Community modules installation skipped during build to avoid rate limits" && \
    echo "To install community modules at runtime, run:" && \
    echo "  prosodyctl install --server=https://modules.prosody.im/rocks/ mod_cloud_notify" && \
    echo "  prosodyctl install --server=https://modules.prosody.im/rocks/ mod_cloud_notify_extensions" && \
    echo "  prosodyctl install --server=https://modules.prosody.im/rocks/ mod_muc_notifications" && \
    echo "  prosodyctl install --server=https://modules.prosody.im/rocks/ mod_muc_offline_delivery" && \
    echo "Or use the install script: /usr/local/bin/install-community-modules.sh" && \
    rm -rf /tmp/* /var/tmp/*

# --- Expose all relevant ports ---
EXPOSE 5222 5223 5269 5270 5280 5281 5347 5000

# --- Healthcheck, volumes, and final setup ---
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 CMD /usr/local/bin/health-check.sh

# Create volumes for persistent data
VOLUME ["/var/lib/prosody", "/var/log/prosody", "/certs"]

# Set Lua paths for modules and C libraries
ENV LUA_PATH="/usr/lib/prosody/?.lua;/usr/lib/prosody/?/init.lua;/usr/local/lib/prosody/?.lua;/usr/local/lib/prosody/?/init.lua;/var/lib/prosody/custom_plugins/?.lua;/var/lib/prosody/custom_plugins/?/init.lua;/var/lib/prosody/custom_plugins/share/lua/5.4/?.lua;/var/lib/prosody/custom_plugins/share/lua/5.4/?/init.lua;;" \
    LUA_CPATH="/usr/lib/prosody/?.so;/usr/local/lib/prosody/?.so;;"

WORKDIR /var/lib/prosody
USER prosody

# --- Entrypoint as PID 1 for signal handling ---
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/entrypoint.sh"]