-- Layer 02: Stream - Stream Feature Negotiation Configuration
-- Service discovery, entity capabilities, and mobile optimizations
-- XEP-0030: Service Discovery, XEP-0115: Entity Capabilities, XEP-0352: Client State Indication

local negotiation_config = {
	-- Service Discovery and Capabilities
	-- Core discovery mechanisms for XMPP features
	discovery = {
		"disco", -- XEP-0030: Service Discovery
		"caps", -- XEP-0115: Entity Capabilities
		"extdisco", -- XEP-0215: External Service Discovery
		"server_info", -- Server information discovery
	},

	-- Mobile and Client Optimizations
	-- Battery saving and bandwidth optimization features
	mobile_optimization = {
		"csi_simple", -- XEP-0352: Client State Indication (built-in)
		"csi_battery_saver", -- Battery optimization for mobile clients (community)
		"filter_chatstates", -- Filter chat state notifications (community)
	},

	-- Roster and Presence Management
	-- Contact management and presence optimization
	roster_management = {
		"roster", -- RFC 6121: Roster management
		"presence", -- RFC 6121: Presence management
		"pep", -- XEP-0163: Personal Eventing Protocol
		"vcard", -- XEP-0054: vCard storage
		"private", -- XEP-0049: Private XML Storage
	},

	-- Message Archive and History
	-- Message archiving and retrieval capabilities
	archive_features = {
		"mam", -- XEP-0313: Message Archive Management
		"carbons", -- XEP-0280: Message Carbons
		"smacks", -- XEP-0198: Stream Management
	},

	-- Advanced Features
	-- Modern XMPP extensions and capabilities
	advanced_features = {
		"blocking", -- XEP-0191: Blocking Command
		"bookmarks", -- XEP-0048/XEP-0402: Bookmarks
		"ping", -- XEP-0199: XMPP Ping
		"time", -- XEP-0202: Entity Time
		"version", -- XEP-0092: Software Version
	},
}

-- Apply negotiation configuration based on environment and client type
local function apply_negotiation_config()
	local env_type = prosody.config.get("*", "environment_type") or "production"

	-- Core negotiation modules (always enabled)
	local core_modules = {}

	-- Essential service discovery
	for _, module in ipairs(negotiation_config.discovery) do
		table.insert(core_modules, module)
	end

	-- Entity capabilities (always needed)
	for _, module in ipairs(negotiation_config.caps) do
		table.insert(core_modules, module)
	end

	-- Core stream features
	for _, module in ipairs(negotiation_config.stream_features) do
		table.insert(core_modules, module)
	end

	-- Extended discovery (production and staging)
	if env_type ~= "development" then
		for _, module in ipairs(negotiation_config.extended_discovery) do
			table.insert(core_modules, module)
		end
	end

	-- Mobile optimizations (always enabled for modern XMPP)
	for _, module in ipairs(negotiation_config.mobile_optimization) do
		table.insert(core_modules, module)
	end

	-- Roster features (always enabled)
	for _, module in ipairs(negotiation_config.roster_management) do
		table.insert(core_modules, module)
	end

	-- Stream integration features (production and staging)
	if env_type ~= "development" then
		for _, module in ipairs(negotiation_config.archive_features) do
			table.insert(core_modules, module)
		end
	end

	return core_modules
end

-- Service Discovery Configuration
-- XEP-0030: Service Discovery settings
disco_config = {
	-- Server identity
	server_identity = {
		category = "server",
		type = "im",
		name = "AllThingsLinux XMPP Server",
	},

	-- Additional identities
	additional_identities = {
		{ category = "conference", type = "text", name = "Multi-User Chat" },
		{ category = "pubsub", type = "service", name = "Publish-Subscribe" },
		{ category = "proxy", type = "bytestreams", name = "SOCKS5 Bytestreams" },
	},

	-- Server features to advertise
	server_features = {
		"http://jabber.org/protocol/disco#info",
		"http://jabber.org/protocol/disco#items",
		"urn:xmpp:ping",
		"jabber:iq:version",
		"urn:xmpp:time",
		"vcard-temp",
		"urn:ietf:params:xml:ns:vcard-4.0",
	},

	-- Cache settings
	cache_settings = {
		max_cache_size = 1000, -- Maximum cached items
		cache_ttl = 3600, -- Cache TTL in seconds (1 hour)
		enable_cache = true, -- Enable disco caching
	},
}

-- Entity Capabilities Configuration
-- XEP-0115: Entity Capabilities settings
caps_config = {
	-- Capability hash algorithm
	hash_algorithm = "sha-1", -- Standard algorithm for XEP-0115

	-- Cache settings
	cache_size = 10000, -- Maximum cached capabilities
	cache_ttl = 86400, -- Cache TTL in seconds (24 hours)

	-- Verification settings
	verify_caps = true, -- Verify capability hashes
	strict_verification = false, -- Strict verification mode

	-- Performance settings
	lazy_loading = true, -- Load capabilities on demand
	background_verification = true, -- Verify caps in background
}

-- Client State Indication Configuration
-- XEP-0352: Client State Indication for mobile optimization
csi_config = {
	-- Default behavior
	default_state = "active", -- Default client state

	-- Inactive state optimizations
	inactive_optimizations = {
		-- Presence filtering
		filter_presence = {
			enabled = true,
			filter_duplicates = true, -- Filter duplicate presence
			filter_unavailable = false, -- Don't filter unavailable presence
		},

		-- Message filtering
		filter_messages = {
			enabled = false, -- Don't filter messages by default
			delay_groupchat = true, -- Delay groupchat messages
			filter_headlines = true, -- Filter headline messages
		},

		-- Notification priorities
		priority_filtering = {
			enabled = true,
			high_priority_types = { "chat", "error" },
			low_priority_types = { "headline", "groupchat" },
		},
	},

	-- Battery saving features
	battery_saver = {
		enabled = true,
		reduce_keepalives = true, -- Reduce keepalive frequency
		batch_notifications = true, -- Batch notifications when possible
		delay_non_urgent = 300, -- Delay non-urgent messages (5 minutes)
	},
}

-- Roster Versioning Configuration
-- XEP-0237: Roster Versioning for bandwidth optimization
roster_versioning_config = {
	enabled = true, -- Enable roster versioning

	-- Storage settings
	store_versions = true, -- Store roster versions
	max_versions = 100, -- Maximum stored versions per user

	-- Synchronization settings
	sync_on_login = true, -- Sync roster on login
	incremental_sync = true, -- Use incremental synchronization

	-- Performance settings
	cache_rosters = true, -- Cache roster data
	cache_ttl = 3600, -- Cache TTL in seconds
}

-- Server Contact Information
-- XEP-0157: Contact Addresses for XMPP Services
server_contact_info = {
	-- Administrative contacts
	admin_addresses = {
		-- "mailto:admin@example.com",
		-- "xmpp:admin@example.com",
	},

	-- Abuse reporting contacts
	abuse_addresses = {
		-- "mailto:abuse@example.com",
		-- "xmpp:abuse@example.com",
	},

	-- Security contacts
	security_addresses = {
		-- "mailto:security@example.com",
		-- "xmpp:security@example.com",
	},

	-- Support contacts
	support_addresses = {
		-- "mailto:support@example.com",
		-- "xmpp:support@example.com",
	},
}

-- Software Version Information
-- XEP-0092: Software Version
version_config = {
	-- Software information
	software_name = "Prosody",
	software_version = prosody.version,

	-- Operating system (optional)
	show_os = false, -- Don't show OS info for security

	-- Custom version string
	custom_version = "AllThingsLinux XMPP Server",
}

-- Export configuration
return {
	modules = apply_negotiation_config(),
	disco_config = disco_config,
	caps_config = caps_config,
	csi_config = csi_config,
	roster_versioning_config = roster_versioning_config,
	server_contact_info = server_contact_info,
	version_config = version_config,
}
