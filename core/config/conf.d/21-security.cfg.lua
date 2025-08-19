-- ===============================================
-- SECURITY (limits, registration, firewall)
-- ===============================================

limits = {
	c2s = { rate = "10kb/s", burst = "25kb", stanza_size = 1024 * 256 },
	s2s = { rate = "30kb/s", burst = "100kb", stanza_size = 1024 * 512 },
	http_upload = { rate = "2mb/s", burst = "10mb" },
}

-- max_connections_per_ip = 5

-- registration_throttle_max = 3
-- registration_throttle_period = 3600

-- ===============================================
-- TLS/SSL SECURITY
-- ===============================================
-- Global TLS configuration. See:
-- https://prosody.im/doc/certificates
-- https://prosody.im/doc/security
ssl = {
	protocol = "tlsv1_2+",
	ciphers = "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20:!aNULL:!MD5:!DSS",
	curve = "secp384r1",
	options = { "cipher_server_preference", "single_dh_use", "single_ecdh_use" },
}

-- Let's Encrypt certificate location (mounted into the container)
certificates = "certs"

-- Require encryption and secure s2s auth
c2s_require_encryption = true
s2s_require_encryption = true
s2s_secure_auth = true
allow_unencrypted_plain_auth = false

-- Channel binding strengthens SASL against MITM
tls_channel_binding = true

-- ===============================================
-- AUTHENTICATION & ACCOUNT POLICY
-- ===============================================
-- Hashed password storage and preferred SASL mechanisms
authentication = "internal_hashed"
sasl_mechanisms = {
	"SCRAM-SHA-256",
	"SCRAM-SHA-1",
	"DIGEST-MD5",
	"PLAIN", -- only over encrypted channels
}

-- Account lifecycle and registration hygiene
user_account_management = {
	grace_period = 7 * 24 * 3600,
	deletion_confirmation = true,
}

-- Disallow common/abusive usernames during registration
block_registrations_users = {
	"administrator",
	"admin",
	"root",
	"postmaster",
	"xmpp",
	"jabber",
	"contact",
	"mail",
	"abuse",
	"support",
	"security",
}
block_registrations_require = "^[a-zA-Z0-9_.-]+$"

-- Inline firewall rules for mod_firewall
-- firewall_rules = [=[
-- %ZONE spam: log=debug
-- RATE: 10 (burst 15) on full-jid
-- TO: spam
-- DROP.

-- %LENGTH > 262144
-- BOUNCE: policy-violation (Stanza too large)
-- ]=]
