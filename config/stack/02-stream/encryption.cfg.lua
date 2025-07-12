-- Layer 02: Stream - Encryption Configuration
-- XEP-0384: OMEMO Encryption, XEP-0373: OpenPGP for XMPP, XEP-0027: Current Jabber OpenPGP Usage
-- Provides end-to-end encryption capabilities for enhanced privacy and security

local encryption_config = {
	-- OMEMO Multi-End Message and Object Encryption (XEP-0384)
	-- Modern, forward-secure end-to-end encryption
	omemo = {
		-- Core OMEMO support
		"omemo_all_access", -- Allow OMEMO for all users
		"omemo_policy", -- Policy enforcement for OMEMO

		-- OMEMO extensions and improvements
		"omemo_fallback", -- Fallback mechanisms for OMEMO
		"omemo_self_messages", -- Support for self-messages in OMEMO

		-- Device management for OMEMO
		"omemo_device_list", -- Device list management
		"omemo_device_verification", -- Device verification support
	},

	-- OpenPGP Integration (XEP-0373, XEP-0027)
	-- Traditional OpenPGP encryption support
	openpgp = {
		"openpgp", -- XEP-0373: OpenPGP for XMPP
		"legacy_openpgp", -- XEP-0027: Current Jabber OpenPGP Usage (legacy)
		"openpgp_crypt", -- OpenPGP encryption/decryption
	},

	-- Encryption Discovery and Capabilities
	-- Help clients discover encryption capabilities
	discovery = {
		"encryption_policy", -- Encryption policy advertisement
		"carbons_adhoc", -- Message Carbons with encryption awareness
		"crypt_policy", -- Cryptographic policy enforcement
	},

	-- Key Management and Storage
	-- Secure key storage and management
	key_management = {
		"keyval_store", -- Key-value storage for encryption keys
		"pep_plus", -- Enhanced PEP for key distribution
		"pubsub_encrypted", -- Encrypted PubSub support
	},

	-- Encryption Metadata and Logging
	-- Handle encryption-related metadata
	metadata = {
		"encrypt_log", -- Encryption logging and audit
		"message_security_labels", -- Security labels for messages
		"encrypted_session_logging", -- Log encrypted session metadata
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

	-- Add OpenPGP support
	for _, module in ipairs(encryption_config.openpgp) do
		table.insert(core_modules, module)
	end

	-- Add discovery support
	for _, module in ipairs(encryption_config.discovery) do
		table.insert(core_modules, module)
	end

	-- Add key management (production and staging)
	if env_type ~= "development" then
		for _, module in ipairs(encryption_config.key_management) do
			table.insert(core_modules, module)
		end
	end

	-- Add metadata handling (production only for performance)
	if env_type == "production" then
		for _, module in ipairs(encryption_config.metadata) do
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
		enabled = true,
		url = "hkps://keys.openpgp.org", -- Default keyserver
		timeout = 30, -- Timeout in seconds
	},

	-- Legacy support (XEP-0027)
	legacy_support = {
		enabled = true, -- Support legacy OpenPGP
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
