-- Layer 07: Interfaces - Components Configuration
-- External component interfaces and service gateways
-- XEP-0114: Jabber Component Protocol, XEP-0225: Component Connections
-- External services, transports, and protocol gateways

local components_config = {
	-- Core Component Support
	-- XEP-0114: Jabber Component Protocol
	core_components = {
		"component", -- XEP-0114: Component protocol (core)
	},

	-- Component Authentication
	-- Authentication methods for external components
	component_auth = {
		-- Component authentication is handled by the core component module
		-- Authentication via shared secrets and component passwords
	},

	-- Component Management
	-- Tools for managing external components
	component_management = {
		-- "component_management", -- Component management interface (community)
		-- "component_status", -- Component status monitoring (community)
	},

	-- Protocol Gateways
	-- Gateway components for other protocols
	protocol_gateways = {
		-- External gateway components would be configured here
		-- These are typically separate applications that connect as components
	},
}

-- Component Server Configuration
-- Configure component server behavior and security
local component_server_config = {
	-- Component listener configuration
	component_ports = { 5347 }, -- Default component port
	component_interface = "*", -- Listen on all interfaces

	-- Component security
	component_stanza_size_limit = 256 * 1024, -- 256KB max stanza size
	component_max_connections = 100, -- Maximum component connections

	-- Component timeout settings
	component_tcp_timeout = 300, -- 5 minutes TCP timeout
	component_handshake_timeout = 30, -- 30 seconds handshake timeout

	-- Component SSL/TLS (if needed)
	component_ssl = {
		-- Components typically don't use TLS, but it's available
		enabled = false,
		key = "/etc/prosody/certs/components.key",
		certificate = "/etc/prosody/certs/components.crt",
	},
}

-- Component Authentication Configuration
-- Configure authentication for external components
local component_auth_config = {
	-- Component authentication method
	component_auth_method = "shared_secret", -- shared_secret, certificate, or custom

	-- Shared secret configuration
	shared_secrets = {
		-- Component shared secrets (should be stored securely)
		-- Format: ["component.domain"] = "secret"
		-- Example:
		-- ["transport.example.com"] = "secret123",
		-- ["gateway.example.com"] = "anothersecret",
	},

	-- Certificate-based authentication (if using TLS)
	certificate_auth = {
		enabled = false,
		require_valid_cert = true,
		trusted_ca_file = "/etc/prosody/certs/component-ca.crt",
	},

	-- Component permissions
	component_permissions = {
		-- Default permissions for components
		default_permissions = {
			"send_stanzas",
			"receive_stanzas",
			"manage_users", -- If component manages users
		},

		-- Per-component permissions
		-- ["transport.example.com"] = { "send_stanzas", "receive_stanzas" },
	},
}

-- Component Types and Examples
-- Different types of components and their configurations
local component_types = {
	-- Multi-User Chat (MUC) Components
	muc_components = {
		description = "Multi-User Chat conference services",
		example_config = {
			-- MUC component configuration
			component_type = "muc",
			default_config = {
				name = "Conference Service",
				restrict_room_creation = false,
				max_history_messages = 50,
			},
		},
	},

	-- Transport/Gateway Components
	transport_components = {
		description = "Protocol gateways (IRC, Discord, Telegram, etc.)",
		example_config = {
			component_type = "transport",
			supported_protocols = {
				"irc",
				"discord",
				"telegram",
				"slack",
				"matrix",
			},
		},
	},

	-- PubSub Components
	pubsub_components = {
		description = "Publish-Subscribe services",
		example_config = {
			component_type = "pubsub",
			default_config = {
				max_items = 1000,
				persist_items = true,
				access_model = "open",
			},
		},
	},

	-- File Transfer Components
	file_transfer_components = {
		description = "File transfer proxy services",
		example_config = {
			component_type = "proxy65",
			default_config = {
				max_file_size = 100 * 1024 * 1024, -- 100MB
				allowed_file_types = "*",
			},
		},
	},

	-- Custom Service Components
	custom_components = {
		description = "Custom service components",
		example_config = {
			component_type = "custom",
			default_config = {
				-- Custom component configuration
			},
		},
	},
}

-- Component Security Configuration
-- Security settings for external components
local component_security = {
	-- Connection security
	connection_security = {
		require_encryption = false, -- Components typically use plain connections
		allowed_ips = {
			-- Restrict component connections to specific IPs
			-- "127.0.0.1", -- Local components only
			-- "10.0.0.0/8", -- Private network
		},

		-- Rate limiting for components
		rate_limiting = {
			enabled = true,
			max_stanzas_per_second = 100,
			burst_limit = 200,
		},
	},

	-- Component validation
	component_validation = {
		validate_from_addresses = true, -- Validate component 'from' addresses
		validate_to_addresses = true, -- Validate component 'to' addresses
		allow_wildcard_subdomains = false, -- Allow components to handle subdomains
	},

	-- Stanza filtering
	stanza_filtering = {
		enabled = true,
		max_stanza_size = 256 * 1024, -- 256KB
		filter_malformed_stanzas = true,
		block_dangerous_content = true,
	},
}

-- Component Monitoring and Management
-- Tools for monitoring and managing components
local component_monitoring = {
	-- Component status tracking
	status_tracking = {
		enabled = true,
		track_connection_status = true,
		track_stanza_counts = true,
		track_error_rates = true,
	},

	-- Component health checks
	health_checks = {
		enabled = true,
		ping_interval = 60, -- Ping components every minute
		timeout = 10, -- 10 second timeout
		max_failed_pings = 3, -- Disconnect after 3 failed pings
	},

	-- Component logging
	logging = {
		log_level = "info", -- debug, info, warn, error
		log_connections = true,
		log_stanzas = false, -- Only enable for debugging
		log_errors = true,
	},

	-- Component statistics
	statistics = {
		enabled = true,
		stats_interval = 300, -- Update stats every 5 minutes
		track_performance = true,
		track_usage = true,
	},
}

-- Component Utilities
-- Helper functions for component management
local component_utilities = {
	-- Register a new component
	register_component = function(domain, secret, component_type)
		return {
			domain = domain,
			secret = secret,
			type = component_type or "generic",
			status = "registered",
			created = os.time(),
		}
	end,

	-- Configure component host
	configure_component_host = function(domain, config)
		return {
			Component = domain,
			component_secret = config.secret,
			modules_enabled = config.modules or {},
			-- Additional component-specific configuration
		}
	end,

	-- Get component statistics
	get_component_stats = function()
		-- This would return real-time component statistics
		return {
			total_components = 5,
			active_components = 4,
			failed_components = 1,
			total_stanzas_processed = 12345,
			average_response_time = 15, -- milliseconds
		}
	end,

	-- Validate component configuration
	validate_component_config = function(config)
		local validation = {
			valid = true,
			errors = {},
			warnings = {},
		}

		-- Validate required fields
		if not config.domain then
			table.insert(validation.errors, "Component domain is required")
			validation.valid = false
		end

		if not config.secret then
			table.insert(validation.errors, "Component secret is required")
			validation.valid = false
		end

		-- Validate domain format
		if config.domain and not config.domain:match("^[%w.-]+$") then
			table.insert(validation.errors, "Invalid domain format")
			validation.valid = false
		end

		return validation
	end,
}

-- Example Component Configurations
-- Sample configurations for common component types
local example_configurations = {
	-- IRC Transport Component
	irc_transport = {
		Component = "irc.example.com",
		component_secret = "irc_secret_123",
		modules_enabled = {
			-- IRC transport would load its own modules
		},
		description = "IRC transport gateway",
	},

	-- Discord Bot Component
	discord_bot = {
		Component = "discord.example.com",
		component_secret = "discord_secret_456",
		modules_enabled = {
			-- Discord bot would load its own modules
		},
		description = "Discord bridge component",
	},

	-- File Transfer Proxy
	file_proxy = {
		Component = "proxy.example.com",
		component_secret = "proxy_secret_789",
		modules_enabled = {
			-- File transfer proxy modules
		},
		description = "SOCKS5 file transfer proxy",
	},
}

-- Export configuration
return {
	modules = {
		-- Core component support
		core = components_config.core_components,

		-- Additional component features (commented out by default)
		-- auth = components_config.component_auth,
		-- management = components_config.component_management,
		-- gateways = components_config.protocol_gateways,
	},

	server = component_server_config,
	auth = component_auth_config,
	types = component_types,
	security = component_security,
	monitoring = component_monitoring,
	utilities = component_utilities,
	examples = example_configurations,
}
