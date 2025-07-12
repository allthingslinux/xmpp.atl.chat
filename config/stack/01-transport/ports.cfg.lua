-- Layer 01: Transport - Port Bindings and Listeners
-- Network and transport layer configuration for XMPP server
-- This handles all network listeners and port configurations

-- Standard XMPP ports
-- RFC 6120: XMPP Core - defines standard port usage
-- XEP-0368: SRV records for XMPP over TLS

-- Client-to-Server (c2s) connections
-- Port 5222: Standard XMPP client connections (STARTTLS)
-- Port 5223: Legacy SSL/TLS direct connections (deprecated but supported)
c2s_require_encryption = true
c2s_ports = { 5222 }
legacy_ssl_ports = { 5223 }

-- Server-to-Server (s2s) connections
-- Port 5269: Standard server-to-server connections
-- XEP-0220: Server Dialback for authentication
s2s_require_encryption = true
s2s_ports = { 5269 }

-- HTTP ports for web services
-- Port 5280: HTTP (BOSH, file upload, admin interface)
-- Port 5281: HTTPS (secure web services)
http_ports = { 5280 }
https_ports = { 5281 }

-- Component connections
-- Port 5347: External component protocol (XEP-0114)
-- Used for gateways, transports, and external services
component_ports = { 5347 }

-- Network interface bindings
-- Listen on all interfaces by default, can be restricted for security
interfaces = { "*" }

-- IPv6 support
-- Enable dual-stack IPv4/IPv6 operation
use_ipv6 = true

-- Connection limits and timeouts
-- Prevent resource exhaustion and abuse
c2s_timeout = 300 -- 5 minutes for client connections
s2s_timeout = 300 -- 5 minutes for server connections
component_timeout = 300 -- 5 minutes for component connections

-- Maximum connections per IP
-- Prevent connection flooding attacks
limits = {
	c2s = {
		rate = "10kb/s", -- Rate limiting per connection
	},
	s2s = {
		rate = "30kb/s", -- Higher rate for server connections
	},
}

-- TCP keepalive settings
-- Detect broken connections and clean up resources
tcp_keepalives = true

-- Buffer sizes for network operations
-- Optimize for different connection types
send_buffer_size_limit = 1024 * 1024 -- 1MB send buffer
read_buffer_size_limit = 1024 * 512 -- 512KB read buffer

-- Network security settings
-- Basic transport-level security measures
c2s_stanza_size_limit = 1024 * 256 -- 256KB max stanza size
s2s_stanza_size_limit = 1024 * 512 -- 512KB for server connections

-- Proxy protocol support (for load balancers)
-- XEP-0368: SRV records for XMPP over TLS
proxy_65_ports = { 7777 } -- SOCKS5 bytestreams (XEP-0065)

log_level = "info"
log = {
	info = "prosody.log",
	error = "prosody.err",
	-- Transport layer specific logging
	{ levels = { "error" }, to = "console" },
}
