-- ===============================================
-- NETWORKING CONFIGURATION
-- ===============================================
-- This file centralizes all network- and port-related settings.
--
-- References:
-- - Port & network configuration docs:
--   https://prosody.im/doc/ports
-- - HTTP server docs:
--   https://prosody.im/doc/http
-- - Config basics and advanced directives:
--   https://prosody.im/doc/configure
--
-- IMPORTANT:
-- - Network options must be set in the GLOBAL section (i.e., not under
--   a VirtualHost/Component) per Prosody's design.
-- - Services can be individually overridden via <service>_ports and
--   <service>_interfaces (e.g., c2s_ports, s2s_interfaces, etc.).
-- - Private services (e.g., components, console) default to loopback.

-- ===============================================
-- Default service ports (override as needed)
-- ===============================================

-- Client-to-server (XMPP over TCP, STARTTLS-capable)
c2s_ports = { 5222 }

-- Client-to-server over direct TLS (XMPP over TLS)
-- Available since Prosody 0.12+
c2s_direct_tls_ports = { 5223 }

-- Server-to-server (federation)
s2s_ports = { 5269 }

-- Server-to-server over direct TLS
-- Available since Prosody 0.12+
s2s_direct_tls_ports = { 5270 }

-- External components (XEP-0114) — private by default
component_ports = { 5347 }

-- HTTP/HTTPS listener (mod_http)
-- Note: 5280 is private by default in Prosody 0.12+
http_ports = { 5280 }
https_ports = { 5281 }

-- ===============================================
-- Interfaces
-- ===============================================
-- By default Prosody listens on all interfaces. To restrict:
--   interfaces = { "127.0.0.1", "::1" }
-- The special "*" means all IPv4; "::" means all IPv6.

interfaces = { "127.0.0.1" } -- Restrict to loopback (adjust if public exposure is required)
local_interfaces = { "127.0.0.1" } -- Private services bind here by default

-- If you need to hint external/public addresses (behind NAT)
external_addresses = { }

-- ===============================================
-- IPv6
-- ===============================================
-- Enable IPv6 if your deployment supports it.
use_ipv6 = false

-- ===============================================
-- Backend & performance tuning
-- ===============================================
-- Available backends: "epoll" (default), "event" (libevent), "select" (legacy)
-- The setting name for libevent backend is "event" for compatibility.
network_backend = "event"

-- Common advanced network settings. See docs for full list.
-- https://prosody.im/doc/ports#advanced
network_settings = {
	read_timeout = 840, -- seconds; align with reverse proxy timeouts (~900s)
	-- send_timeout = 300,
	-- max_send_buffer_size = 1048576,
	-- tcp_backlog = 32,
}


