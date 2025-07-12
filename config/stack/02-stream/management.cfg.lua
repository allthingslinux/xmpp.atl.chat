-- Layer 02: Stream - Stream Management Configuration
-- Stream resumption, client state indication, and mobile optimizations
-- XEP-0198: Stream Management, XEP-0352: Client State Indication

local stream_management_modules = {
	"smacks", -- XEP-0198: Stream Management
	"smacks_offline", -- Offline message handling with SM
	"csi_simple", -- XEP-0352: Client State Indication (built-in)
	"csi_battery_saver", -- Battery optimization for mobile clients (community)
	"filter_chatstates", -- Filter chat states for mobile (community)
}

-- Stream Management configuration
-- XEP-0198: Stream Management
smacks_config = {
	-- Enable stream management
	enabled = true,

	-- Resumption timeout
	-- How long to keep a stream alive for resumption
	resumption_timeout = 300, -- 5 minutes default
	max_resumption_timeout = 3600, -- 1 hour maximum

	-- Hibernation support
	-- Allow clients to hibernate connections
	hibernation_timeout = 60, -- 1 minute hibernation timeout
	max_hibernation_timeout = 300, -- 5 minute maximum hibernation

	-- Stanza queue management
	max_unacked_stanzas = 500, -- Maximum unacked stanzas to queue
	max_queue_size = 1000, -- Maximum total queue size

	-- Ack frequency
	-- How often to request acknowledgments
	ack_frequency = 5, -- Request ack every 5 stanzas
	ack_timeout = 60, -- 1 minute timeout for ack responses

	-- Stream resumption storage
	resumption_storage = "memory", -- memory, sql, file

	-- Mobile optimizations
	mobile_optimizations = {
		enabled = true,

		-- Detect mobile clients
		detect_mobile = true,
		mobile_patterns = {
			"Conversations",
			"ChatSecure",
			"Monal",
			"Siskin",
			"Xabber",
			"Blabber",
		},

		-- Mobile-specific settings
		mobile_resumption_timeout = 900, -- 15 minutes for mobile
		mobile_hibernation_timeout = 300, -- 5 minutes hibernation for mobile
		mobile_ack_frequency = 10, -- Less frequent acks for mobile
	},
}

-- Client State Indication (CSI)
-- XEP-0352: Client State Indication
csi_config = {
	enabled = true,

	-- State management
	default_state = "active", -- active, inactive

	-- Inactive state optimizations
	inactive_optimizations = {
		-- Queue non-important stanzas when inactive
		queue_presence = true, -- Queue presence updates
		queue_chatstates = true, -- Queue chat state notifications
		queue_pep = false, -- Don't queue PEP events (keep real-time)

		-- Delivery delays
		delivery_delay = 30, -- 30 second delay for inactive clients
		max_delay = 300, -- Maximum 5 minute delay

		-- Batching
		batch_stanzas = true, -- Batch multiple stanzas
		max_batch_size = 10, -- Maximum 10 stanzas per batch
		batch_timeout = 60, -- 1 minute batch timeout
	},

	-- Active state behavior
	active_optimizations = {
		-- Immediate delivery when active
		immediate_delivery = true,

		-- Flush queued stanzas
		flush_queue_on_active = true,
		flush_timeout = 5, -- 5 second flush timeout
	},
}

-- Connection reliability features
-- Additional features for connection stability
reliability_features = {
	-- Ping/keepalive management
	keepalive = {
		enabled = true,
		interval = 120, -- 2 minute ping interval
		timeout = 30, -- 30 second ping timeout

		-- Smart keepalive
		adaptive = true, -- Adjust based on connection quality
		min_interval = 60, -- Minimum 1 minute interval
		max_interval = 300, -- Maximum 5 minute interval
	},

	-- Connection quality monitoring
	quality_monitoring = {
		enabled = true,

		-- Metrics to track
		track_latency = true, -- Track round-trip time
		track_packet_loss = true, -- Track packet loss
		track_jitter = true, -- Track connection jitter

		-- Quality thresholds
		good_latency = 100, -- < 100ms is good
		poor_latency = 500, -- > 500ms is poor
		packet_loss_threshold = 0.05, -- 5% packet loss threshold

		-- Adaptive behavior based on quality
		adaptive_behavior = {
			enabled = true,

			-- Poor connection adaptations
			poor_connection = {
				increase_ack_frequency = true,
				reduce_keepalive_interval = true,
				enable_compression = true,
				prioritize_important_stanzas = true,
			},

			-- Good connection optimizations
			good_connection = {
				reduce_ack_frequency = true,
				increase_keepalive_interval = true,
				disable_unnecessary_features = true,
			},
		},
	},
}

-- Offline message handling
-- Integration with stream management
offline_handling = {
	-- Store messages for offline users
	store_offline = true,

	-- Offline storage limits
	max_offline_messages = 1000, -- Maximum offline messages per user
	offline_message_ttl = 86400 * 7, -- 7 days TTL for offline messages

	-- Offline message priorities
	priority_handling = {
		enabled = true,

		-- High priority messages (always store)
		high_priority = {
			"chat", -- Chat messages
			"headline", -- Headlines
		},

		-- Low priority messages (limited storage)
		low_priority = {
			"groupchat", -- Group chat messages
		},

		-- Skip storing these
		skip_storage = {
			-- "presence";          -- Uncomment to skip presence
		},
	},

	-- Integration with Stream Management
	sm_integration = {
		enabled = true,

		-- Deliver offline messages on resumption
		deliver_on_resumption = true,

		-- Mark messages as delivered when acked
		mark_delivered_on_ack = true,

		-- Handle duplicates
		deduplicate_messages = true,
	},
}

-- Stanza routing optimization
-- Optimize stanza delivery for stream management
routing_optimization = {
	-- Stanza prioritization
	prioritization = {
		enabled = true,

		-- Priority levels (1-10, 10 is highest)
		priorities = {
			iq = 8, -- IQ stanzas (high priority)
			message = 6, -- Messages (medium-high priority)
			presence = 4, -- Presence (medium priority)
		},

		-- Special handling
		special_handling = {
			-- Authentication stanzas (highest priority)
			auth_stanzas = 10,

			-- Error stanzas (high priority)
			error_stanzas = 9,

			-- Stream management stanzas (high priority)
			sm_stanzas = 8,
		},
	},

	-- Queue management
	queue_management = {
		enabled = true,

		-- Queue types
		queues = {
			high_priority = {
				max_size = 100,
				timeout = 5, -- 5 second processing timeout
			},
			normal_priority = {
				max_size = 500,
				timeout = 30, -- 30 second processing timeout
			},
			low_priority = {
				max_size = 1000,
				timeout = 60, -- 1 minute processing timeout
			},
		},

		-- Queue overflow handling
		overflow_policy = "drop_oldest", -- drop_oldest, drop_newest, reject
	},
}

-- Mobile client optimizations
-- Specific optimizations for mobile devices
mobile_optimizations = {
	-- Battery life optimizations
	battery_optimization = {
		enabled = true,

		-- Reduce unnecessary traffic
		minimize_presence = true, -- Minimize presence updates
		batch_notifications = true, -- Batch multiple notifications
		compress_stanzas = true, -- Enable compression for mobile

		-- Push notification integration
		push_integration = {
			enabled = true,
			defer_to_push = true, -- Use push instead of maintaining connection
			push_timeout = 300, -- 5 minute push timeout
		},
	},

	-- Network optimization
	network_optimization = {
		enabled = true,

		-- Adaptive timeouts based on network type
		adaptive_timeouts = {
			wifi = {
				keepalive_interval = 120, -- 2 minutes on WiFi
				resumption_timeout = 600, -- 10 minutes on WiFi
			},
			cellular = {
				keepalive_interval = 180, -- 3 minutes on cellular
				resumption_timeout = 900, -- 15 minutes on cellular
			},
		},

		-- Data usage optimization
		data_optimization = {
			compress_presence = true,
			minimize_roster_pushes = true,
			cache_disco_info = true,
		},
	},
}

-- Monitoring and metrics
-- Track stream management performance
sm_monitoring = {
	-- Performance metrics
	metrics = {
		enabled = true,

		-- Track resumption success rate
		track_resumption_rate = true,

		-- Track stanza acknowledgment latency
		track_ack_latency = true,

		-- Track queue sizes
		track_queue_sizes = true,

		-- Track client state changes
		track_csi_changes = true,
	},

	-- Alerting
	alerts = {
		enabled = true,

		-- Alert thresholds
		low_resumption_rate = 0.8, -- Alert if < 80% resumption rate
		high_ack_latency = 1000, -- Alert if ack latency > 1 second
		large_queue_size = 800, -- Alert if queue > 800 stanzas

		-- Alert destinations
		alert_jid = "admin@localhost",
		alert_email = "admin@localhost",
	},

	-- Logging
	logging = {
		log_level = "info",

		-- Events to log
		log_events = {
			stream_resumption = true,
			hibernation = true,
			csi_state_changes = true,
			queue_overflows = true,
			ack_timeouts = true,
		},

		-- Structured logging
		structured_logs = true,
		include_performance_data = true,
	},
}
