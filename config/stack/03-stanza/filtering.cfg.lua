-- Layer 03: Stanza - Filtering Configuration
-- Content filtering, spam prevention, firewall rules, and stanza validation
-- XEP-0016: Privacy Lists, XEP-0191: Blocking Command, XEP-0158: CAPTCHA Forms
-- Comprehensive stanza filtering and security mechanisms

local filtering_config = {
	-- Core Filtering Modules
	-- Essential filtering and validation
	core_filtering = {
		"firewall", -- Advanced stanza firewall
		"filter_chatstates", -- Filter chat state notifications
		"limits", -- Rate limiting and resource management
		"watchregistrations", -- Monitor registration attempts
	},

	-- Anti-Spam and Abuse Prevention
	-- Comprehensive spam and abuse protection
	anti_spam = {
		"spam_reporting", -- XEP-0377: Spam Reporting
		"block_strangers", -- Block messages from strangers
		"block_subscriptions", -- Block subscription requests
		"throttle_unsolicited", -- Throttle unsolicited messages
	},

	-- Content Filtering
	-- Message and content filtering capabilities
	content_filtering = {
		"filter_words", -- Word filtering and profanity detection
		"message_logging", -- Message logging for compliance
		"mam_muc", -- MUC message archiving
		"carbons", -- Message carbons filtering
	},

	-- Privacy and Security Filtering
	-- Privacy protection and security filtering
	privacy_filtering = {
		"privacy", -- XEP-0016: Privacy Lists
		"blocking", -- XEP-0191: Blocking Command
		"filter_iq", -- IQ stanza filtering
		"roster_command", -- Roster manipulation protection
	},

	-- Compliance and Legal Filtering
	-- Compliance, legal, and regulatory filtering
	compliance_filtering = {
		"audit", -- Audit logging
		"compliance_archive", -- Compliance message archiving
		"retention_policy", -- Data retention policy enforcement
		"gdpr_compliance", -- GDPR compliance features
	},

	-- Advanced Filtering Features
	-- Sophisticated filtering and analysis
	advanced_filtering = {
		"measure_stanza_counts", -- Stanza statistics and monitoring
		"stanza_counter", -- Count different stanza types
		"bandwidth_monitor", -- Monitor bandwidth usage
		"connection_throttle", -- Connection rate limiting
	},
}

-- Apply filtering configuration based on environment
local function apply_filtering_config()
	local env_type = prosody.config.get("*", "environment_type") or "production"

	-- Core filtering modules (always enabled)
	local core_modules = {}

	-- Essential filtering
	for _, module in ipairs(filtering_config.core_filtering) do
		table.insert(core_modules, module)
	end

	-- Anti-spam (always enabled)
	for _, module in ipairs(filtering_config.anti_spam) do
		table.insert(core_modules, module)
	end

	-- Content filtering (production and staging)
	if env_type ~= "development" then
		for _, module in ipairs(filtering_config.content_filtering) do
			table.insert(core_modules, module)
		end
	end

	-- Privacy filtering (always enabled)
	for _, module in ipairs(filtering_config.privacy_filtering) do
		table.insert(core_modules, module)
	end

	-- Compliance filtering (production only)
	if env_type == "production" then
		for _, module in ipairs(filtering_config.compliance_filtering) do
			table.insert(core_modules, module)
		end
	end

	-- Advanced filtering (production and staging)
	if env_type ~= "development" then
		for _, module in ipairs(filtering_config.advanced_filtering) do
			table.insert(core_modules, module)
		end
	end

	return core_modules
end

-- Firewall Configuration
-- Advanced stanza firewall rules and policies
firewall_config = {
	-- Basic firewall settings
	enabled = true, -- Enable firewall

	-- Default policies
	default_policy = "allow", -- Default policy: allow, deny
	log_blocked = true, -- Log blocked stanzas

	-- Rate limiting rules
	rate_limits = {
		-- Message rate limits
		message_rate = {
			burst = 50, -- Burst limit
			rate = 5, -- Messages per second
			period = 60, -- Rate period
		},

		-- Presence rate limits
		presence_rate = {
			burst = 20, -- Burst limit
			rate = 2, -- Presence updates per second
			period = 60, -- Rate period
		},

		-- IQ rate limits
		iq_rate = {
			burst = 30, -- Burst limit
			rate = 3, -- IQ stanzas per second
			period = 60, -- Rate period
		},
	},

	-- Content-based rules
	content_rules = {
		-- Block messages with excessive length
		max_message_length = 10000, -- Maximum message length

		-- Block messages with too many recipients
		max_recipients = 100, -- Maximum recipients per message

		-- Block binary content
		block_binary = true, -- Block binary attachments

		-- URL filtering
		url_filtering = {
			enabled = false, -- Enable URL filtering
			whitelist = {}, -- Allowed domains
			blacklist = {}, -- Blocked domains
		},
	},

	-- Spam detection rules
	spam_detection = {
		-- Duplicate message detection
		duplicate_detection = {
			enabled = true, -- Enable duplicate detection
			window = 300, -- Detection window (5 minutes)
			threshold = 3, -- Duplicate threshold
		},

		-- Rapid-fire message detection
		rapid_fire = {
			enabled = true, -- Enable rapid-fire detection
			messages_per_minute = 20, -- Messages per minute threshold
			action = "throttle", -- Action: throttle, block, warn
		},

		-- Pattern-based detection
		pattern_detection = {
			enabled = false, -- Enable pattern detection
			patterns = {}, -- Spam patterns (regex)
		},
	},
}

-- Anti-Spam Configuration
-- Comprehensive spam prevention settings
anti_spam_config = {
	-- Basic anti-spam settings
	enabled = true, -- Enable anti-spam

	-- Stranger filtering
	stranger_filtering = {
		enabled = false, -- Block messages from strangers
		whitelist_roster = true, -- Allow messages from roster contacts
		whitelist_subscribed = true, -- Allow messages from subscribed contacts
		require_subscription = false, -- Require subscription for messaging
	},

	-- Subscription request filtering
	subscription_filtering = {
		enabled = false, -- Filter subscription requests
		max_requests_per_hour = 10, -- Maximum requests per hour
		require_message = false, -- Require message with subscription
		auto_approve_known = false, -- Auto-approve known contacts
	},

	-- Challenge-response system
	challenge_response = {
		enabled = false, -- Enable challenge-response
		challenge_type = "captcha", -- Challenge type: captcha, question
		max_attempts = 3, -- Maximum challenge attempts
		timeout = 300, -- Challenge timeout (5 minutes)
	},

	-- Reputation system
	reputation_system = {
		enabled = false, -- Enable reputation tracking
		initial_score = 50, -- Initial reputation score
		min_score = 0, -- Minimum reputation score
		max_score = 100, -- Maximum reputation score
		decay_rate = 0.1, -- Daily reputation decay
	},
}

-- Content Filtering Configuration
-- Message content filtering and moderation
content_filter_config = {
	-- Word filtering
	word_filtering = {
		enabled = false, -- Enable word filtering

		-- Filter lists
		profanity_list = {}, -- Profanity word list
		spam_keywords = {}, -- Spam keyword list

		-- Actions
		action = "warn", -- Action: block, warn, moderate
		replacement_char = "*", -- Replacement character

		-- Whitelist
		whitelist = {}, -- Whitelisted words/phrases
	},

	-- Image and media filtering
	media_filtering = {
		enabled = false, -- Enable media filtering
		max_file_size = 10485760, -- Maximum file size (10MB)
		allowed_types = { -- Allowed media types
			"image/jpeg",
			"image/png",
			"image/gif",
			"image/webp",
		},
		scan_for_malware = false, -- Scan for malware (requires external service)
	},

	-- Link filtering
	link_filtering = {
		enabled = false, -- Enable link filtering
		check_reputation = false, -- Check link reputation
		block_shorteners = false, -- Block URL shorteners
		whitelist_domains = {}, -- Whitelisted domains
		blacklist_domains = {}, -- Blacklisted domains
	},
}

-- Privacy Lists Configuration
-- XEP-0016: Privacy Lists (legacy support)
privacy_lists_config = {
	-- Basic settings
	enabled = true, -- Enable privacy lists

	-- Default lists
	default_list = "default", -- Default privacy list name

	-- List management
	max_lists = 20, -- Maximum lists per user
	max_items_per_list = 100, -- Maximum items per list

	-- Performance
	cache_lists = true, -- Cache privacy lists
	cache_ttl = 3600, -- Cache TTL (1 hour)

	-- Rules
	default_rules = {
		-- Default allow rule
		{
			action = "allow",
			order = 100,
		},
	},
}

-- Blocking Command Configuration
-- XEP-0191: Blocking Command (modern blocking)
blocking_command_config = {
	-- Basic settings
	enabled = true, -- Enable blocking command

	-- Limits
	max_blocked_items = 1000, -- Maximum blocked items

	-- Blocking scope
	block_messages = true, -- Block messages
	block_presence_in = true, -- Block incoming presence
	block_presence_out = false, -- Block outgoing presence
	block_iq = true, -- Block IQ stanzas

	-- Storage
	persistent = true, -- Persist blocking lists
	sync_on_login = true, -- Sync on login
}

-- Rate Limiting Configuration
-- Comprehensive rate limiting settings
rate_limiting_config = {
	-- Connection limits
	connections = {
		max_per_ip = 10, -- Maximum connections per IP
		max_per_user = 5, -- Maximum connections per user
		connection_rate = 1, -- New connections per second
	},

	-- Stanza limits
	stanzas = {
		-- Global limits
		global_rate = 1000, -- Global stanzas per second

		-- Per-user limits
		user_rate = 50, -- User stanzas per second
		user_burst = 100, -- User burst limit

		-- Per-connection limits
		connection_rate = 20, -- Connection stanzas per second
		connection_burst = 50, -- Connection burst limit
	},

	-- Bandwidth limits
	bandwidth = {
		max_incoming = 1048576, -- Max incoming bandwidth (1MB/s)
		max_outgoing = 1048576, -- Max outgoing bandwidth (1MB/s)
		burst_size = 2097152, -- Burst size (2MB)
	},

	-- Penalties
	penalties = {
		soft_limit_penalty = 2, -- Soft limit penalty multiplier
		hard_limit_penalty = 10, -- Hard limit penalty multiplier
		ban_duration = 3600, -- Ban duration (1 hour)
	},
}

-- Export configuration
return {
	modules = apply_filtering_config(),
	firewall_config = firewall_config,
	anti_spam_config = anti_spam_config,
	content_filter_config = content_filter_config,
	privacy_lists_config = privacy_lists_config,
	blocking_command_config = blocking_command_config,
	rate_limiting_config = rate_limiting_config,
}
