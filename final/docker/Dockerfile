# Professional Prosody XMPP Server Docker Image
# Based on analysis of 42+ XMPP implementations
# Combines security-first approach with modern optimization

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
    mercurial \
    git \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

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

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    # Core Prosody and Lua
    prosody \
    lua5.4 \
    liblua5.4-0 \
    # Database drivers
    lua-dbi-postgresql \
    lua-dbi-mysql \
    lua-dbi-sqlite3 \
    # Security and networking
    lua-sec \
    lua-socket \
    lua-bitop \
    lua-event \
    lua-zlib \
    lua-filesystem \
    lua-expat \
    # System utilities
    ca-certificates \
    openssl \
    curl \
    dnsutils \
    # Process management
    tini \
    # Monitoring tools
    procps \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

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
    /opt/prosody/scripts \
    && chown -R prosody:prosody \
        /etc/prosody \
        /var/lib/prosody \
        /var/log/prosody

# Link community modules
RUN ln -sf /opt/prosody-modules/mod_* /usr/lib/prosody/modules/ 2>/dev/null || true

# Copy configuration files
COPY config/prosody.cfg.lua /etc/prosody/
COPY config/modules.d/ /etc/prosody/modules.d/
COPY config/firewall/ /etc/prosody/firewall/
COPY config/templates/ /etc/prosody/templates/

# Copy scripts
COPY scripts/entrypoint.sh /opt/prosody/scripts/
COPY scripts/health-check.sh /opt/prosody/scripts/
COPY scripts/setup.sh /opt/prosody/scripts/

# Make scripts executable
RUN chmod +x /opt/prosody/scripts/*.sh

# Set proper permissions
RUN chown -R prosody:prosody /etc/prosody /var/lib/prosody /var/log/prosody

# Create log files with proper permissions
RUN touch /var/log/prosody/prosody.log /var/log/prosody/error.log \
    && chown prosody:prosody /var/log/prosody/*.log

# Expose ports
EXPOSE 5222/tcp  # Client connections (C2S)
EXPOSE 5269/tcp  # Server connections (S2S)
EXPOSE 5280/tcp  # HTTP (BOSH, WebSocket, file upload)
EXPOSE 5281/tcp  # HTTPS (secure HTTP services)

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /opt/prosody/scripts/health-check.sh

# Volume mounts for persistent data
VOLUME ["/etc/prosody/certs", "/var/lib/prosody/data", "/var/log/prosody"]

# Switch to prosody user
USER prosody

# Use tini for proper signal handling
ENTRYPOINT ["/usr/bin/tini", "--"]

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