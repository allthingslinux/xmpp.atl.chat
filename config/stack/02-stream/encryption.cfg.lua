-- Layer 02: Stream - Encryption Configuration
-- End-to-end encryption, key management, and cryptographic policies
-- OMEMO, OpenPGP, and encryption discovery/enforcement

local encryption_config = {
	-- OMEMO Multi-End Message and Object Encryption (XEP-0384)
	-- Modern, forward-secure end-to-end encryption
	omemo = {
		-- Core OMEMO support
		"omemo_all_access", -- Allow OMEMO for all users (real community module)
	},

	-- OpenPGP Integration (XEP-0373, XEP-0027)
	-- Traditional OpenPGP encryption support
	openpgp = {
		-- Note: Most OpenPGP modules are client-side or not widely available
		-- Keeping this section minimal with only well-established modules
	},

	-- Encryption Discovery and Capabilities
	-- Help clients discover encryption capabilities
	discovery = {
		"encryption_policy", -- Encryption policy advertisement (if available)
	},

	-- Security Labels (XEP-0258)
	-- Security classification for messages
	security_labels = {
		"seclabels", -- Security Labels support (real community module)
	},
}

-- Apply encryption configuration based on environment
local function apply_encryption_config()
	local env_type = prosody.config.get("*", "environment_type") or "production"

	-- Core encryption modules (always enabled)
	local core_modules = {}

	-- Add OMEMO support
	for _, module in ipairs(encryption_config.omemo) do
		table.insert(core_modules, module)
	end

	-- Add discovery support (if modules exist)
	for _, module in ipairs(encryption_config.discovery) do
		table.insert(core_modules, module)
	end

	-- Add security labels (optional, for high-security environments)
	if env_type == "production" then
		for _, module in ipairs(encryption_config.security_labels) do
			table.insert(core_modules, module)
		end
	end

	return core_modules
end

-- OMEMO Configuration
-- XEP-0384: OMEMO Encryption configuration
omemo_policy = {
	-- Default policy for OMEMO usage
	default_policy = "optional", -- optional, required, disabled

	-- Per-domain policies
	domain_policies = {
		-- Example: require OMEMO for sensitive domains
		-- ["secure.example.com"] = "required",
	},

	-- Device limits
	max_devices_per_user = 10, -- Limit devices per user
	device_verification_required = false, -- Require device verification

	-- Key rotation
	key_rotation_interval = 7 * 24 * 3600, -- 7 days in seconds
	max_key_age = 30 * 24 * 3600, -- 30 days maximum key age
}

-- OpenPGP Configuration
-- XEP-0373 and XEP-0027 configuration
openpgp_config = {
	-- Key server configuration
	keyserver = {
		enabled = false, -- Disabled by default (most servers don't support this)
		url = "hkps://keys.openpgp.org", -- Default keyserver
		timeout = 30, -- Timeout in seconds
	},

	-- Legacy support (XEP-0027)
	legacy_support = {
		enabled = false, -- Disabled by default (deprecated)
		warn_deprecated = true, -- Warn about deprecated usage
	},

	-- Key validation
	key_validation = {
		require_valid_signature = true, -- Require valid signatures
		check_key_expiry = true, -- Check key expiration
		min_key_size = 2048, -- Minimum key size in bits
	},
}

-- Encryption Policy Configuration
-- Global encryption policies and enforcement
encryption_policy = {
	-- Default encryption requirements
	default_policy = {
		c2s = "optional", -- Client-to-server encryption
		s2s = "required", -- Server-to-server encryption (always required)
		muc = "optional", -- Multi-user chat encryption
		pubsub = "optional", -- PubSub encryption
	},

	-- Compliance requirements
	compliance = {
		log_unencrypted = false, -- Log unencrypted communications
		reject_unencrypted_s2s = true, -- Reject unencrypted S2S
		require_forward_secrecy = false, -- Require forward secrecy
	},

	-- Cipher preferences
	cipher_preferences = {
		-- Preferred encryption algorithms
		"aes256-gcm",
		"aes128-gcm",
		"chacha20-poly1305",
	},
}

-- Message Security Labels
-- XEP-0258: Security Labels in XMPP
security_labels_config = {
	enabled = false, -- Disabled by default

	-- Security label catalog
	catalog = {
		{
			label = "PUBLIC",
			color = "green",
			classification = "public",
		},
		{
			label = "INTERNAL",
			color = "yellow",
			classification = "internal",
		},
		{
			label = "CONFIDENTIAL",
			color = "red",
			classification = "confidential",
		},
	},

	-- Default label for unlabeled messages
	default_label = "PUBLIC",

	-- Require labels for certain domains
	required_domains = {},
}

-- Export configuration
return {
	modules = apply_encryption_config(),
	omemo_policy = omemo_policy,
	openpgp_config = openpgp_config,
	encryption_policy = encryption_policy,
	security_labels_config = security_labels_config,
}
