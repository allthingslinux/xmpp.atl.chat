-- Layer 05: Services - Messaging Configuration
-- Message handling, storage, delivery, and advanced messaging features
-- XEP-0313: Message Archive Management, XEP-0280: Message Carbons, XEP-0184: Message Delivery Receipts
-- XEP-0085: Chat State Notifications, XEP-0203: Delayed Delivery, XEP-0308: Last Message Correction
-- Comprehensive messaging service implementation

local messaging_config = {
	-- Core Messaging Services
	-- Essential message handling capabilities
	core_messaging = {
		"message_router", -- Core message routing
		"offline", -- Offline message storage
		"carbons", -- XEP-0280: Message Carbons
		"mam", -- XEP-0313: Message Archive Management
	},

	-- Message Delivery Services
	-- Enhanced message delivery and reliability
	delivery_services = {
		"receipts", -- XEP-0184: Message Delivery Receipts
		"smacks", -- XEP-0198: Stream Management
		"csi", -- XEP-0352: Client State Indication
		"throttle_presence", -- Presence throttling for messaging
	},

	-- Message Enhancement Services
	-- Advanced messaging features
	enhancement_services = {
		"chatstates", -- XEP-0085: Chat State Notifications
		"delay", -- XEP-0203: Delayed Delivery
		"replace", -- XEP-0308: Last Message Correction
		"attention", -- XEP-0224: Attention
	},

	-- Message Processing Services
	-- Message processing and transformation
	processing_services = {
		"message_logging", -- Message logging
		"message_filtering", -- Message content filtering
		"message_encryption", -- Message encryption services
		"message_compression", -- Message compression
	},

	-- Message Storage Services
	-- Message archiving and storage
	storage_services = {
		"archive", -- Message archiving
		"storage_sql", -- SQL storage backend
		"storage_memory", -- Memory storage backend
		"storage_file", -- File storage backend
	},

	-- Message Analytics Services
	-- Message analytics and reporting
	analytics_services = {
		"message_stats", -- Message statistics
		"delivery_stats", -- Delivery statistics
		"performance_monitoring", -- Performance monitoring
		"usage_analytics", -- Usage analytics
	},
}

-- Apply messaging configuration based on environment
local function apply_messaging_config()
	local env_type = prosody.config.get("*", "environment_type") or "production"

	-- Core messaging modules (always enabled)
	local core_modules = {}

	-- Core messaging (always enabled)
	for _, module in ipairs(messaging_config.core_messaging) do
		table.insert(core_modules, module)
	end

	-- Delivery services (always enabled)
	for _, module in ipairs(messaging_config.delivery_services) do
		table.insert(core_modules, module)
	end

	-- Enhancement services (always enabled)
	for _, module in ipairs(messaging_config.enhancement_services) do
		table.insert(core_modules, module)
	end

	-- Processing services (production and staging)
	if env_type ~= "development" then
		for _, module in ipairs(messaging_config.processing_services) do
			table.insert(core_modules, module)
		end
	end

	-- Storage services (always enabled)
	for _, module in ipairs(messaging_config.storage_services) do
		table.insert(core_modules, module)
	end

	-- Analytics services (production and staging)
	if env_type ~= "development" then
		for _, module in ipairs(messaging_config.analytics_services) do
			table.insert(core_modules, module)
		end
	end

	return core_modules
end

-- Message Archive Management Configuration
-- XEP-0313: Message Archive Management
mam_config = {
	-- Basic MAM settings
	enabled = true, -- Enable MAM

	-- Archive policies
	archive_policies = {
		default_policy = "roster", -- Default archiving policy
		available_policies = {
			"always", -- Always archive
			"never", -- Never archive
			"roster", -- Archive roster contacts only
		},
		user_can_change_policy = true, -- Users can change their policy
	},

	-- Storage settings
	storage_settings = {
		backend = "sql", -- Storage backend
		max_archive_query_results = 250, -- Maximum results per query
		default_page_size = 50, -- Default pagination size

		-- Retention policies
		archive_expires_after = 365 * 24 * 3600, -- Archive expiry (1 year)
		cleanup_interval = 24 * 3600, -- Cleanup interval (24 hours)
		max_archive_size_per_user = 1073741824, -- Max archive size per user (1GB)
	},

	-- Query settings
	query_settings = {
		max_query_results = 250, -- Maximum query results
		max_query_timespan = 30 * 24 * 3600, -- Maximum query timespan (30 days)

		-- Query optimizations
		enable_query_cache = true, -- Cache query results
		cache_ttl = 300, -- Cache TTL (5 minutes)
		parallel_queries = true, -- Enable parallel queries
	},

	-- Privacy settings
	privacy_settings = {
		respect_privacy_lists = true, -- Respect privacy list settings
		respect_blocking = true, -- Respect blocking settings
		anonymize_muc_archives = false, -- Anonymize MUC archives
		encrypt_archives = false, -- Encrypt archived messages
	},

	-- Performance settings
	performance_settings = {
		async_archiving = true, -- Asynchronous archiving
		batch_archiving = true, -- Batch archiving operations
		archive_compression = false, -- Compress archived messages
		index_optimization = true, -- Optimize database indexes
	},
}

-- Message Carbons Configuration
-- XEP-0280: Message Carbons
carbons_config = {
	-- Basic carbons settings
	enabled = true, -- Enable message carbons

	-- Carbon behavior
	carbon_behavior = {
		auto_enable_carbons = false, -- Auto-enable for all users
		respect_private_messages = true, -- Respect private message hints
		carbon_muc_messages = false, -- Carbon MUC messages
		carbon_error_messages = false, -- Carbon error messages

		-- Carbon filtering
		filter_duplicates = true, -- Filter duplicate carbons
		filter_chat_states = true, -- Filter chat state notifications
		filter_receipts = false, -- Don't filter delivery receipts
	},

	-- Performance settings
	performance_settings = {
		max_carbons_per_user = 10, -- Maximum carbon recipients per user
		carbon_delivery_timeout = 30, -- Carbon delivery timeout (seconds)
		batch_carbon_delivery = true, -- Batch carbon delivery
		async_carbon_delivery = true, -- Asynchronous carbon delivery
	},

	-- Privacy settings
	privacy_settings = {
		respect_carbon_hints = true, -- Respect carbon copy hints
		allow_carbon_disable = true, -- Allow users to disable carbons
		log_carbon_usage = false, -- Log carbon usage statistics
	},
}

-- Offline Message Storage Configuration
-- Offline message handling and storage
offline_config = {
	-- Basic offline settings
	enabled = true, -- Enable offline message storage

	-- Storage settings
	storage_settings = {
		backend = "sql", -- Storage backend
		max_offline_messages = 150, -- Maximum offline messages per user
		offline_message_ttl = 7 * 24 * 3600, -- Offline message TTL (7 days)

		-- Message priorities
		priority_handling = {
			store_normal = true, -- Store normal priority messages
			store_chat = true, -- Store chat messages
			store_headline = false, -- Don't store headline messages
			store_groupchat = false, -- Don't store groupchat messages
		},
	},

	-- Delivery settings
	delivery_settings = {
		deliver_on_login = true, -- Deliver messages on login
		deliver_order = "timestamp", -- Delivery order: timestamp, priority
		batch_delivery = true, -- Batch offline message delivery
		delivery_timeout = 60, -- Delivery timeout (1 minute)

		-- Delivery optimization
		compress_delivery = false, -- Compress offline message delivery
		parallel_delivery = true, -- Parallel delivery to multiple resources
	},

	-- Notification settings
	notification_settings = {
		notify_on_storage = false, -- Notify sender when message stored offline
		notify_on_delivery = false, -- Notify sender when message delivered
		include_message_count = true, -- Include offline message count in presence
	},
}

-- Message Delivery Receipts Configuration
-- XEP-0184: Message Delivery Receipts
receipts_config = {
	-- Basic receipts settings
	enabled = true, -- Enable delivery receipts

	-- Receipt behavior
	receipt_behavior = {
		auto_request_receipts = false, -- Automatically request receipts
		honor_receipt_requests = true, -- Honor receipt requests from others
		generate_receipts = true, -- Generate delivery receipts

		-- Receipt types
		support_received = true, -- Support 'received' receipts
		support_displayed = false, -- Support 'displayed' receipts (experimental)
		support_acknowledged = false, -- Support 'acknowledged' receipts (experimental)
	},

	-- Storage settings
	storage_settings = {
		store_receipts = false, -- Store receipt information
		receipt_timeout = 300, -- Receipt timeout (5 minutes)
		max_pending_receipts = 100, -- Maximum pending receipts per user
	},

	-- Privacy settings
	privacy_settings = {
		respect_privacy = true, -- Respect privacy settings for receipts
		allow_receipt_disable = true, -- Allow users to disable receipts
		anonymous_receipts = false, -- Anonymous receipt handling
	},

	-- Performance settings
	performance_settings = {
		async_receipt_processing = true, -- Asynchronous receipt processing
		batch_receipt_delivery = true, -- Batch receipt delivery
		receipt_rate_limiting = true, -- Rate limit receipt generation
	},
}

-- Chat State Notifications Configuration
-- XEP-0085: Chat State Notifications
chatstates_config = {
	-- Basic chat states settings
	enabled = true, -- Enable chat state notifications

	-- Chat state behavior
	chatstate_behavior = {
		-- Supported chat states
		support_active = true, -- Support 'active' state
		support_inactive = true, -- Support 'inactive' state
		support_composing = true, -- Support 'composing' state
		support_paused = true, -- Support 'paused' state
		support_gone = true, -- Support 'gone' state

		-- State transitions
		auto_inactive_timeout = 120, -- Auto-inactive timeout (2 minutes)
		auto_gone_timeout = 600, -- Auto-gone timeout (10 minutes)
		composing_timeout = 30, -- Composing state timeout (30 seconds)
	},

	-- Filtering settings
	filtering_settings = {
		filter_chat_states = false, -- Filter chat states for mobile clients
		respect_csi = true, -- Respect Client State Indication
		rate_limit_chatstates = true, -- Rate limit chat state notifications

		-- Mobile optimizations
		mobile_optimization = {
			reduce_chatstate_frequency = true, -- Reduce frequency for mobile
			batch_chatstates = false, -- Don't batch chat states
			suppress_when_inactive = true, -- Suppress when client inactive
		},
	},

	-- Privacy settings
	privacy_settings = {
		respect_privacy_lists = true, -- Respect privacy lists
		allow_chatstate_disable = true, -- Allow users to disable chat states
		anonymous_chatstates = false, -- Anonymous chat state handling
	},
}

-- Last Message Correction Configuration
-- XEP-0308: Last Message Correction
replace_config = {
	-- Basic correction settings
	enabled = true, -- Enable message correction

	-- Correction policies
	correction_policies = {
		allow_correction = true, -- Allow message correction
		time_limit = 300, -- Correction time limit (5 minutes)
		max_corrections = 5, -- Maximum corrections per message

		-- Who can correct
		author_can_correct = true, -- Message author can correct
		moderator_can_correct = false, -- Moderators cannot correct (privacy)
	},

	-- Correction behavior
	correction_behavior = {
		preserve_original = true, -- Preserve original message
		show_correction_history = false, -- Don't show correction history
		notify_correction = true, -- Notify about corrections

		-- Archive handling
		archive_corrections = true, -- Archive message corrections
		replace_in_archive = false, -- Don't replace original in archive
	},

	-- Security settings
	security_settings = {
		validate_correction_author = true, -- Validate correction author
		prevent_malicious_corrections = true, -- Prevent malicious corrections
		log_corrections = true, -- Log message corrections
	},
}

-- Message Processing Configuration
-- Advanced message processing features
message_processing_config = {
	-- Content processing
	content_processing = {
		enable_content_filtering = false, -- Content filtering
		enable_spam_detection = false, -- Spam detection
		enable_language_detection = false, -- Language detection

		-- Text processing
		normalize_unicode = true, -- Normalize Unicode text
		strip_excessive_whitespace = true, -- Strip excessive whitespace
		max_message_length = 65536, -- Maximum message length (64KB)
	},

	-- Encryption processing
	encryption_processing = {
		support_omemo = true, -- Support OMEMO encryption
		support_openpgp = true, -- Support OpenPGP encryption
		encrypt_offline_messages = false, -- Encrypt offline messages

		-- Key management
		auto_key_exchange = false, -- Automatic key exchange
		key_rotation_interval = 0, -- Key rotation interval (0 = disabled)
	},

	-- Transformation processing
	transformation_processing = {
		enable_message_transformation = false, -- Message transformation
		support_message_markup = false, -- Message markup support
		auto_link_detection = false, -- Automatic link detection

		-- Format conversion
		markdown_to_xhtml = false, -- Markdown to XHTML conversion
		emoji_conversion = false, -- Emoji conversion
	},
}

-- Message Analytics Configuration
-- Message analytics and reporting
analytics_config = {
	-- Basic analytics settings
	enabled = false, -- Disabled by default (privacy)

	-- Statistics collection
	statistics_collection = {
		collect_message_stats = false, -- Collect message statistics
		collect_delivery_stats = false, -- Collect delivery statistics
		collect_user_stats = false, -- Collect user statistics

		-- Data retention
		stats_retention_period = 30 * 24 * 3600, -- Stats retention (30 days)
		anonymize_stats = true, -- Anonymize statistics
	},

	-- Performance monitoring
	performance_monitoring = {
		monitor_message_latency = false, -- Monitor message latency
		monitor_delivery_success = false, -- Monitor delivery success rates
		monitor_storage_performance = false, -- Monitor storage performance

		-- Alerting
		latency_threshold = 1000, -- Latency alert threshold (1 second)
		delivery_failure_threshold = 0.1, -- Delivery failure threshold (10%)
	},

	-- Reporting
	reporting = {
		generate_reports = false, -- Generate analytics reports
		report_interval = 24 * 3600, -- Report interval (24 hours)
		report_format = "json", -- Report format: json, csv, xml

		-- Report types
		daily_summary = false, -- Daily summary reports
		weekly_summary = false, -- Weekly summary reports
		monthly_summary = false, -- Monthly summary reports
	},
}

-- Message Security Configuration
-- Security features for messaging
security_config = {
	-- Message validation
	message_validation = {
		validate_message_structure = true, -- Validate message structure
		validate_jid_format = true, -- Validate JID format
		validate_message_content = false, -- Validate message content

		-- Size limits
		max_message_size = 65536, -- Maximum message size (64KB)
		max_subject_length = 1024, -- Maximum subject length
		max_body_length = 65536, -- Maximum body length
	},

	-- Anti-abuse measures
	anti_abuse = {
		enable_rate_limiting = true, -- Enable message rate limiting
		messages_per_minute = 60, -- Messages per minute limit
		burst_limit = 10, -- Burst limit

		-- Spam prevention
		duplicate_message_detection = true, -- Detect duplicate messages
		rapid_fire_detection = true, -- Detect rapid-fire messaging
		flood_protection = true, -- Flood protection
	},

	-- Privacy protection
	privacy_protection = {
		respect_blocking = true, -- Respect blocking lists
		respect_privacy_lists = true, -- Respect privacy lists
		anonymous_messaging = false, -- Anonymous messaging support

		-- Data protection
		encrypt_sensitive_data = false, -- Encrypt sensitive message data
		secure_message_storage = false, -- Secure message storage
	},
}

-- Export configuration
return {
	modules = apply_messaging_config(),
	mam_config = mam_config,
	carbons_config = carbons_config,
	offline_config = offline_config,
	receipts_config = receipts_config,
	chatstates_config = chatstates_config,
	replace_config = replace_config,
	message_processing_config = message_processing_config,
	analytics_config = analytics_config,
	security_config = security_config,
}
