-- Layer 03: Stanza - Processing Configuration
-- Stanza processing pipelines, transformation, and workflow management
-- XEP-0079: Advanced Message Processing, XEP-0033: Extended Stanza Addressing
-- XEP-0131: Stanza Headers and Internet Metadata, XEP-0297: Stanza Forwarding
-- Comprehensive stanza processing and transformation

local processing_config = {
	-- Core Processing Modules
	-- Essential stanza processing
	core_processing = {
		"stanza_router", -- Core stanza routing
		"message_router", -- Message routing logic
		"presence_router", -- Presence routing logic
		"iq_router", -- IQ routing logic
	},

	-- Advanced Message Processing (XEP-0079)
	-- Sophisticated message processing capabilities
	amp_processing = {
		"amp", -- XEP-0079: Advanced Message Processing
		"amp_rules", -- AMP rule processing
		"message_conditions", -- Message condition evaluation
		"delivery_semantics", -- Message delivery semantics
	},

	-- Stanza Transformation
	-- Stanza modification and transformation
	transformation = {
		"stanza_modify", -- Stanza modification
		"address_rewrite", -- Address rewriting
		"content_transform", -- Content transformation
		"namespace_transform", -- Namespace transformation
	},

	-- Extended Processing Features
	-- Extended stanza addressing and headers
	extended_processing = {
		"address", -- XEP-0033: Extended Stanza Addressing
		"stanza_headers", -- XEP-0131: Stanza Headers and Internet Metadata
		"forwarding", -- XEP-0297: Stanza Forwarding
		"delay", -- XEP-0203: Delayed Delivery
	},

	-- Pipeline Processing
	-- Processing pipeline management
	pipeline_processing = {
		"processing_hints", -- XEP-0334: Message Processing Hints
		"priority", -- Message priority handling
		"queueing", -- Message queueing
		"batch_processing", -- Batch processing
	},

	-- Workflow and Automation
	-- Automated processing workflows
	workflow_processing = {
		"auto_responder", -- Automatic response generation
		"message_routing_rules", -- Message routing rules
		"conditional_processing", -- Conditional processing logic
		"event_triggers", -- Event-triggered processing
	},

	-- Performance Processing
	-- Performance-optimized processing
	performance_processing = {
		"async_processing", -- Asynchronous processing
		"parallel_processing", -- Parallel processing
		"cache_processing", -- Cached processing results
		"lazy_evaluation", -- Lazy evaluation
	},
}

-- Apply processing configuration based on environment
local function apply_processing_config()
	local env_type = prosody.config.get("*", "environment_type") or "production"

	-- Core processing modules (always enabled)
	local core_modules = {}

	-- Essential processing
	for _, module in ipairs(processing_config.core_processing) do
		table.insert(core_modules, module)
	end

	-- AMP processing (production and staging)
	if env_type ~= "development" then
		for _, module in ipairs(processing_config.amp_processing) do
			table.insert(core_modules, module)
		end
	end

	-- Transformation (always enabled)
	for _, module in ipairs(processing_config.transformation) do
		table.insert(core_modules, module)
	end

	-- Extended processing (production and staging)
	if env_type ~= "development" then
		for _, module in ipairs(processing_config.extended_processing) do
			table.insert(core_modules, module)
		end
	end

	-- Pipeline processing (always enabled)
	for _, module in ipairs(processing_config.pipeline_processing) do
		table.insert(core_modules, module)
	end

	-- Workflow processing (production only)
	if env_type == "production" then
		for _, module in ipairs(processing_config.workflow_processing) do
			table.insert(core_modules, module)
		end
	end

	-- Performance processing (production and staging)
	if env_type ~= "development" then
		for _, module in ipairs(processing_config.performance_processing) do
			table.insert(core_modules, module)
		end
	end

	return core_modules
end

-- Stanza Router Configuration
-- Core stanza routing and dispatch
stanza_router_config = {
	-- Basic routing settings
	enable_routing = true, -- Enable stanza routing

	-- Routing priorities
	routing_priorities = {
		iq = 10, -- IQ stanza priority
		message = 5, -- Message stanza priority
		presence = 1, -- Presence stanza priority
	},

	-- Routing rules
	routing_rules = {
		-- Local delivery rules
		local_delivery = {
			enabled = true, -- Enable local delivery
			check_user_exists = true, -- Check if user exists
			offline_storage = true, -- Store offline messages
		},

		-- Remote delivery rules
		remote_delivery = {
			enabled = true, -- Enable remote delivery
			s2s_required = true, -- Require S2S for remote delivery
			fallback_mechanisms = { "s2s", "component" }, -- Fallback mechanisms
		},

		-- Component delivery rules
		component_delivery = {
			enabled = true, -- Enable component delivery
			trusted_components = {}, -- Trusted component list
			component_timeout = 30, -- Component timeout (seconds)
		},
	},

	-- Error handling
	error_handling = {
		generate_errors = true, -- Generate error responses
		error_types = { -- Error type mapping
			["feature-not-implemented"] = "cancel",
			["service-unavailable"] = "wait",
			["item-not-found"] = "cancel",
		},
		max_error_retries = 3, -- Maximum error retries
	},
}

-- Advanced Message Processing Configuration
-- XEP-0079: Advanced Message Processing
amp_config = {
	-- Basic AMP settings
	enabled = false, -- Enable AMP (disabled by default)

	-- Supported conditions
	supported_conditions = {
		"deliver", -- Delivery condition
		"expire-at", -- Expiration condition
		"match-resource", -- Resource matching condition
	},

	-- Supported actions
	supported_actions = {
		"alert", -- Alert action
		"drop", -- Drop action
		"error", -- Error action
		"notify", -- Notify action
	},

	-- Processing rules
	processing_rules = {
		max_conditions = 10, -- Maximum conditions per message
		max_rule_depth = 5, -- Maximum rule nesting depth
		timeout = 300, -- Processing timeout (5 minutes)
	},

	-- Delivery semantics
	delivery_semantics = {
		exactly_once = false, -- Exactly-once delivery
		at_least_once = true, -- At-least-once delivery
		at_most_once = false, -- At-most-once delivery
	},
}

-- Extended Stanza Addressing Configuration
-- XEP-0033: Extended Stanza Addressing
addressing_config = {
	-- Basic addressing settings
	enabled = true, -- Enable extended addressing

	-- Address types
	supported_address_types = {
		"to", -- Primary recipient
		"cc", -- Carbon copy
		"bcc", -- Blind carbon copy
		"replyto", -- Reply-to address
		"replyroom", -- Reply-to room
		"noreply", -- No-reply address
	},

	-- Addressing limits
	addressing_limits = {
		max_addresses = 100, -- Maximum addresses per stanza
		max_to_addresses = 10, -- Maximum 'to' addresses
		max_cc_addresses = 50, -- Maximum 'cc' addresses
		max_bcc_addresses = 50, -- Maximum 'bcc' addresses
	},

	-- Privacy settings
	privacy_settings = {
		hide_bcc_addresses = true, -- Hide BCC addresses
		validate_addresses = true, -- Validate address format
		check_permissions = true, -- Check addressing permissions
	},

	-- Delivery settings
	delivery_settings = {
		parallel_delivery = true, -- Parallel delivery to multiple recipients
		continue_on_error = true, -- Continue delivery on individual errors
		aggregate_errors = true, -- Aggregate delivery errors
	},
}

-- Stanza Forwarding Configuration
-- XEP-0297: Stanza Forwarding
forwarding_config = {
	-- Basic forwarding settings
	enabled = true, -- Enable stanza forwarding

	-- Forwarding rules
	forwarding_rules = {
		preserve_original = true, -- Preserve original stanza
		add_forwarded_headers = true, -- Add forwarded headers
		validate_forwarded = true, -- Validate forwarded stanzas
	},

	-- Security settings
	security_settings = {
		verify_forwarder = true, -- Verify forwarder identity
		trusted_forwarders = {}, -- Trusted forwarder list
		max_forwarding_depth = 5, -- Maximum forwarding depth
	},

	-- Performance settings
	performance_settings = {
		cache_forwarded = true, -- Cache forwarded stanzas
		async_forwarding = true, -- Asynchronous forwarding
		batch_forwarding = false, -- Batch forwarding
	},
}

-- Message Processing Hints Configuration
-- XEP-0334: Message Processing Hints
processing_hints_config = {
	-- Basic hints settings
	enabled = true, -- Enable processing hints

	-- Supported hints
	supported_hints = {
		"no-copy", -- No copies hint
		"no-store", -- No storage hint
		"no-permanent-store", -- No permanent storage hint
		"store", -- Store hint
	},

	-- Hint processing
	hint_processing = {
		respect_no_copy = true, -- Respect no-copy hint
		respect_no_store = true, -- Respect no-store hint
		respect_store = true, -- Respect store hint
		override_policy = false, -- Allow policy override
	},

	-- Default behaviors
	default_behaviors = {
		default_store_policy = "auto", -- Default storage policy
		default_copy_policy = "auto", -- Default copy policy
		hint_precedence = "hint", -- Precedence: hint, policy, default
	},
}

-- Delayed Delivery Configuration
-- XEP-0203: Delayed Delivery
delayed_delivery_config = {
	-- Basic delay settings
	enabled = true, -- Enable delayed delivery

	-- Delay processing
	delay_processing = {
		add_delay_stamps = true, -- Add delay timestamps
		preserve_original_delay = true, -- Preserve original delay info
		update_delay_reason = true, -- Update delay reason
	},

	-- Delay reasons
	delay_reasons = {
		"offline", -- User offline
		"resource-constraint", -- Resource constraint
		"service-unavailable", -- Service unavailable
		"policy-violation", -- Policy violation
	},

	-- Performance settings
	performance_settings = {
		max_delay_time = 86400, -- Maximum delay time (24 hours)
		cleanup_interval = 3600, -- Cleanup interval (1 hour)
		batch_processing = true, -- Batch delayed messages
	},
}

-- Processing Pipeline Configuration
-- Message processing pipeline settings
pipeline_config = {
	-- Pipeline stages
	pipeline_stages = {
		"input_validation", -- Input validation stage
		"preprocessing", -- Preprocessing stage
		"routing_decision", -- Routing decision stage
		"transformation", -- Transformation stage
		"delivery_preparation", -- Delivery preparation stage
		"output_processing", -- Output processing stage
	},

	-- Stage configuration
	stage_config = {
		parallel_stages = { "transformation", "delivery_preparation" }, -- Parallel stages
		critical_stages = { "input_validation", "routing_decision" }, -- Critical stages
		optional_stages = { "preprocessing", "output_processing" }, -- Optional stages
	},

	-- Error handling
	pipeline_error_handling = {
		stop_on_critical_error = true, -- Stop pipeline on critical errors
		retry_failed_stages = true, -- Retry failed stages
		max_retries = 3, -- Maximum retries per stage
		fallback_pipeline = "minimal", -- Fallback pipeline
	},

	-- Performance settings
	pipeline_performance = {
		async_stages = true, -- Asynchronous stage processing
		stage_timeout = 10, -- Stage timeout (seconds)
		pipeline_timeout = 60, -- Total pipeline timeout (seconds)
		enable_profiling = false, -- Enable pipeline profiling
	},
}

-- Export configuration
return {
	modules = apply_processing_config(),
	stanza_router_config = stanza_router_config,
	amp_config = amp_config,
	addressing_config = addressing_config,
	forwarding_config = forwarding_config,
	processing_hints_config = processing_hints_config,
	delayed_delivery_config = delayed_delivery_config,
	pipeline_config = pipeline_config,
}
