-- Layer 05: Services - Messaging Configuration
-- Message handling, storage, delivery, and advanced messaging features
-- XEP-0313: Message Archive Management, XEP-0280: Message Carbons, XEP-0184: Message Delivery Receipts
-- XEP-0085: Chat State Notifications, XEP-0203: Delayed Delivery, XEP-0308: Last Message Correction
-- Comprehensive messaging service implementation

local messaging_config = {
	-- Core Messaging Services
	-- Essential message handling capabilities
	core_messaging = {
		"offline", -- Offline message storage
		"carbons", -- XEP-0280: Message Carbons
		"mam", -- XEP-0313: Message Archive Management
	},

	-- Message Delivery Services
	-- Enhanced message delivery and reliability
	delivery_services = {
		"smacks", -- XEP-0198: Stream Management
		"csi_simple", -- XEP-0352: Client State Indication
	},

	-- Message Enhancement Services
	-- Advanced messaging features
	enhancement_services = {
		"delay", -- XEP-0203: Delayed Delivery
		-- Note: chatstates, receipts, replace, attention are client-side features
		-- They work automatically without server modules
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

-- Stream Management Configuration
-- XEP-0198: Stream Management
smacks_config = {
	-- Basic stream management settings
	enabled = true, -- Enable stream management

	-- Resumption settings
	resumption_settings = {
		max_hibernation_time = 300, -- Maximum hibernation time (5 minutes)
		hibernation_timeout = 60, -- Hibernation timeout (1 minute)
		max_unacked_stanzas = 5, -- Maximum unacked stanzas before forcing ack
	},

	-- Performance settings
	performance_settings = {
		ack_frequency = 5, -- Request ack every 5 stanzas
		enable_resumption = true, -- Enable stream resumption
		queue_offline_messages = true, -- Queue messages during hibernation
	},
}

-- Client State Indication Configuration
-- XEP-0352: Client State Indication
csi_config = {
	-- Basic CSI settings
	enabled = true, -- Enable client state indication

	-- State handling
	state_handling = {
		queue_chat_states = true, -- Queue chat state notifications
		queue_presence = true, -- Queue presence updates
		important_payloads = { "urn:xmpp:chat-markers:0" }, -- Always deliver these
	},

	-- Mobile optimizations
	mobile_optimizations = {
		reduce_presence_frequency = true, -- Reduce presence update frequency
		delay_non_urgent = 300, -- Delay non-urgent messages (5 minutes)
		flush_on_message = true, -- Flush queue when user sends message
	},
}

-- Export configuration
return {
	modules = apply_messaging_config(),
	mam_config = mam_config,
	carbons_config = carbons_config,
	offline_config = offline_config,
	smacks_config = smacks_config,
	csi_config = csi_config,
}
