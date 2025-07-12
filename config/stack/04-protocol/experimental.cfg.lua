-- Layer 04: Protocol - Experimental Configuration
-- Cutting-edge XEPs, experimental features, and emerging XMPP technologies
-- Draft XEPs, experimental implementations, and bleeding-edge features
-- Use with caution - these features may change or be deprecated

local experimental_config = {
	-- Experimental Messaging Features
	-- Cutting-edge messaging enhancements
	experimental_messaging = {
		"message_retraction", -- XEP-0424: Message Retraction (community)
		"message_moderation", -- XEP-0425: Message Moderation (community)
		"message_styling", -- XEP-0393: Message Styling (community)
		"spoiler_messages", -- XEP-0382: Spoiler Messages (community)
		"message_fastening", -- XEP-0422: Message Fastening (community)
	},

	-- Experimental Authentication Features
	-- Next-generation authentication mechanisms
	experimental_auth = {
		-- Note: SASL 2.0 modules are experimental and may be unstable
		-- Uncomment only for testing purposes
		-- "sasl2", -- XEP-0388: Extensible SASL Profile (community)
		-- "sasl2_bind2", -- XEP-0386: Bind 2 (community)
		-- "sasl2_fast", -- XEP-0484: Fast Authentication Streamlining Tokens (community)
		-- "sasl2_sm", -- XEP-0198 integration with SASL2 (community)
	},

	-- Experimental Push Features
	-- Advanced push notification capabilities
	experimental_push = {
		-- "push2", -- Push 2.0 - New Cloud-Notify (community)
		-- "cloud_notify_encrypted", -- Encrypted push notifications (community)
	},

	-- Experimental MUC Features
	-- Advanced multi-user chat capabilities
	experimental_muc = {
		-- "muc_hats", -- XEP-0317: Hats (community)
		-- "muc_occupant_id", -- XEP-0421: Occupant identifiers (community)
	},
}

-- Apply experimental configuration based on environment and settings
local function apply_experimental_config()
	local env_type = prosody.config.get("*", "environment_type") or "production"
	local enable_experimental = prosody.config.get("*", "enable_experimental_features") or false

	-- Only enable experimental features if explicitly requested and not in production
	if not enable_experimental or env_type == "production" then
		return {}
	end

	local core_modules = {}

	-- Experimental messaging (development and staging)
	if env_type ~= "production" then
		for _, module in ipairs(experimental_config.experimental_messaging) do
			table.insert(core_modules, module)
		end
	end

	-- Modern authentication (staging only)
	if env_type == "staging" then
		for _, module in ipairs(experimental_config.experimental_auth) do
			table.insert(core_modules, module)
		end
	end

	-- Mobile and IoT (development only)
	if env_type == "development" then
		for _, module in ipairs(experimental_config.experimental_mobile) do
			table.insert(core_modules, module)
		end
	end

	-- RTC advanced (development only)
	if env_type == "development" then
		for _, module in ipairs(experimental_config.experimental_protocols) do
			table.insert(core_modules, module)
		end
	end

	-- Privacy and security enhancements (development and staging)
	if env_type ~= "production" then
		for _, module in ipairs(experimental_config.privacy_security) do
			table.insert(core_modules, module)
		end
	end

	-- Emerging standards (development only)
	if env_type == "development" then
		for _, module in ipairs(experimental_config.emerging_standards) do
			table.insert(core_modules, module)
		end
	end

	return core_modules
end

-- Message Retraction Configuration
-- XEP-0424: Message Retraction
message_retraction_config = {
	-- Basic retraction settings
	enabled = false, -- Disabled by default (experimental)

	-- Retraction policies
	retraction_policies = {
		allow_retraction = true, -- Allow message retraction
		time_limit = 300, -- Retraction time limit (5 minutes)
		require_reason = false, -- Require retraction reason

		-- Who can retract
		author_can_retract = true, -- Message author can retract
		moderator_can_retract = true, -- Moderators can retract
		admin_can_retract = true, -- Admins can retract
	},

	-- Retraction behavior
	retraction_behavior = {
		preserve_metadata = true, -- Preserve message metadata
		tombstone_message = true, -- Leave tombstone message
		notify_participants = true, -- Notify all participants

		-- Archive handling
		remove_from_archive = false, -- Don't remove from MAM archive
		mark_as_retracted = true, -- Mark as retracted in archive
	},
}

-- SASL 2.0 Configuration
-- XEP-0388: Extensible SASL Profile
sasl2_config = {
	-- Basic SASL 2.0 settings
	enabled = false, -- Disabled by default (experimental)

	-- SASL 2.0 features
	features = {
		inline_features = true, -- Inline stream features
		bind2_integration = true, -- Bind 2.0 integration
		fast_integration = true, -- FAST integration
	},

	-- Authentication mechanisms
	mechanisms = {
		"SCRAM-SHA-256-PLUS", -- SCRAM with channel binding
		"SCRAM-SHA-256",
		"SCRAM-SHA-1-PLUS",
		"SCRAM-SHA-1",
	},
}

-- Message Moderation Configuration
-- XEP-0425: Message Moderation
message_moderation_config = {
	-- Basic moderation settings
	enabled = false, -- Disabled by default (experimental)

	-- Moderation policies
	moderation_policies = {
		allow_moderation = true, -- Allow message moderation
		require_reason = true, -- Require moderation reason
		preserve_metadata = true, -- Preserve message metadata

		-- Who can moderate
		moderator_can_moderate = true, -- Moderators can moderate
		admin_can_moderate = true, -- Admins can moderate
		author_can_moderate = false, -- Authors cannot moderate their own messages
	},

	-- Moderation behavior
	moderation_behavior = {
		tombstone_message = true, -- Leave tombstone message
		notify_participants = true, -- Notify all participants
		log_moderation = true, -- Log moderation actions

		-- Archive handling
		remove_from_archive = false, -- Don't remove from MAM archive
		mark_as_moderated = true, -- Mark as moderated in archive
	},
}

-- Message Styling Configuration
-- XEP-0393: Message Styling
message_styling_config = {
	-- Basic styling settings
	enabled = false, -- Disabled by default (experimental)

	-- Styling features
	styling_features = {
		emphasis = true, -- *emphasis*
		strong_emphasis = true, -- **strong emphasis**
		strikethrough = true, -- ~strikethrough~
		preformatted = true, -- ```preformatted```
		inline_code = true, -- `inline code`
	},

	-- Styling policies
	styling_policies = {
		max_nesting_depth = 3, -- Maximum nesting depth
		max_styling_length = 1000, -- Maximum styled text length
		allow_mixed_styling = true, -- Allow mixed styling
	},
}

-- Spoiler Messages Configuration
-- XEP-0382: Spoiler Messages
spoiler_messages_config = {
	-- Basic spoiler settings
	enabled = false, -- Disabled by default (experimental)

	-- Spoiler policies
	spoiler_policies = {
		allow_spoilers = true, -- Allow spoiler messages
		require_hint = false, -- Require spoiler hint
		max_hint_length = 100, -- Maximum hint length
	},

	-- Spoiler behavior
	spoiler_behavior = {
		preserve_in_archive = true, -- Preserve spoilers in archive
		show_hint_in_notifications = false, -- Don't show hint in notifications
	},
}

-- Mobile Optimizations Configuration
-- XEP-0286: Mobile Considerations
mobile_optimizations_config = {
	-- Basic mobile settings
	enabled = false, -- Disabled by default (experimental)

	-- Mobile features
	mobile_features = {
		battery_optimization = true, -- Battery optimization
		bandwidth_optimization = true, -- Bandwidth optimization
		push_integration = true, -- Push notification integration
		background_sync = true, -- Background synchronization
	},

	-- Mobile policies
	mobile_policies = {
		max_offline_messages = 50, -- Maximum offline messages
		compress_images = true, -- Compress images
		defer_non_critical = true, -- Defer non-critical operations
	},
}

-- Privacy and Security Enhancements Configuration
privacy_security_config = {
	-- Basic privacy settings
	enabled = false, -- Disabled by default (experimental)

	-- Privacy features
	privacy_features = {
		forward_secrecy = true, -- Forward secrecy
		perfect_forward_secrecy = false, -- Perfect forward secrecy (experimental)
		message_mixing = false, -- MIX support (experimental)
	},

	-- Security policies
	security_policies = {
		require_encryption = false, -- Require encryption
		block_unencrypted = false, -- Block unencrypted messages
		audit_security_events = true, -- Audit security events
	},
}

-- Return experimental configuration
return {
	experimental_config = experimental_config,
	apply_experimental_config = apply_experimental_config,
	message_retraction_config = message_retraction_config,
	sasl2_config = sasl2_config,
	message_moderation_config = message_moderation_config,
	message_styling_config = message_styling_config,
	spoiler_messages_config = spoiler_messages_config,
	mobile_optimizations_config = mobile_optimizations_config,
	privacy_security_config = privacy_security_config,
}
