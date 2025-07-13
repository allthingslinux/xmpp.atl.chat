-- ===============================================
-- PUBLIC SERVER BEST PRACTICES CONFIGURATION
-- Based on official Prosody public server documentation
-- Reference: https://prosody.im/doc/public_servers
-- ===============================================
-- This configuration implements all recommendations for running a public XMPP server
-- including registration control, abuse prevention, and contact information

local domain = os.getenv("PROSODY_DOMAIN") or "localhost"

-- ===============================================
-- REGISTRATION CONTROL AND SECURITY
-- ===============================================

-- Core Registration Configuration
-- mod_register settings for secure user registration
local registration_config = {
	-- Enable registration with strict controls
	allow_registration = os.getenv("PROSODY_ALLOW_REGISTRATION") == "true",

	-- Rate limiting for registration (per-IP)
	-- "Spammers have lots of IP addresses and lots of time, so this limit alone is not enough"
	min_seconds_between_registrations = tonumber(os.getenv("PROSODY_REG_THROTTLE_PERIOD")) or 300, -- 5 minutes minimum

	-- Additional registration security
	registration_throttle_max = tonumber(os.getenv("PROSODY_REG_THROTTLE_MAX")) or 3, -- Max 3 registrations per period
	registration_throttle_period = tonumber(os.getenv("PROSODY_REG_THROTTLE_WINDOW")) or 3600, -- 1 hour window

	-- Require invitation codes (recommended for public servers)
	registration_invite_only = os.getenv("PROSODY_INVITE_ONLY") == "true",

	-- Welcome message for new users
	registration_welcome_message = "Welcome to "
		.. domain
		.. "! Please read our community guidelines and terms of service.",
}

-- Reserved Usernames (mod_block_registrations)
-- "This module allows you to set a list of reserved account names that cannot be registered"
local blocked_usernames = {
	-- Administrative accounts
	"admin",
	"administrator",
	"root",
	"system",
	"daemon",
	"service",
	"hostmaster",
	"postmaster",
	"webmaster",
	"abuse",
	"security",

	-- XMPP-specific reserved names
	"xmpp",
	"prosody",
	"ejabberd",
	"openfire",
	"tigase",

	-- Service accounts
	"support",
	"help",
	"info",
	"contact",
	"noreply",
	"no-reply",
	"staff",
	"moderator",
	"mod",
	"operator",
	"bot",

	-- Technical services
	"api",
	"www",
	"mail",
	"email",
	"ftp",
	"ssh",
	"dns",
	"conference",
	"muc",
	"upload",
	"pubsub",
	"proxy",
	"register",
	"registration",
	"subscribe",
	"subscription",

	-- Common service names
	"news",
	"announcements",
	"notifications",
	"alerts",
	"test",
	"testing",
	"guest",
	"anonymous",
	"null",
	"void",

	-- Prevent abuse
	"spam",
	"spammer",
	"phishing",
	"malware",
	"virus",
	"troll",
	"fake",
	"scam",
	"fraud",
	"abuse-team",
}

-- Registration Monitoring (mod_watchregistrations)
-- "This module alerts admins of new accounts, allowing you to keep an eye on how often accounts are created"
local registration_monitoring = {
	-- Enable registration monitoring
	registration_notification = true,

	-- Admin contacts for registration alerts
	admins = os.getenv("PROSODY_ADMINS") or ("admin@" .. domain),

	-- Notification settings
	registration_watchers = {
		"admin@" .. domain,
		"abuse@" .. domain,
	},

	-- Alert thresholds
	registration_alert_threshold = 10, -- Alert if >10 registrations per hour
	registration_alert_window = 3600, -- 1 hour window
}

-- ===============================================
-- CONTACT INFORMATION (XEP-0128)
-- ===============================================

-- Server Contact Information (mod_server_contact_info)
-- "This module advertises addresses where you can be reached"
-- "Especially the abuse address should be set for public servers"
local contact_info = {
	-- Administrative contacts
	admin = {
		"xmpp:admin@" .. domain,
		"mailto:admin@" .. domain,
		"https://" .. domain .. "/contact",
	},

	-- Abuse reporting (CRITICAL for public servers)
	abuse = {
		"xmpp:abuse@" .. domain,
		"mailto:abuse@" .. domain,
		"https://" .. domain .. "/report-abuse",
	},

	-- General support
	support = {
		"xmpp:support@" .. domain,
		"mailto:support@" .. domain,
		"https://" .. domain .. "/support",
	},

	-- Security team
	security = {
		"mailto:security@" .. domain,
		"https://" .. domain .. "/security",
	},

	-- Service status and outages
	status = {
		"https://status." .. domain,
		"mailto:status@" .. domain,
	},
}

-- RFC 3912 Contact (XMPP Core RFC encouragement)
-- "The XMPP Core RFC encourages providing an email mailbox xmpp (eg xmpp@example.com)"
local rfc_contact = {
	xmpp_contact = "xmpp@" .. domain,
	contact_description = "General inquiries about " .. domain .. " XMPP service",
}

-- ===============================================
-- ABUSE PREVENTION AND RATE LIMITING
-- ===============================================

-- Connection and Bandwidth Limits (mod_limits)
-- "This module limits bandwidth used by XMPP sessions"
-- "Traffic patterns between servers may vary, but here is an example that is being used in production"
local bandwidth_limits = {
	c2s = {
		rate = os.getenv("PROSODY_C2S_RATE") or "3kb/s", -- Production example from documentation
		burst = os.getenv("PROSODY_C2S_BURST") or "2s", -- Production example from documentation
		stanza_size_limit = 262144, -- 256KB max stanza size
		max_connections = 1000, -- Maximum client connections
	},
	s2sin = {
		rate = os.getenv("PROSODY_S2S_RATE") or "30kb/s", -- Production example from documentation
		burst = os.getenv("PROSODY_S2S_BURST") or "3s", -- Production example from documentation
		stanza_size_limit = 524288, -- 512KB max stanza size for s2s
		max_connections = 100, -- Maximum incoming server connections
	},
	s2sout = {
		rate = os.getenv("PROSODY_S2S_RATE") or "30kb/s",
		burst = os.getenv("PROSODY_S2S_BURST") or "3s",
		stanza_size_limit = 524288, -- 512KB max stanza size for s2s
		max_connections = 100, -- Maximum outgoing server connections
	},
}

-- Connection Security and Anti-Abuse
local connection_security = {
	-- Per-IP connection limits
	max_connections_per_ip = tonumber(os.getenv("PROSODY_MAX_CONNECTIONS_PER_IP")) or 5,

	-- Connection rate limiting
	connection_throttle_max = 10, -- Max new connections per period
	connection_throttle_period = 60, -- 1 minute period

	-- Failed authentication tracking
	auth_failure_limit = 5, -- Max failed attempts
	auth_failure_window = 300, -- 5 minute window
	auth_failure_ban_time = 3600, -- 1 hour ban

	-- Stanza flood protection
	stanza_rate_limit = 50, -- Max stanzas per second per connection
	stanza_burst_limit = 100, -- Burst allowance
}

-- MUC Flood Prevention (mod_muc_limits)
-- "If you run a MUC (chatroom) service, this module helps to prevent flooding of rooms"
local muc_limits = {
	-- Message rate limits in chat rooms
	muc_max_messages_per_minute = 30,
	muc_max_presence_per_minute = 20,
	muc_max_participants = 200,

	-- Room creation limits
	max_rooms_per_user = 10,
	room_creation_rate_limit = 5, -- Max rooms created per hour

	-- Content limits
	muc_max_message_length = 5000, -- 5KB max message
	muc_max_subject_length = 200,
}

-- ===============================================
-- FIREWALL AND CONTENT FILTERING
-- ===============================================

-- Advanced Firewall Rules (mod_firewall)
-- "This module allows admins to respond to abuse promptly with a rule-based configuration"
local firewall_rules = {
	-- Basic spam prevention
	spam_protection = {
		duplicate_message_threshold = 3, -- Block after 3 identical messages
		rapid_message_threshold = 10, -- Block after 10 messages in 60 seconds
		long_message_threshold = 10000, -- Block messages >10KB
	},

	-- Content filtering
	content_filters = {
		block_binary_content = true,
		max_message_length = 10000, -- 10KB max
		max_recipients_per_message = 50,
		block_excessive_markup = true,
	},

	-- IP-based filtering
	ip_filtering = {
		enable_dnsbl = true, -- Enable DNS blocklists
		dnsbl_servers = {
			"zen.spamhaus.org",
			"bl.spamcop.net",
			"dnsbl.sorbs.net",
		},
	},
}

-- ===============================================
-- IDENTITY PROTECTION
-- ===============================================

-- Username Spoofing Prevention (mod_mimicking)
-- "Prevents registration of usernames visibly similar to existing usernames to prevent spoofing attacks"
local mimicking_prevention = {
	-- Enable spoofing protection
	block_mimicking = true,

	-- Similarity threshold (0.0-1.0, lower = stricter)
	mimicking_threshold = 0.8,

	-- Character substitution protection
	block_homograph_attacks = true,
	block_similar_characters = true,

	-- Admin notification for blocked attempts
	notify_admins_on_mimicking = true,
}

-- Account Deletion Protection (mod_tombstones)
-- "Prevents registration of usernames that have been deleted"
-- "in order to prevent access to any group chats or other resources that may not have revoked access"
local tombstone_protection = {
	-- Enable tombstone protection
	use_tombstones = true,

	-- Tombstone retention period
	tombstone_expiry = "1y", -- Keep tombstones for 1 year

	-- Tombstone storage
	tombstone_storage = "sql", -- Use persistent storage for tombstones
}

-- ===============================================
-- SCALABILITY CONSIDERATIONS
-- ===============================================

-- File Descriptor Limits
-- "Raise the per-process file limit. When running under systemd..."
local scalability_config = {
	-- System limits (configured via systemd or system config)
	recommended_nofile_limit = 1048576, -- 1M file descriptors

	-- Prosody-specific performance settings
	max_clients = tonumber(os.getenv("PROSODY_MAX_CLIENTS")) or 10000,
	gc_settings = {
		speed = 500, -- Aggressive GC for large servers
		threshold = 110, -- Lower GC threshold
	},

	-- Connection optimization
	tcp_nodelay = true,
	tcp_keepalive = true,
}

-- ===============================================
-- BACKUP AND MONITORING CONSIDERATIONS
-- ===============================================

-- Backup Configuration
local backup_config = {
	-- Backup recommendations (implement via external scripts)
	backup_frequency = "daily",
	backup_retention = "30d",
	backup_types = {
		"full_database", -- Complete database backup
		"user_data", -- User accounts and rosters
		"configuration", -- Server configuration
		"certificates", -- TLS certificates
	},

	-- Recovery testing
	test_restore_frequency = "monthly",
	recovery_time_objective = "4h", -- Max downtime for recovery
	recovery_point_objective = "1h", -- Max data loss acceptable
}

-- Monitoring Configuration
local monitoring_config = {
	-- Key metrics to monitor
	critical_metrics = {
		"connection_count",
		"message_rate",
		"error_rate",
		"memory_usage",
		"disk_space",
		"certificate_expiry",
	},

	-- Alert thresholds
	alert_thresholds = {
		max_connections = 9000, -- 90% of max_clients
		high_error_rate = 0.05, -- 5% error rate
		memory_usage = 0.85, -- 85% memory usage
		disk_usage = 0.90, -- 90% disk usage
	},
}

-- ===============================================
-- REQUIRED MODULES FOR PUBLIC SERVERS
-- ===============================================

-- Essential Public Server Modules
local public_server_modules = {
	-- Registration and user management
	"register", -- User registration (mod_register)
	"register_limits", -- Registration rate limiting
	"watchregistrations", -- Registration monitoring (mod_watchregistrations)
	"block_registrations", -- Block reserved usernames (mod_block_registrations)

	-- Contact and service information
	"server_contact_info", -- Contact information (mod_server_contact_info)
	"server_info", -- Enhanced server information
	"disco_items", -- Service discovery

	-- Abuse prevention
	"limits", -- Bandwidth and connection limits (mod_limits)
	"firewall", -- Advanced firewall (mod_firewall)
	"mimicking", -- Username spoofing prevention (mod_mimicking)
	"tombstones", -- Deleted account protection (mod_tombstones)

	-- MUC protection (if running MUC service)
	"muc_limits", -- MUC flood prevention (mod_muc_limits)

	-- Security and monitoring
	"log_auth", -- Authentication logging
	"measure_registration", -- Registration metrics
	"blocklist", -- User blocking capabilities
	"privacy_lists", -- Privacy controls

	-- Performance and reliability
	"reload_modules", -- Hot reload capabilities
	"admin_shell", -- Administrative interface
	"statistics", -- Performance statistics
}

-- ===============================================
-- CONFIGURATION EXPORT
-- ===============================================

-- Apply all configurations
-- These settings will be merged with the main configuration

-- Registration settings
for key, value in pairs(registration_config) do
	_G[key] = value
end

-- Contact information
_G.contact_info = contact_info

-- Bandwidth limits
_G.limits = bandwidth_limits

-- Blocked usernames
_G.block_registrations_users = blocked_usernames

-- Registration monitoring
for key, value in pairs(registration_monitoring) do
	_G[key] = value
end

-- Export configuration for use by other modules
return {
	-- Module list for public servers
	modules = public_server_modules,

	-- Configuration sections
	registration = registration_config,
	contact_info = contact_info,
	bandwidth_limits = bandwidth_limits,
	connection_security = connection_security,
	muc_limits = muc_limits,
	firewall_rules = firewall_rules,
	mimicking_prevention = mimicking_prevention,
	tombstone_protection = tombstone_protection,
	scalability = scalability_config,
	backup = backup_config,
	monitoring = monitoring_config,

	-- Blocked usernames list
	blocked_usernames = blocked_usernames,

	-- RFC contact information
	rfc_contact = rfc_contact,
}
