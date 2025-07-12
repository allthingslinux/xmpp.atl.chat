-- Layer 08: Integration - Webhooks Configuration
-- Webhook integration for external service notifications and event handling
-- HTTP callbacks for XMPP events, real-time notifications, and service integration
-- Event-driven integration with external systems and applications

local webhooks_config = {
	-- Webhook Modules
	-- HTTP webhook and notification modules
	webhook_modules = {
		"http_upload_external", -- External file upload webhooks (community)
		-- "webhook", -- Generic webhook module (community, if available)
		-- "http_notification", -- HTTP notification module (community, if available)
	},

	-- Event Webhooks
	-- Webhooks for XMPP events and notifications
	event_webhooks = {
		-- "event_webhook", -- Event-based webhooks (community, if available)
		-- "user_event_webhook", -- User event webhooks (community, if available)
	},

	-- Message Webhooks
	-- Webhooks for message events and notifications
	message_webhooks = {
		-- "message_webhook", -- Message event webhooks (community, if available)
		-- "offline_webhook", -- Offline message webhooks (community, if available)
	},

	-- Administrative Webhooks
	-- Webhooks for administrative events
	admin_webhooks = {
		-- "admin_webhook", -- Administrative event webhooks (community, if available)
		-- "audit_webhook", -- Audit event webhooks (community, if available)
	},
}

-- Webhook Configuration
-- Configure webhook endpoints and event handling
local webhook_config = {
	-- Webhook endpoints
	endpoints = {
		-- User registration webhook
		user_registration = {
			enabled = false,
			url = "https://your-service.com/webhooks/user/register",
			method = "POST",
			headers = {
				["Content-Type"] = "application/json",
				["Authorization"] = "Bearer your-webhook-token",
			},
			events = { "user-registered", "user-activated" },
		},

		-- Message webhook
		message_events = {
			enabled = false,
			url = "https://your-service.com/webhooks/message",
			method = "POST",
			headers = {
				["Content-Type"] = "application/json",
				["Authorization"] = "Bearer your-webhook-token",
			},
			events = { "message-sent", "message-received", "message-offline" },
		},

		-- Presence webhook
		presence_events = {
			enabled = false,
			url = "https://your-service.com/webhooks/presence",
			method = "POST",
			headers = {
				["Content-Type"] = "application/json",
				["Authorization"] = "Bearer your-webhook-token",
			},
			events = { "user-online", "user-offline", "presence-changed" },
		},

		-- Administrative webhook
		admin_events = {
			enabled = false,
			url = "https://your-service.com/webhooks/admin",
			method = "POST",
			headers = {
				["Content-Type"] = "application/json",
				["Authorization"] = "Bearer your-webhook-token",
			},
			events = { "user-created", "user-deleted", "config-changed" },
		},

		-- File upload webhook
		file_upload = {
			enabled = false,
			url = "https://your-service.com/webhooks/upload",
			method = "POST",
			headers = {
				["Content-Type"] = "application/json",
				["Authorization"] = "Bearer your-webhook-token",
			},
			events = { "file-uploaded", "file-downloaded", "file-deleted" },
		},
	},

	-- Global webhook settings
	global_settings = {
		-- Timeout settings
		timeout = 30, -- HTTP request timeout in seconds
		connect_timeout = 10, -- Connection timeout in seconds

		-- Retry settings
		max_retries = 3, -- Maximum retry attempts
		retry_delay = 5, -- Delay between retries in seconds
		exponential_backoff = true, -- Use exponential backoff for retries

		-- Rate limiting
		rate_limit = {
			enabled = true,
			max_requests_per_minute = 100,
			burst_limit = 20,
		},
	},
}

-- Webhook Event Configuration
-- Configure which XMPP events trigger webhooks
local webhook_events = {
	-- User events
	user_events = {
		-- User lifecycle events
		user_registered = {
			enabled = false,
			description = "User account created",
			payload_fields = { "username", "domain", "timestamp", "registration_source" },
		},

		user_deleted = {
			enabled = false,
			description = "User account deleted",
			payload_fields = { "username", "domain", "timestamp", "deletion_reason" },
		},

		user_login = {
			enabled = false,
			description = "User logged in",
			payload_fields = { "username", "domain", "timestamp", "client_info", "ip_address" },
		},

		user_logout = {
			enabled = false,
			description = "User logged out",
			payload_fields = { "username", "domain", "timestamp", "session_duration" },
		},
	},

	-- Message events
	message_events = {
		-- Message lifecycle events
		message_sent = {
			enabled = false,
			description = "Message sent by user",
			payload_fields = { "from", "to", "timestamp", "message_type", "message_id" },
			include_body = false, -- Include message body (privacy consideration)
		},

		message_received = {
			enabled = false,
			description = "Message received by user",
			payload_fields = { "from", "to", "timestamp", "message_type", "message_id" },
			include_body = false, -- Include message body (privacy consideration)
		},

		message_offline = {
			enabled = false,
			description = "Message stored for offline user",
			payload_fields = { "from", "to", "timestamp", "message_type", "message_id" },
		},

		message_archived = {
			enabled = false,
			description = "Message archived (MAM)",
			payload_fields = { "from", "to", "timestamp", "archive_id" },
		},
	},

	-- Presence events
	presence_events = {
		-- Presence state changes
		user_online = {
			enabled = false,
			description = "User came online",
			payload_fields = { "username", "domain", "timestamp", "presence_show", "presence_status" },
		},

		user_offline = {
			enabled = false,
			description = "User went offline",
			payload_fields = { "username", "domain", "timestamp", "session_duration" },
		},

		presence_changed = {
			enabled = false,
			description = "User presence status changed",
			payload_fields = { "username", "domain", "timestamp", "old_presence", "new_presence" },
		},
	},

	-- Administrative events
	admin_events = {
		-- Server administration events
		config_reloaded = {
			enabled = false,
			description = "Server configuration reloaded",
			payload_fields = { "timestamp", "admin_user", "config_changes" },
		},

		module_loaded = {
			enabled = false,
			description = "Module loaded or reloaded",
			payload_fields = { "timestamp", "module_name", "admin_user" },
		},

		server_started = {
			enabled = false,
			description = "XMPP server started",
			payload_fields = { "timestamp", "server_version", "uptime" },
		},

		server_stopped = {
			enabled = false,
			description = "XMPP server stopped",
			payload_fields = { "timestamp", "shutdown_reason", "uptime" },
		},
	},
}

-- Webhook Security Configuration
-- Security settings for webhook delivery and authentication
local webhook_security = {
	-- Authentication settings
	authentication = {
		-- Webhook authentication methods
		auth_methods = {
			bearer_token = true, -- Support Bearer token authentication
			api_key = true, -- Support API key authentication
			hmac_signature = false, -- Support HMAC signature verification
			basic_auth = false, -- Support basic authentication
		},

		-- Token configuration
		token_config = {
			header_name = "Authorization", -- Header name for tokens
			prefix = "Bearer ", -- Token prefix
			validate_tokens = false, -- Validate tokens with external service
		},

		-- HMAC signature configuration
		hmac_config = {
			algorithm = "sha256", -- HMAC algorithm
			header_name = "X-Webhook-Signature", -- Signature header name
			secret_key = "your-webhook-secret", -- HMAC secret key
		},
	},

	-- Transport security
	transport_security = {
		-- TLS requirements
		require_tls = true, -- Require HTTPS for webhook delivery
		verify_certificates = true, -- Verify webhook endpoint certificates
		min_tls_version = "1.2", -- Minimum TLS version

		-- Certificate validation
		trusted_ca_file = "/etc/ssl/certs/ca-certificates.crt",
		allow_self_signed = false, -- Allow self-signed certificates
	},

	-- Data security
	data_security = {
		-- Payload encryption
		encrypt_payloads = false, -- Encrypt webhook payloads
		encryption_algorithm = "AES-256-GCM",

		-- Data privacy
		sanitize_payloads = true, -- Remove sensitive data from payloads
		mask_personal_data = true, -- Mask personal information

		-- Sensitive fields to exclude/mask
		sensitive_fields = {
			"password",
			"token",
			"secret",
			"key",
			"ip_address",
			"email",
			"phone",
		},
	},
}

-- Webhook Delivery Configuration
-- Configure webhook delivery behavior and reliability
local webhook_delivery = {
	-- Delivery settings
	delivery_settings = {
		-- Delivery mode
		delivery_mode = "async", -- async, sync, batch

		-- Batch delivery (if using batch mode)
		batch_config = {
			batch_size = 10, -- Number of events per batch
			batch_timeout = 30, -- Maximum time to wait for batch (seconds)
			max_batch_delay = 300, -- Maximum delay before sending batch (seconds)
		},

		-- Queue settings
		queue_config = {
			max_queue_size = 1000, -- Maximum queued webhooks
			queue_timeout = 3600, -- Queue timeout in seconds (1 hour)
			persistent_queue = false, -- Persist queue across restarts
		},
	},

	-- Reliability settings
	reliability = {
		-- Retry configuration
		retry_config = {
			max_retries = 3, -- Maximum retry attempts
			initial_delay = 1, -- Initial retry delay (seconds)
			max_delay = 60, -- Maximum retry delay (seconds)
			backoff_multiplier = 2, -- Exponential backoff multiplier
		},

		-- Dead letter queue
		dead_letter_queue = {
			enabled = false, -- Enable dead letter queue for failed webhooks
			max_age = 86400, -- Maximum age in dead letter queue (24 hours)
			storage_backend = "memory", -- memory, file, database
		},

		-- Circuit breaker
		circuit_breaker = {
			enabled = true, -- Enable circuit breaker for failing endpoints
			failure_threshold = 5, -- Number of failures to trigger circuit breaker
			timeout = 300, -- Circuit breaker timeout (5 minutes)
			half_open_max_calls = 3, -- Max calls in half-open state
		},
	},
}

-- Webhook Utilities
-- Helper functions for webhook management
local webhook_utilities = {
	-- Validate webhook configuration
	validate_webhook_config = function(config)
		local validation = {
			valid = true,
			errors = {},
			warnings = {},
		}

		-- Validate endpoints
		for endpoint_name, endpoint_config in pairs(config.endpoints or {}) do
			if endpoint_config.enabled then
				if not endpoint_config.url then
					table.insert(validation.errors, endpoint_name .. ": URL is required")
					validation.valid = false
				end

				if endpoint_config.url and not endpoint_config.url:match("^https?://") then
					table.insert(validation.errors, endpoint_name .. ": Invalid URL format")
					validation.valid = false
				end

				if endpoint_config.url and endpoint_config.url:match("^http://") and config.require_tls then
					table.insert(validation.warnings, endpoint_name .. ": HTTP URL with TLS required")
				end
			end
		end

		return validation
	end,

	-- Test webhook endpoint
	test_webhook_endpoint = function(endpoint_config)
		-- This would test the webhook endpoint
		return {
			endpoint_reachable = true,
			response_code = 200,
			response_time = 85, -- milliseconds
			authentication_valid = true,
		}
	end,

	-- Get webhook statistics
	get_webhook_stats = function()
		-- This would return real-time webhook statistics
		return {
			total_webhooks_sent = 1234,
			successful_deliveries = 1200,
			failed_deliveries = 34,
			success_rate = 97.2, -- percentage
			average_response_time = 120, -- milliseconds
			queued_webhooks = 5,
		}
	end,

	-- Generate webhook payload
	generate_webhook_payload = function(event_type, event_data)
		-- This would generate a standardized webhook payload
		return {
			event_type = event_type,
			timestamp = os.time(),
			server_id = "xmpp.example.com",
			event_id = "evt_" .. os.time() .. "_" .. math.random(1000, 9999),
			data = event_data,
		}
	end,
}

-- Webhook Monitoring and Diagnostics
-- Tools for monitoring webhook delivery and performance
local webhook_monitoring = {
	-- Delivery monitoring
	delivery_monitoring = {
		enabled = true,
		track_delivery_rates = true,
		track_response_times = true,
		track_error_rates = true,
		track_retry_attempts = true,
	},

	-- Performance monitoring
	performance_monitoring = {
		enabled = true,
		response_time_threshold = 5000, -- Alert if response time > 5 seconds
		error_rate_threshold = 10, -- Alert if error rate > 10%
		queue_size_threshold = 100, -- Alert if queue size > 100
	},

	-- Health checks
	health_checks = {
		enabled = true,
		check_interval = 300, -- Check endpoints every 5 minutes
		endpoint_health_check = true,
		queue_health_check = true,
	},

	-- Logging configuration
	logging = {
		log_level = "info", -- debug, info, warn, error
		log_requests = false, -- Log webhook requests (can be verbose)
		log_responses = false, -- Log webhook responses
		log_errors = true, -- Always log errors
		log_retries = true, -- Log retry attempts
	},
}

-- Export configuration
return {
	modules = {
		-- Webhook modules (commented out by default - requires setup)
		-- webhooks = webhooks_config.webhook_modules,
		-- events = webhooks_config.event_webhooks,
		-- messages = webhooks_config.message_webhooks,
		-- admin = webhooks_config.admin_webhooks,
	},

	config = webhook_config,
	events = webhook_events,
	security = webhook_security,
	delivery = webhook_delivery,
	utilities = webhook_utilities,
	monitoring = webhook_monitoring,
}
