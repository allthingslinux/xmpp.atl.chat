-- Layer 04: Protocol - Extensions Configuration
-- Modern XMPP Extension Protocols (XEPs) - Well-established and commonly used extensions
-- Focuses on stable, widely-adopted XEPs that enhance XMPP functionality
-- Organized by functional categories for better maintainability

local extensions_config = {
	-- Message Extensions
	-- Enhanced messaging capabilities
	message_extensions = {
		"carbons", -- XEP-0280: Message Carbons
		"mam", -- XEP-0313: Message Archive Management
		"receipts", -- XEP-0184: Message Delivery Receipts
		"chatstates", -- XEP-0085: Chat State Notifications
		"attention", -- XEP-0224: Attention
		"delay", -- XEP-0203: Delayed Delivery
		"replace", -- XEP-0308: Last Message Correction
		"reactions", -- XEP-0444: Message Reactions
	},

	-- Presence Extensions
	-- Enhanced presence and availability features
	presence_extensions = {
		"last", -- XEP-0012: Last Activity
		"idle", -- XEP-0319: Last User Interaction in Presence
		"mood", -- XEP-0107: User Mood
		"activity", -- XEP-0108: User Activity
		"tune", -- XEP-0118: User Tune
		"geoloc", -- XEP-0080: User Location
		"nick", -- XEP-0172: User Nickname
	},

	-- Multi-User Chat Extensions
	-- Group chat and conference features
	muc_extensions = {
		"muc", -- XEP-0045: Multi-User Chat
		"muc_mam", -- XEP-0313: Message Archive Management for MUC
		"muc_unique", -- XEP-0307: Unique Room Names for Multi-User Chat
		"muc_limits", -- XEP-0045: MUC room limits and restrictions
		"occupant_id", -- XEP-0421: Anonymous unique occupant identifiers for MUCs
		"muc_hats", -- XEP-0317: Hats
	},

	-- File Transfer and Media
	-- File sharing and media transfer capabilities
	file_transfer = {
		"http_upload", -- XEP-0363: HTTP File Upload
		"http_upload_external", -- External HTTP upload services
		"ibb", -- XEP-0047: In-Band Bytestreams
		"s5b", -- XEP-0065: SOCKS5 Bytestreams
		"jingle", -- XEP-0166: Jingle
		"jingle_ft", -- XEP-0234: Jingle File Transfer
		"thumbnails", -- XEP-0264: Jingle Content Thumbnails
	},

	-- Publish-Subscribe
	-- Event notification and data syndication
	pubsub_extensions = {
		"pubsub", -- XEP-0060: Publish-Subscribe
		"pep", -- XEP-0163: Personal Eventing Protocol
		"pubsub_subscription", -- Enhanced subscription management
		"pubsub_owner", -- Node ownership and management
		"pubsub_publish_options", -- XEP-0060: Publish options
		"pubsub_delete_items", -- Item deletion capabilities
	},

	-- Real-Time Communication
	-- Voice, video, and real-time features
	rtc_extensions = {
		"jingle_ice", -- XEP-0176: Jingle ICE-UDP Transport Method
		"jingle_rtp", -- XEP-0167: Jingle RTP Sessions
		"jingle_dtls", -- XEP-0320: Use of DTLS-SRTP in Jingle Sessions
		"external_services", -- XEP-0215: External Service Discovery
		"turncredentials", -- TURN credentials for WebRTC
		"stun", -- STUN server support
	},

	-- Mobile and Push Notifications
	-- Mobile client optimizations and push notifications
	mobile_extensions = {
		"push", -- XEP-0357: Push Notifications
		"csi", -- XEP-0352: Client State Indication
		"smacks", -- XEP-0198: Stream Management
		"throttle_presence", -- Presence throttling for mobile
		"filter_chatstates", -- Chat state filtering for mobile
		"mobile_optimization", -- General mobile optimizations
	},

	-- Security and Privacy Extensions
	-- Enhanced security and privacy features
	security_extensions = {
		"blocking", -- XEP-0191: Blocking Command
		"privacy", -- XEP-0016: Privacy Lists (legacy support)
		"spam_reporting", -- XEP-0377: Spam Reporting
		"sasl2", -- XEP-0388: Extensible SASL Profile
		"fast", -- XEP-0484: Fast Authentication Streamlining Tokens
		"bind2", -- XEP-0386: Bind 2.0
	},

	-- Service Discovery Extensions
	-- Enhanced service discovery and capabilities
	disco_extensions = {
		"adhoc", -- XEP-0050: Ad-Hoc Commands
		"commands", -- Command execution framework
		"dataforms", -- XEP-0004: Data Forms
		"feature_neg", -- XEP-0020: Feature Negotiation
		"disco_info", -- Enhanced service discovery info
		"disco_items", -- Enhanced service discovery items
	},
}

-- Apply extensions configuration based on environment
local function apply_extensions_config()
	local env_type = prosody.config.get("*", "environment_type") or "production"

	-- Core modules (always enabled)
	local core_modules = {}

	-- Message extensions (always enabled)
	for _, module in ipairs(extensions_config.message_extensions) do
		table.insert(core_modules, module)
	end

	-- Presence extensions (always enabled)
	for _, module in ipairs(extensions_config.presence_extensions) do
		table.insert(core_modules, module)
	end

	-- MUC extensions (always enabled)
	for _, module in ipairs(extensions_config.muc_extensions) do
		table.insert(core_modules, module)
	end

	-- File transfer (always enabled)
	for _, module in ipairs(extensions_config.file_transfer) do
		table.insert(core_modules, module)
	end

	-- PubSub extensions (production and staging)
	if env_type ~= "development" then
		for _, module in ipairs(extensions_config.pubsub_extensions) do
			table.insert(core_modules, module)
		end
	end

	-- RTC extensions (production and staging)
	if env_type ~= "development" then
		for _, module in ipairs(extensions_config.rtc_extensions) do
			table.insert(core_modules, module)
		end
	end

	-- Mobile extensions (always enabled)
	for _, module in ipairs(extensions_config.mobile_extensions) do
		table.insert(core_modules, module)
	end

	-- Security extensions (always enabled)
	for _, module in ipairs(extensions_config.security_extensions) do
		table.insert(core_modules, module)
	end

	-- Discovery extensions (always enabled)
	for _, module in ipairs(extensions_config.disco_extensions) do
		table.insert(core_modules, module)
	end

	return core_modules
end

-- Message Archive Management Configuration
-- XEP-0313: Message Archive Management
mam_config = {
	-- Basic MAM settings
	enabled = true, -- Enable MAM

	-- Storage settings
	storage_settings = {
		default_archive_policy = "roster", -- Default archiving policy
		max_archive_query_results = 50, -- Maximum results per query
		archive_expires_after = 365 * 24 * 3600, -- Archive expiry (1 year)

		-- Archive policies
		archive_policies = {
			always = true, -- Always archive
			never = true, -- Never archive
			roster = true, -- Archive roster contacts only
		},
	},

	-- Query settings
	query_settings = {
		max_query_results = 250, -- Maximum query results
		default_page_size = 50, -- Default pagination size
		max_query_timespan = 30 * 24 * 3600, -- Maximum query timespan (30 days)

		-- Query optimizations
		enable_query_cache = true, -- Cache query results
		cache_ttl = 300, -- Cache TTL (5 minutes)
	},

	-- Privacy settings
	privacy_settings = {
		respect_privacy_lists = true, -- Respect privacy list settings
		respect_blocking = true, -- Respect blocking settings
		anonymize_muc_archives = false, -- Anonymize MUC archives
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

		-- Carbon filtering
		filter_duplicates = true, -- Filter duplicate carbons
		filter_errors = true, -- Filter error messages
		filter_chat_states = true, -- Filter chat state notifications
	},

	-- Performance settings
	performance_settings = {
		max_carbons_per_user = 10, -- Maximum carbon recipients per user
		carbon_delivery_timeout = 30, -- Carbon delivery timeout (seconds)
		batch_carbon_delivery = true, -- Batch carbon delivery
	},
}

-- HTTP File Upload Configuration
-- XEP-0363: HTTP File Upload
http_upload_config = {
	-- Basic upload settings
	enabled = true, -- Enable HTTP file upload

	-- Upload limits
	upload_limits = {
		max_file_size = 100 * 1024 * 1024, -- Maximum file size (100MB)
		max_files_per_day = 100, -- Maximum files per user per day
		max_total_size_per_day = 1024 * 1024 * 1024, -- Max total size per day (1GB)

		-- File type restrictions
		allowed_file_types = { -- Allowed MIME types
			"image/jpeg",
			"image/png",
			"image/gif",
			"image/webp",
			"audio/mpeg",
			"audio/ogg",
			"audio/wav",
			"video/mp4",
			"video/webm",
			"video/ogg",
			"application/pdf",
			"text/plain",
		},
		blocked_file_types = { -- Blocked MIME types
			"application/x-executable",
			"application/x-dosexec",
			"application/x-msdownload",
		},
	},

	-- Storage settings
	storage_settings = {
		storage_path = "/var/lib/prosody/http_upload", -- Upload storage path
		base_url = "https://upload.example.com", -- Base URL for uploads

		-- Cleanup settings
		expire_after = 30 * 24 * 3600, -- File expiry (30 days)
		cleanup_interval = 24 * 3600, -- Cleanup interval (24 hours)
	},

	-- Security settings
	security_settings = {
		require_authentication = true, -- Require authentication
		validate_file_content = true, -- Validate file content
		scan_for_malware = false, -- Scan for malware (requires external service)
		generate_thumbnails = false, -- Generate thumbnails
	},
}

-- Multi-User Chat Configuration
-- XEP-0045: Multi-User Chat
muc_config = {
	-- Basic MUC settings
	enabled = true, -- Enable MUC

	-- Room settings
	room_settings = {
		max_rooms = 1000, -- Maximum rooms
		max_occupants_per_room = 100, -- Maximum occupants per room
		default_room_config = {
			persistent = true, -- Rooms are persistent by default
			public = true, -- Rooms are public by default
			members_only = false, -- Rooms are not members-only by default
			moderated = false, -- Rooms are not moderated by default
		},

		-- Room limits
		max_room_name_length = 100, -- Maximum room name length
		max_room_description_length = 500, -- Maximum room description length
		max_history_messages = 50, -- Maximum history messages
	},

	-- Occupant settings
	occupant_settings = {
		max_nick_length = 50, -- Maximum nickname length
		allow_nick_changes = true, -- Allow nickname changes
		unique_nicks = false, -- Require unique nicknames

		-- Presence settings
		broadcast_presence_changes = true, -- Broadcast presence changes
		show_join_leave = true, -- Show join/leave messages
		show_status_changes = true, -- Show status changes
	},

	-- Moderation settings
	moderation_settings = {
		enable_room_logging = false, -- Enable room logging
		log_room_config_changes = true, -- Log room configuration changes
		auto_destroy_empty_rooms = false, -- Auto-destroy empty rooms
		empty_room_timeout = 24 * 3600, -- Empty room timeout (24 hours)
	},
}

-- Push Notifications Configuration
-- XEP-0357: Push Notifications
push_config = {
	-- Basic push settings
	enabled = true, -- Enable push notifications

	-- Push services
	push_services = {
		-- Example push service configuration
		-- fcm = {
		--     type = "fcm",
		--     endpoint = "https://fcm.googleapis.com/fcm/send",
		--     auth_key = "your-server-key",
		-- },
		-- apns = {
		--     type = "apns",
		--     endpoint = "https://api.push.apple.com",
		--     certificate = "/path/to/certificate.pem",
		-- }
	},

	-- Push behavior
	push_behavior = {
		push_on_message = true, -- Push on new messages
		push_on_mention = true, -- Push on mentions
		push_on_subscription = true, -- Push on subscription requests

		-- Push filtering
		respect_do_not_disturb = true, -- Respect DND status
		quiet_hours = { -- Quiet hours (no push)
			enabled = false,
			start_hour = 22, -- 10 PM
			end_hour = 7, -- 7 AM
		},
	},

	-- Performance settings
	performance_settings = {
		max_push_attempts = 3, -- Maximum push attempts
		push_timeout = 30, -- Push timeout (seconds)
		batch_push_notifications = true, -- Batch notifications
		push_rate_limit = 10, -- Push rate limit (per minute)
	},
}

-- Publish-Subscribe Configuration
-- XEP-0060: Publish-Subscribe
pubsub_config = {
	-- Basic PubSub settings
	enabled = true, -- Enable PubSub

	-- Node settings
	node_settings = {
		max_nodes = 1000, -- Maximum nodes
		max_items_per_node = 1000, -- Maximum items per node
		max_item_size = 65536, -- Maximum item size (64KB)

		-- Node policies
		default_access_model = "open", -- Default access model
		allow_node_creation = true, -- Allow node creation
		auto_create_nodes = false, -- Auto-create nodes
	},

	-- Subscription settings
	subscription_settings = {
		max_subscriptions_per_user = 100, -- Maximum subscriptions per user
		allow_subscription_notifications = true, -- Allow subscription notifications

		-- Subscription policies
		default_subscription_policy = "open", -- Default subscription policy
		require_subscription_approval = false, -- Require approval for subscriptions
	},

	-- Publishing settings
	publishing_settings = {
		max_publish_rate = 10, -- Maximum publish rate (per minute)
		allow_item_deletion = true, -- Allow item deletion
		persist_items = true, -- Persist published items

		-- Publishing policies
		default_publish_model = "publishers", -- Default publish model
		require_publisher_approval = false, -- Require approval for publishing
	},
}

-- Ad-Hoc Commands Configuration
-- XEP-0050: Ad-Hoc Commands
adhoc_config = {
	-- Basic ad-hoc settings
	enabled = true, -- Enable ad-hoc commands

	-- Command settings
	command_settings = {
		max_concurrent_commands = 10, -- Maximum concurrent commands per user
		command_timeout = 300, -- Command timeout (5 minutes)

		-- Command permissions
		require_admin_for_server_commands = true, -- Require admin for server commands
		allow_user_commands = true, -- Allow user-level commands
	},

	-- Available commands
	available_commands = {
		-- Server management commands
		"reload_modules", -- Reload modules
		"shutdown", -- Server shutdown
		"get_server_info", -- Get server information

		-- User management commands
		"change_password", -- Change user password
		"delete_account", -- Delete user account
		"get_user_info", -- Get user information
	},

	-- Security settings
	security_settings = {
		log_command_execution = true, -- Log command execution
		require_secure_connection = false, -- Require secure connection
		rate_limit_commands = true, -- Rate limit command execution
		max_commands_per_minute = 5, -- Maximum commands per minute
	},
}

-- Export configuration
return {
	modules = apply_extensions_config(),
	mam_config = mam_config,
	carbons_config = carbons_config,
	http_upload_config = http_upload_config,
	muc_config = muc_config,
	push_config = push_config,
	pubsub_config = pubsub_config,
	adhoc_config = adhoc_config,
}
