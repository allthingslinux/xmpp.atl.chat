-- Layer 08: Integration - APIs Configuration
-- REST API and external service integration for XMPP server management
-- HTTP APIs for user management, messaging, and administrative functions
-- External service integration and programmatic access to XMPP functionality

local apis_config = {
	-- Core API Modules
	-- HTTP API and REST interface modules
	core_api = {
		"http", -- Core HTTP server (core)
		"http_files", -- Static file serving (core)
		-- "rest", -- REST API module (community, if available)
	},

	-- Administrative APIs
	-- APIs for server administration and management
	admin_api = {
		"admin_rest", -- REST API for administration (community)
		-- "admin_api", -- Administrative API (community, if available)
	},

	-- User Management APIs
	-- APIs for user account management
	user_api = {
		-- "user_management_api", -- User management API (community, if available)
		-- "roster_api", -- Roster management API (community, if available)
	},

	-- Messaging APIs
	-- APIs for sending and managing messages
	messaging_api = {
		-- "message_api", -- Message sending API (community, if available)
		-- "offline_api", -- Offline message API (community, if available)
	},

	-- Statistics APIs
	-- APIs for server statistics and monitoring
	stats_api = {
		"http_openmetrics", -- Prometheus metrics API (community)
		-- "stats_api", -- Statistics API (community, if available)
	},
}

-- API Configuration
-- Configure API endpoints and access control
local api_config = {
	-- API endpoints
	endpoints = {
		-- User management endpoints
		users = {
			enabled = false,
			base_path = "/api/v1/users",
			methods = { "GET", "POST", "PUT", "DELETE" },
			authentication_required = true,
			rate_limit = {
				requests_per_minute = 100,
				burst_limit = 20,
			},
		},

		-- Roster management endpoints
		roster = {
			enabled = false,
			base_path = "/api/v1/roster",
			methods = { "GET", "POST", "PUT", "DELETE" },
			authentication_required = true,
			rate_limit = {
				requests_per_minute = 200,
				burst_limit = 50,
			},
		},

		-- Message endpoints
		messages = {
			enabled = false,
			base_path = "/api/v1/messages",
			methods = { "GET", "POST" },
			authentication_required = true,
			rate_limit = {
				requests_per_minute = 500,
				burst_limit = 100,
			},
		},

		-- Administrative endpoints
		admin = {
			enabled = false,
			base_path = "/api/v1/admin",
			methods = { "GET", "POST", "PUT", "DELETE" },
			authentication_required = true,
			admin_required = true,
			rate_limit = {
				requests_per_minute = 50,
				burst_limit = 10,
			},
		},

		-- Statistics endpoints
		stats = {
			enabled = false,
			base_path = "/api/v1/stats",
			methods = { "GET" },
			authentication_required = true,
			rate_limit = {
				requests_per_minute = 60,
				burst_limit = 10,
			},
		},

		-- Health check endpoint
		health = {
			enabled = true,
			base_path = "/api/health",
			methods = { "GET" },
			authentication_required = false,
			rate_limit = {
				requests_per_minute = 1000,
				burst_limit = 100,
			},
		},
	},

	-- Global API settings
	global_settings = {
		-- API versioning
		api_version = "v1",
		version_header = "X-API-Version",

		-- Content types
		default_content_type = "application/json",
		supported_content_types = {
			"application/json",
			"application/xml",
			"text/plain",
		},

		-- Response format
		response_format = {
			include_metadata = true,
			include_timestamps = true,
			include_request_id = true,
			error_format = "rfc7807", -- RFC 7807 Problem Details
		},

		-- CORS settings
		cors = {
			enabled = false, -- Disabled by default for security
			allowed_origins = {
				-- "https://admin.example.com",
				-- "https://app.example.com",
			},
			allowed_methods = { "GET", "POST", "PUT", "DELETE", "OPTIONS" },
			allowed_headers = { "Content-Type", "Authorization", "X-API-Version" },
			max_age = 86400, -- 24 hours
		},
	},
}

-- API Authentication Configuration
-- Configure authentication methods for API access
local api_auth_config = {
	-- Authentication methods
	auth_methods = {
		-- API key authentication
		api_key = {
			enabled = false,
			header_name = "X-API-Key",
			query_param = "api_key",
			validate_keys = true,
		},

		-- Bearer token authentication
		bearer_token = {
			enabled = false,
			header_name = "Authorization",
			token_prefix = "Bearer ",
			validate_tokens = true,
		},

		-- Basic authentication
		basic_auth = {
			enabled = false,
			realm = "XMPP API",
			validate_credentials = true,
		},

		-- OAuth 2.0 authentication
		oauth2 = {
			enabled = false,
			token_introspection_endpoint = "/oauth/introspect",
			required_scopes = {
				users = { "user:read", "user:write" },
				roster = { "roster:read", "roster:write" },
				messages = { "message:send", "message:read" },
				admin = { "admin:read", "admin:write" },
			},
		},
	},

	-- API key management
	api_keys = {
		-- API key storage
		storage_backend = "internal", -- internal, database, external

		-- Key generation
		key_length = 32, -- API key length in bytes
		key_prefix = "xmpp_", -- API key prefix

		-- Key validation
		validate_keys = true,
		cache_validation = true,
		cache_timeout = 300, -- 5 minutes

		-- Key permissions
		default_permissions = {
			"user:read",
			"roster:read",
			"stats:read",
		},

		-- Key expiration
		default_expiration = 365 * 24 * 3600, -- 1 year
		max_expiration = 2 * 365 * 24 * 3600, -- 2 years
	},

	-- Session management
	session_management = {
		-- Session tokens
		enable_sessions = false,
		session_timeout = 3600, -- 1 hour
		session_storage = "memory", -- memory, database

		-- Session security
		secure_sessions = true,
		httponly_sessions = true,
		same_site = "strict", -- strict, lax, none
	},
}

-- API Security Configuration
-- Security settings for API access and data protection
local api_security = {
	-- Transport security
	transport_security = {
		-- TLS requirements
		require_tls = true, -- Require HTTPS for API access
		min_tls_version = "1.2", -- Minimum TLS version

		-- HSTS (HTTP Strict Transport Security)
		hsts = {
			enabled = true,
			max_age = 31536000, -- 1 year
			include_subdomains = true,
			preload = false,
		},
	},

	-- Request security
	request_security = {
		-- Request size limits
		max_request_size = 10 * 1024 * 1024, -- 10MB
		max_json_depth = 10, -- Maximum JSON nesting depth
		max_array_length = 1000, -- Maximum array length

		-- Request validation
		validate_content_type = true,
		validate_json_syntax = true,
		sanitize_input = true,

		-- Security headers
		security_headers = {
			["X-Content-Type-Options"] = "nosniff",
			["X-Frame-Options"] = "DENY",
			["X-XSS-Protection"] = "1; mode=block",
			["Referrer-Policy"] = "strict-origin-when-cross-origin",
		},
	},

	-- Rate limiting
	rate_limiting = {
		-- Global rate limiting
		global_rate_limit = {
			enabled = true,
			requests_per_minute = 1000,
			burst_limit = 200,
		},

		-- Per-IP rate limiting
		ip_rate_limit = {
			enabled = true,
			requests_per_minute = 100,
			burst_limit = 20,
			block_duration = 300, -- 5 minutes
		},

		-- Per-user rate limiting
		user_rate_limit = {
			enabled = true,
			requests_per_minute = 200,
			burst_limit = 50,
		},

		-- Rate limit storage
		storage_backend = "memory", -- memory, redis, database
		cleanup_interval = 60, -- Clean up expired entries every minute
	},

	-- Input validation
	input_validation = {
		-- Parameter validation
		validate_parameters = true,
		max_parameter_length = 1000,
		allowed_characters = "alphanumeric_plus", -- alphanumeric, alphanumeric_plus, all

		-- SQL injection protection
		sql_injection_protection = true,

		-- XSS protection
		xss_protection = true,
		sanitize_html = true,

		-- Path traversal protection
		path_traversal_protection = true,
	},
}

-- API Response Configuration
-- Configure API response formats and data handling
local api_response_config = {
	-- Response formats
	response_formats = {
		-- JSON response format
		json = {
			enabled = true,
			pretty_print = false, -- Pretty print JSON (development only)
			include_null_values = false,
			date_format = "iso8601", -- iso8601, unix, custom
		},

		-- XML response format
		xml = {
			enabled = false,
			root_element = "response",
			namespace = "urn:xmpp:api:v1",
			include_declaration = true,
		},

		-- Plain text response format
		text = {
			enabled = false,
			charset = "utf-8",
		},
	},

	-- Error handling
	error_handling = {
		-- Error response format
		error_format = "rfc7807", -- rfc7807, simple, custom

		-- Error details
		include_stack_trace = false, -- Never include in production
		include_request_id = true,
		include_timestamp = true,

		-- Error codes
		use_http_status_codes = true,
		custom_error_codes = false,

		-- Error logging
		log_errors = true,
		log_level = "error",
	},

	-- Response caching
	response_caching = {
		-- HTTP caching headers
		cache_control = {
			enabled = true,
			default_max_age = 300, -- 5 minutes
			private_cache = true,
			no_cache_endpoints = { "/api/v1/admin", "/api/health" },
		},

		-- ETag support
		etag_support = {
			enabled = false,
			weak_etags = true,
		},

		-- Last-Modified support
		last_modified_support = {
			enabled = false,
		},
	},
}

-- API Integration Utilities
-- Helper functions for API integration and management
local api_utilities = {
	-- Validate API configuration
	validate_api_config = function(config)
		local validation = {
			valid = true,
			errors = {},
			warnings = {},
		}

		-- Validate endpoints
		for endpoint_name, endpoint_config in pairs(config.endpoints or {}) do
			if endpoint_config.enabled then
				if not endpoint_config.base_path then
					table.insert(validation.errors, endpoint_name .. ": base_path is required")
					validation.valid = false
				end

				if not endpoint_config.methods or #endpoint_config.methods == 0 then
					table.insert(validation.errors, endpoint_name .. ": methods are required")
					validation.valid = false
				end
			end
		end

		-- Validate security settings
		if not config.require_tls then
			table.insert(validation.warnings, "TLS is not required for API access")
		end

		return validation
	end,

	-- Generate API documentation
	generate_api_docs = function(config)
		-- This would generate OpenAPI/Swagger documentation
		return {
			openapi = "3.0.0",
			info = {
				title = "XMPP Server API",
				version = config.api_version or "v1",
				description = "REST API for XMPP server management",
			},
			servers = {
				{
					url = "https://xmpp.example.com/api/v1",
					description = "Production server",
				},
			},
			-- Additional OpenAPI specification would be generated here
		}
	end,

	-- Get API statistics
	get_api_stats = function()
		-- This would return real-time API statistics
		return {
			total_requests = 12345,
			requests_per_minute = 45.2,
			success_rate = 98.7, -- percentage
			average_response_time = 85, -- milliseconds
			active_api_keys = 25,
			rate_limited_requests = 12,
		}
	end,

	-- Test API endpoint
	test_api_endpoint = function(endpoint, method, auth_token)
		-- This would test an API endpoint
		return {
			endpoint_available = true,
			authentication_valid = true,
			response_code = 200,
			response_time = 95, -- milliseconds
		}
	end,
}

-- API Monitoring and Diagnostics
-- Tools for monitoring API usage and performance
local api_monitoring = {
	-- Request monitoring
	request_monitoring = {
		enabled = true,
		track_request_rates = true,
		track_response_times = true,
		track_error_rates = true,
		track_authentication_failures = true,
	},

	-- Performance monitoring
	performance_monitoring = {
		enabled = true,
		response_time_threshold = 1000, -- Alert if response time > 1 second
		error_rate_threshold = 5, -- Alert if error rate > 5%
		throughput_threshold = 1000, -- Alert if throughput < 1000 req/min
	},

	-- Security monitoring
	security_monitoring = {
		enabled = true,
		track_failed_auth = true,
		track_rate_limiting = true,
		track_suspicious_activity = true,

		-- Security thresholds
		max_failed_auth_per_ip = 20, -- Per hour
		suspicious_activity_threshold = 100, -- Requests per minute
	},

	-- Health checks
	health_checks = {
		enabled = true,
		check_interval = 60, -- Check every minute
		endpoint_health = true,
		database_health = true,
		external_service_health = false,
	},

	-- Logging configuration
	logging = {
		log_level = "info", -- debug, info, warn, error
		log_requests = false, -- Log all requests (can be verbose)
		log_responses = false, -- Log all responses
		log_errors = true, -- Always log errors
		log_slow_requests = true, -- Log slow requests
		slow_request_threshold = 1000, -- milliseconds
	},
}

-- Export configuration
return {
	modules = {
		-- API modules (commented out by default - requires setup)
		-- core = apis_config.core_api,
		-- admin = apis_config.admin_api,
		-- users = apis_config.user_api,
		-- messaging = apis_config.messaging_api,
		-- stats = apis_config.stats_api,
	},

	config = api_config,
	auth = api_auth_config,
	security = api_security,
	response = api_response_config,
	utilities = api_utilities,
	monitoring = api_monitoring,
}
