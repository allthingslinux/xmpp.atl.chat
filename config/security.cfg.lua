-- ============================================================================
-- SECURITY CONFIGURATION
-- ============================================================================
-- Encryption, authentication, TLS settings, and security policies

-- ============================================================================
-- ENCRYPTION AND AUTHENTICATION
-- ============================================================================

-- Enforce encryption for all connections
c2s_require_encryption = true
s2s_require_encryption = true
s2s_secure_auth = true

-- Disable insecure authentication
allow_unencrypted_plain_auth = false
authentication = "internal_hashed"

-- SASL mechanisms with channel binding support (XMPP Safeguarding Manifesto)
sasl_mechanisms = {
	"SCRAM-SHA-256-PLUS",
	"SCRAM-SHA-1-PLUS",
	"SCRAM-SHA-256",
	"SCRAM-SHA-1",
}

-- ============================================================================
-- TLS CONFIGURATION
-- ============================================================================

-- Modern TLS configuration
ssl = {
	-- Use TLS 1.3 and above (fallback to 1.2 for compatibility)
	protocol = "tlsv1_2+",
	-- Modern cipher suites - prioritize ECDHE and ChaCha20
	ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!SHA1:!AESCCM",
	-- Use secure curves
	curve = "secp384r1",
	-- Disable insecure versions
	options = { "no_sslv2", "no_sslv3", "no_tlsv1", "no_tlsv1_1" },
	-- Certificate verification options
	verifyext = { "lsec_continue", "lsec_ignore_purpose" },
	-- Enable TLS 1.3 specific options
	dhparam = "/etc/prosody/certs/dhparam.pem",
}

-- ============================================================================
-- FIREWALL CONFIGURATION
-- ============================================================================

-- Load firewall rules if security is enabled
if os.getenv("PROSODY_ENABLE_SECURITY") ~= "false" then
	firewall_scripts = {
		"/etc/prosody/firewall/anti-spam.pfw",
		"/etc/prosody/firewall/rate-limit.pfw",
		"/etc/prosody/firewall/blacklist.pfw",
	}
end

-- ============================================================================
-- SECURITY POLICIES
-- ============================================================================

-- Cross-domain policy for web clients
cross_domain_bosh = false
cross_domain_websocket = false

-- Disable directory browsing for HTTP services
http_index_files = {}

-- Security headers for HTTP services
http_headers = {
	["X-Frame-Options"] = "DENY",
	["X-Content-Type-Options"] = "nosniff",
	["X-XSS-Protection"] = "1; mode=block",
	["Referrer-Policy"] = "strict-origin-when-cross-origin",
	["Content-Security-Policy"] = "default-src 'self'",
}

-- Disable server version disclosure in error pages
hide_os_type = true
