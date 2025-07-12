-- Layer 08: Integration - OAuth Configuration
-- OAuth 2.0 integration for external authentication and API access
-- Single Sign-On (SSO) with external providers and API authentication
-- Note: OAuth support in Prosody is limited - most OAuth integration happens at client level

local oauth_config = {
	-- OAuth Modules
	-- Limited OAuth support in Prosody core
	oauth_modules = {
		-- Note: Prosody has limited built-in OAuth support
		-- Most OAuth integration happens at the client/application level
		-- "oauth2", -- Basic OAuth 2.0 support (community, if available)
	},

	-- External Authentication
	-- Integration with external OAuth providers
	external_auth = {
		-- External authentication modules
		-- "auth_oauth", -- OAuth authentication (community, if available)
		-- "auth_external", -- External authentication script support (community)
	},

	-- API Authentication
	-- OAuth for API access to XMPP services
	api_auth = {
		-- API authentication modules
		-- "api_oauth", -- OAuth for API access (community, if available)
		-- "rest_oauth", -- OAuth for REST API (community, if available)
	},
}

-- OAuth Provider Configuration
-- Configure OAuth 2.0 providers and settings
local oauth_provider_config = {
	-- OAuth 2.0 providers
	providers = {
		-- Google OAuth
		google = {
			enabled = false,
			client_id = "your-google-client-id",
			client_secret = "your-google-client-secret",
			auth_url = "https://accounts.google.com/o/oauth2/auth",
			token_url = "https://oauth2.googleapis.com/token",
			scope = "openid email profile",
		},

		-- Microsoft Azure AD
		microsoft = {
			enabled = false,
			client_id = "your-azure-client-id",
			client_secret = "your-azure-client-secret",
			tenant_id = "your-tenant-id",
			auth_url = "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize",
			token_url = "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token",
			scope = "openid email profile",
		},

		-- GitHub OAuth
		github = {
			enabled = false,
			client_id = "your-github-client-id",
			client_secret = "your-github-client-secret",
			auth_url = "https://github.com/login/oauth/authorize",
			token_url = "https://github.com/login/oauth/access_token",
			scope = "user:email",
		},

		-- Custom OAuth provider
		custom = {
			enabled = false,
			client_id = "your-custom-client-id",
			client_secret = "your-custom-client-secret",
			auth_url = "https://your-provider.com/oauth/authorize",
			token_url = "https://your-provider.com/oauth/token",
			user_info_url = "https://your-provider.com/oauth/userinfo",
			scope = "openid email profile",
		},
	},

	-- OAuth flow configuration
	flow_config = {
		-- Authorization code flow (recommended)
		authorization_code = {
			enabled = true,
			redirect_uri = "https://your-domain.com/oauth/callback",
			state_parameter = true, -- Use state parameter for security
			pkce_enabled = true, -- Enable PKCE for additional security
		},

		-- Implicit flow (not recommended for security reasons)
		implicit = {
			enabled = false,
			redirect_uri = "https://your-domain.com/oauth/callback",
		},

		-- Client credentials flow (for server-to-server)
		client_credentials = {
			enabled = false,
			scope = "api:read api:write",
		},
	},
}

-- OAuth Authentication Configuration
-- Configure OAuth-based authentication behavior
local oauth_auth_config = {
	-- Authentication settings
	auth_settings = {
		-- Allow OAuth as authentication method
		allow_oauth_auth = false, -- Disabled by default

		-- OAuth authentication flow
		auth_flow = "authorization_code", -- authorization_code, implicit

		-- User mapping from OAuth to XMPP
		user_mapping = {
			username_claim = "preferred_username", -- OAuth claim for username
			email_claim = "email", -- OAuth claim for email
			name_claim = "name", -- OAuth claim for full name

			-- Username generation strategy
			username_strategy = "email", -- email, claim, custom
			domain_mapping = "example.com", -- Default domain for OAuth users
		},
	},

	-- Token management
	token_management = {
		-- Access token settings
		access_token_lifetime = 3600, -- 1 hour
		refresh_token_lifetime = 86400 * 30, -- 30 days

		-- Token storage
		token_storage = "memory", -- memory, file, database
		token_encryption = true, -- Encrypt stored tokens

		-- Token validation
		validate_tokens = true, -- Validate tokens with provider
		validation_interval = 300, -- Validate every 5 minutes
	},

	-- User provisioning
	user_provisioning = {
		auto_create_users = false, -- Auto-create XMPP users from OAuth
		sync_user_attributes = true, -- Sync user attributes from OAuth
		update_on_login = true, -- Update user info on each OAuth login

		-- Default user settings for OAuth users
		default_user_config = {
			quota = 1024 * 1024 * 1024, -- 1GB default quota
			default_groups = {}, -- Default XMPP groups
		},
	},
}

-- OAuth API Configuration
-- Configure OAuth for API access to XMPP services
local oauth_api_config = {
	-- API OAuth settings
	api_settings = {
		-- Enable OAuth for API access
		enable_api_oauth = false, -- Disabled by default

		-- OAuth scopes for API access
		api_scopes = {
			"xmpp:read", -- Read XMPP data
			"xmpp:write", -- Write XMPP data
			"xmpp:admin", -- Administrative access
			"roster:read", -- Read roster
			"roster:write", -- Modify roster
			"message:send", -- Send messages
		},

		-- API endpoints that require OAuth
		protected_endpoints = {
			"/api/users",
			"/api/roster",
			"/api/messages",
			"/api/admin",
		},
	},

	-- API token configuration
	api_tokens = {
		-- Token types
		bearer_tokens = true, -- Support Bearer tokens
		api_keys = false, -- Support API keys

		-- Token validation
		token_introspection = true, -- Support token introspection
		introspection_endpoint = "/oauth/introspect",

		-- Rate limiting per token
		rate_limiting = {
			enabled = true,
			requests_per_minute = 1000,
			burst_limit = 100,
		},
	},
}

-- OAuth Security Configuration
-- Security settings for OAuth integration
local oauth_security = {
	-- OAuth security settings
	oauth_security_settings = {
		-- PKCE (Proof Key for Code Exchange)
		pkce_required = true, -- Require PKCE for public clients
		pkce_method = "S256", -- S256 or plain

		-- State parameter
		state_required = true, -- Require state parameter
		state_entropy = 32, -- State parameter entropy (bytes)

		-- Nonce parameter (for OpenID Connect)
		nonce_required = false, -- Require nonce parameter
		nonce_entropy = 32, -- Nonce parameter entropy (bytes)
	},

	-- Token security
	token_security = {
		-- Token encryption
		encrypt_tokens = true, -- Encrypt tokens at rest
		encryption_algorithm = "AES-256-GCM",

		-- Token signing
		sign_tokens = true, -- Sign tokens (JWT)
		signing_algorithm = "RS256", -- RS256, HS256, etc.

		-- Token validation
		validate_issuer = true, -- Validate token issuer
		validate_audience = true, -- Validate token audience
		validate_expiration = true, -- Validate token expiration
		clock_skew_tolerance = 300, -- 5 minutes clock skew tolerance
	},

	-- Transport security
	transport_security = {
		-- TLS requirements
		require_tls = true, -- Require TLS for OAuth flows
		min_tls_version = "1.2", -- Minimum TLS version

		-- Certificate validation
		validate_certificates = true, -- Validate OAuth provider certificates
		trusted_ca_file = "/etc/ssl/certs/ca-certificates.crt",
	},
}

-- OAuth Integration Utilities
-- Helper functions for OAuth integration management
local oauth_utilities = {
	-- Validate OAuth configuration
	validate_oauth_config = function(config)
		local validation = {
			valid = true,
			errors = {},
			warnings = {},
		}

		-- Validate provider configuration
		for provider_name, provider_config in pairs(config.providers or {}) do
			if provider_config.enabled then
				if not provider_config.client_id then
					table.insert(validation.errors, provider_name .. ": client_id is required")
					validation.valid = false
				end

				if not provider_config.client_secret then
					table.insert(validation.errors, provider_name .. ": client_secret is required")
					validation.valid = false
				end

				if not provider_config.auth_url then
					table.insert(validation.errors, provider_name .. ": auth_url is required")
					validation.valid = false
				end
			end
		end

		return validation
	end,

	-- Test OAuth provider connection
	test_oauth_provider = function(provider_name, config)
		-- This would test the OAuth provider connection
		return {
			provider_reachable = true,
			configuration_valid = true,
			endpoints_accessible = true,
			response_time = 150, -- milliseconds
		}
	end,

	-- Get OAuth statistics
	get_oauth_stats = function()
		-- This would return real-time OAuth integration statistics
		return {
			total_oauth_users = 125,
			active_oauth_sessions = 15,
			oauth_auth_success_rate = 96.8, -- percentage
			token_validation_success_rate = 99.2, -- percentage
			average_auth_time = 1200, -- milliseconds
		}
	end,

	-- Generate OAuth authorization URL
	generate_auth_url = function(provider, state, redirect_uri)
		-- This would generate an OAuth authorization URL
		local base_url = "https://provider.com/oauth/authorize"
		local params = {
			"client_id=" .. provider.client_id,
			"response_type=code",
			"scope=" .. (provider.scope or ""),
			"state=" .. state,
			"redirect_uri=" .. redirect_uri,
		}

		if provider.pkce_enabled then
			-- Add PKCE parameters
			table.insert(params, "code_challenge=" .. "challenge")
			table.insert(params, "code_challenge_method=S256")
		end

		return base_url .. "?" .. table.concat(params, "&")
	end,
}

-- OAuth Monitoring and Diagnostics
-- Tools for monitoring OAuth integration health and performance
local oauth_monitoring = {
	-- OAuth flow monitoring
	flow_monitoring = {
		enabled = true,
		track_auth_attempts = true,
		track_token_requests = true,
		track_success_rates = true,
		track_error_rates = true,
	},

	-- Performance monitoring
	performance_monitoring = {
		enabled = true,
		track_response_times = true,
		track_provider_latency = true,
		performance_threshold = 2000, -- Alert if auth time > 2 seconds
	},

	-- Security monitoring
	security_monitoring = {
		enabled = true,
		track_failed_attempts = true,
		track_suspicious_activity = true,
		alert_on_security_events = true,

		-- Security thresholds
		max_failed_attempts = 10, -- Per IP per hour
		suspicious_activity_threshold = 50, -- Requests per minute
	},

	-- Logging configuration
	logging = {
		log_level = "info", -- debug, info, warn, error
		log_auth_attempts = false, -- Log auth attempts (privacy consideration)
		log_token_operations = false, -- Log token operations (security consideration)
		log_errors = true, -- Always log errors
		log_security_events = true, -- Log security events
	},
}

-- Export configuration
return {
	modules = {
		-- OAuth modules (commented out by default - limited support in Prosody)
		-- oauth = oauth_config.oauth_modules,
		-- external_auth = oauth_config.external_auth,
		-- api_auth = oauth_config.api_auth,
	},

	providers = oauth_provider_config,
	auth = oauth_auth_config,
	api = oauth_api_config,
	security = oauth_security,
	utilities = oauth_utilities,
	monitoring = oauth_monitoring,
}
