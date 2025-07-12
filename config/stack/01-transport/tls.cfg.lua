-- Layer 01: Transport - TLS/SSL Configuration
-- Transport Layer Security configuration for XMPP connections
-- Handles encryption, certificates, and cryptographic settings

-- Certificate configuration
-- Automatic certificate management and paths
certificates = "certs"

-- SSL/TLS configuration for different connection types
ssl = {
	-- Client-to-Server TLS configuration
	c2s = {
		key = "certs/localhost.key",
		certificate = "certs/localhost.crt",

		-- Modern TLS configuration
		protocol = "tlsv1_2+", -- TLS 1.2 and above only
		ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS",
		options = {
			"no_sslv2",
			"no_sslv3", -- Disable legacy SSL versions
			"no_tlsv1",
			"no_tlsv1_1", -- Disable TLS 1.0 and 1.1
			"cipher_server_preference", -- Use server cipher preference
			"no_compression", -- Disable TLS compression (CRIME attack)
			"single_dh_use", -- Use new DH key for each connection
			"single_ecdh_use", -- Use new ECDH key for each connection
		},

		-- Diffie-Hellman parameters for forward secrecy
		dhparam = "certs/dh-2048.pem",

		-- Certificate verification
		verify = "none", -- Client certificates optional
		cafile = "/etc/ssl/certs/ca-certificates.crt",
	},

	-- Server-to-Server TLS configuration
	s2s = {
		key = "certs/localhost.key",
		certificate = "certs/localhost.crt",

		-- Server-to-server specific settings
		protocol = "tlsv1_2+",
		ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS",
		options = {
			"no_sslv2",
			"no_sslv3",
			"no_tlsv1",
			"no_tlsv1_1",
			"cipher_server_preference",
			"no_compression",
			"single_dh_use",
			"single_ecdh_use",
		},

		dhparam = "certs/dh-2048.pem",

		-- Server certificate verification
		verify = "optional", -- Verify if certificate provided
		cafile = "/etc/ssl/certs/ca-certificates.crt",
	},

	-- HTTPS configuration for web services
	https = {
		key = "certs/localhost.key",
		certificate = "certs/localhost.crt",

		-- Web service TLS settings
		protocol = "tlsv1_2+",
		ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS",
		options = {
			"no_sslv2",
			"no_sslv3",
			"no_tlsv1",
			"no_tlsv1_1",
			"cipher_server_preference",
			"no_compression",
			"single_dh_use",
			"single_ecdh_use",
		},

		dhparam = "certs/dh-2048.pem",
	},
}

-- STARTTLS configuration
-- XEP-0368: SRV records for XMPP over TLS
c2s_require_encryption = true -- Require encryption for clients
s2s_require_encryption = true -- Require encryption for servers
s2s_secure_auth = true -- Require valid certificates for s2s

-- Certificate management
-- Automatic certificate generation and renewal support
certificates_config = {
	-- Let's Encrypt / ACME support
	acme = {
		enabled = false, -- Enable when ready for production
		staging = true, -- Use staging environment for testing
		email = "admin@localhost", -- Contact email for certificate authority
	},

	-- Self-signed certificate generation
	self_signed = {
		enabled = true, -- Generate self-signed certs if none exist
		key_size = 2048, -- RSA key size
		days_valid = 365, -- Certificate validity period
	},
}

-- TLS session resumption
-- Improve performance by reusing TLS sessions
tls_session_cache = {
	c2s = 1000, -- Cache 1000 client sessions
	s2s = 100, -- Cache 100 server sessions
	timeout = 3600, -- 1 hour session timeout
}

-- OCSP (Online Certificate Status Protocol)
-- Real-time certificate revocation checking
ocsp = {
	enabled = false, -- Enable for production with valid certs
	timeout = 5, -- 5 second OCSP timeout
}

-- TLS security headers for HTTPS
-- Additional security measures for web services
https_security_headers = {
	["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains",
	["X-Frame-Options"] = "DENY",
	["X-Content-Type-Options"] = "nosniff",
	["Referrer-Policy"] = "strict-origin-when-cross-origin",
	["Content-Security-Policy"] = "default-src 'self'",
}

-- Cipher suite preferences
-- Modern, secure cipher configuration following best practices
cipher_preferences = {
	-- AEAD ciphers (Authenticated Encryption with Associated Data)
	"ECDHE-ECDSA-AES256-GCM-SHA384",
	"ECDHE-RSA-AES256-GCM-SHA384",
	"ECDHE-ECDSA-CHACHA20-POLY1305",
	"ECDHE-RSA-CHACHA20-POLY1305",
	"ECDHE-ECDSA-AES128-GCM-SHA256",
	"ECDHE-RSA-AES128-GCM-SHA256",

	-- DHE ciphers for compatibility
	"DHE-RSA-AES256-GCM-SHA384",
	"DHE-RSA-AES128-GCM-SHA256",
}
