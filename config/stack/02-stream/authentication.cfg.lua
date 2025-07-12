-- Layer 02: Stream - Authentication Configuration
-- SASL authentication mechanisms and policies
-- RFC 4422: Simple Authentication and Security Layer (SASL)
-- XEP-0388: Extensible SASL Profile

-- Authentication modules
-- All modern SASL mechanisms and authentication methods
modules_enabled = {
	"saslauth", -- Core SASL authentication
	"auth_internal_hashed", -- Internal hashed password storage
	"auth_internal_plain", -- Internal plaintext storage (dev only)
	"register", -- In-band registration (XEP-0077)
	"register_web", -- Web-based registration
	"limits", -- Rate limiting for auth attempts
	"auth_anonymous", -- Anonymous authentication
	"auth_external", -- External authentication
	"sasl2", -- SASL 2.0 (XEP-0388)
	"sasl2_bind2", -- SASL 2.0 with BIND 2.0 (XEP-0386)
	"sasl2_fast", -- SASL 2.0 FAST mechanism
}

-- SASL mechanisms configuration
-- Order matters - listed in preference order
sasl_mechanisms = {
	-- Modern mechanisms (preferred)
	"SCRAM-SHA-256-PLUS", -- SCRAM with channel binding
	"SCRAM-SHA-256", -- SCRAM-SHA-256 (RFC 7677)
	"SCRAM-SHA-1-PLUS", -- SCRAM-SHA-1 with channel binding
	"SCRAM-SHA-1", -- SCRAM-SHA-1 (RFC 5802)

	-- OAuth and external mechanisms
	"OAUTHBEARER", -- OAuth 2.0 Bearer tokens (RFC 7628)
	"EXTERNAL", -- External authentication (client certs)

	-- Legacy mechanisms (for compatibility)
	"DIGEST-MD5", -- DIGEST-MD5 (deprecated but supported)
	"PLAIN", -- PLAIN mechanism (only over TLS)

	-- Anonymous access
	"ANONYMOUS", -- Anonymous authentication
}

-- SASL 2.0 configuration
-- XEP-0388: Extensible SASL Profile
sasl2_config = {
	enabled = true,

	-- Inline features during SASL 2.0
	inline_features = {
		"bind2", -- Resource binding (XEP-0386)
		"sm", -- Stream management (XEP-0198)
		"csi", -- Client state indication (XEP-0352)
	},

	-- FAST authentication
	fast = {
		enabled = true,
		token_lifetime = 3600, -- 1 hour token lifetime
		max_tokens_per_user = 5, -- Maximum 5 active tokens per user
	},

	-- Channel binding
	channel_binding = {
		enabled = true,
		required = false, -- Optional but recommended
		types = {
			"tls-server-end-point", -- TLS server certificate binding
			"tls-unique", -- TLS unique channel binding
		},
	},
}

-- Authentication storage backends
-- Multiple storage options for different use cases
authentication_storage = {
	-- Default authentication provider
	default = "internal_hashed",

	-- Provider-specific configuration
	providers = {
		-- Internal hashed storage (recommended)
		internal_hashed = {
			store = "accounts",
			hash_algorithm = "SHA-256", -- SHA-256 for password hashing
			salt_length = 16, -- 16-byte salt
			iteration_count = 10000, -- PBKDF2 iterations
		},

		-- Internal plain storage (development only)
		internal_plain = {
			store = "accounts",
			-- WARNING: Only use for development/testing
		},

		-- LDAP authentication
		ldap = {
			hostname = "ldap.example.com",
			port = 636, -- LDAPS port
			use_tls = true,
			base_dn = "ou=users,dc=example,dc=com",
			filter = "(uid=$user)",
			bind_dn = "cn=prosody,ou=services,dc=example,dc=com",
			bind_password = "password",
		},

		-- External authentication script
		external = {
			command = "/usr/local/bin/prosody-auth",
			timeout = 5, -- 5 second timeout
		},

		-- Anonymous authentication
		anonymous = {
			allow_unencrypted = false, -- Require TLS for anonymous
			random_username = true, -- Generate random usernames
		},
	},
}

-- Registration policies
-- Control how users can register accounts
registration_config = {
	-- In-band registration (XEP-0077)
	inband = {
		enabled = true,
		min_username_length = 3,
		max_username_length = 20,
		min_password_length = 8,

		-- Registration restrictions
		restrictions = {
			ip_limit = 3, -- Max 3 registrations per IP per day
			time_limit = 86400, -- 24 hour limit window
			require_email = false, -- Email verification required
			require_invitation = false, -- Invitation code required
		},

		-- Username validation
		username_validation = {
			allowed_chars = "abcdefghijklmnopqrstuvwxyz0123456789_-",
			forbidden_words = {
				"admin",
				"administrator",
				"root",
				"system",
				"support",
				"help",
				"abuse",
				"postmaster",
			},
		},
	},

	-- Web registration
	web = {
		enabled = true,
		url = "/register",
		template = "register.html",

		-- CAPTCHA integration
		captcha = {
			enabled = false, -- Enable for production
			provider = "recaptcha", -- recaptcha, hcaptcha
			site_key = "",
			secret_key = "",
		},

		-- Email verification
		email_verification = {
			enabled = false,
			smtp_server = "localhost",
			smtp_port = 587,
			smtp_username = "",
			smtp_password = "",
			from_address = "noreply@localhost",
			subject = "XMPP Account Verification",
		},
	},
}

-- Password policies
-- Enforce strong password requirements
password_policy = {
	enabled = true,

	-- Strength requirements
	min_length = 8,
	max_length = 128,
	require_uppercase = true,
	require_lowercase = true,
	require_numbers = true,
	require_symbols = false,

	-- Common password checking
	check_common_passwords = true,
	common_password_file = "/usr/share/dict/common-passwords",

	-- Password history
	history = {
		enabled = true,
		remember_count = 5, -- Remember last 5 passwords
	},

	-- Password expiration
	expiration = {
		enabled = false, -- Disable by default
		max_age_days = 90, -- 90 day expiration
		warning_days = 7, -- Warn 7 days before expiration
	},
}

-- Multi-factor authentication
-- Additional security layers
mfa_config = {
	enabled = false, -- Enable when ready

	-- TOTP (Time-based One-Time Password)
	totp = {
		enabled = false,
		issuer = "XMPP Server",
		window = 1, -- Allow 1 time step variance
		backup_codes = 10, -- Generate 10 backup codes
	},

	-- WebAuthn/FIDO2
	webauthn = {
		enabled = false,
		rp_name = "XMPP Server",
		rp_id = "localhost",
		require_resident_key = false,
		user_verification = "preferred",
	},

	-- SMS verification
	sms = {
		enabled = false,
		provider = "twilio", -- twilio, nexmo, etc.
		api_key = "",
		api_secret = "",
	},
}

-- Session management
-- Control authenticated sessions
session_management = {
	-- Session limits
	max_sessions_per_user = 10, -- Maximum concurrent sessions

	-- Session timeout
	idle_timeout = 3600, -- 1 hour idle timeout
	absolute_timeout = 86400, -- 24 hour absolute timeout

	-- Session tracking
	track_location = true, -- Track login locations
	track_devices = true, -- Track login devices

	-- Concurrent session handling
	concurrent_sessions = {
		policy = "allow", -- allow, replace, deny
		notify_other_sessions = true, -- Notify other sessions of new login
	},
}

-- Authentication security
-- Security measures for authentication
auth_security = {
	-- Brute force protection
	brute_force = {
		enabled = true,
		max_attempts = 5, -- Lock after 5 failed attempts
		lockout_duration = 300, -- 5 minute lockout
		lockout_progression = true, -- Increase lockout time with repeated failures
	},

	-- Account lockout
	account_lockout = {
		enabled = true,
		max_failures = 10, -- Lock account after 10 total failures
		lockout_duration = 3600, -- 1 hour account lockout
		admin_unlock = true, -- Allow admin to unlock accounts
	},

	-- Suspicious activity detection
	anomaly_detection = {
		enabled = true,
		track_login_patterns = true,
		track_location_changes = true,
		track_device_changes = true,
		alert_threshold = 3, -- Alert after 3 anomalies
	},
}

-- Authentication logging
-- Comprehensive authentication event logging
auth_logging = {
	log_level = "info",

	-- Events to log
	log_events = {
		successful_auth = true,
		failed_auth = true,
		account_creation = true,
		account_deletion = true,
		password_changes = true,
		lockouts = true,
		anomalies = true,
	},

	-- Log format
	log_format = "structured", -- structured, plain
	include_ip = true,
	include_user_agent = true,
	include_timestamp = true,

	-- Log retention
	retention_days = 90, -- Keep auth logs for 90 days
}
