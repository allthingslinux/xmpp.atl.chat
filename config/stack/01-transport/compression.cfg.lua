-- Layer 01: Transport - Stream Compression Configuration
-- XMPP stream compression for bandwidth optimization
-- XEP-0138: Stream Compression

-- Stream compression modules
-- Reduces bandwidth usage at the cost of CPU overhead
modules_enabled = {
	"compression", -- XEP-0138: Stream Compression
}

-- Compression configuration
compression = {
	-- Compression levels (1-9, where 9 is maximum compression)
	-- Higher levels use more CPU but achieve better compression
	level = {
		c2s = 6, -- Moderate compression for client connections
		s2s = 4, -- Lower compression for server connections (less CPU impact)
	},

	-- Compression algorithms
	-- zlib is most widely supported, lz4 offers better performance
	algorithms = {
		"zlib", -- Standard compression algorithm (RFC 1950)
		-- "lz4";          -- Fast compression (if available)
	},

	-- Compression thresholds
	-- Only compress stanzas larger than threshold (bytes)
	threshold = {
		c2s = 256, -- Compress client stanzas > 256 bytes
		s2s = 512, -- Compress server stanzas > 512 bytes
	},

	-- Memory limits for compression
	-- Prevent excessive memory usage during compression
	memory_limit = {
		c2s = 1024 * 1024, -- 1MB limit for client compression
		s2s = 2048 * 1024, -- 2MB limit for server compression
	},

	-- Compression window size
	-- Larger windows improve compression but use more memory
	window_size = {
		c2s = 15, -- 32KB window for clients
		s2s = 15, -- 32KB window for servers
	},
}

-- Compression policy
-- When to offer and require compression
compression_policy = {
	-- Offer compression to clients
	c2s_offer = true,

	-- Offer compression to servers
	s2s_offer = true,

	-- Require compression (not recommended - breaks compatibility)
	c2s_require = false,
	s2s_require = false,

	-- Compression preference order
	preference = { "zlib" },
}

-- Performance tuning
-- Balance compression ratio vs CPU usage
compression_performance = {
	-- CPU usage limits
	max_cpu_percent = 25, -- Don't use more than 25% CPU for compression

	-- Adaptive compression
	adaptive = {
		enabled = true, -- Adjust compression based on load
		low_threshold = 10, -- Reduce compression when CPU > 10%
		high_threshold = 20, -- Disable compression when CPU > 20%
	},

	-- Compression statistics
	stats = {
		enabled = true, -- Track compression statistics
		interval = 300, -- Log stats every 5 minutes
	},
}

-- Compression exclusions
-- Don't compress certain types of traffic
compression_exclusions = {
	-- Don't compress already compressed data
	exclude_mime_types = {
		"image/jpeg",
		"image/png",
		"image/gif",
		"audio/mpeg",
		"video/mp4",
		"application/zip",
		"application/gzip",
	},

	-- Don't compress small stanzas (overhead not worth it)
	min_stanza_size = 128, -- Minimum 128 bytes before considering compression

	-- Don't compress certain stanza types
	exclude_stanzas = {
		-- "presence";       -- Uncomment to exclude presence stanzas
		-- "iq";             -- Uncomment to exclude IQ stanzas
	},
}

-- Security considerations
-- Compression can have security implications
compression_security = {
	-- CRIME attack mitigation
	-- Don't compress when TLS compression is enabled
	disable_with_tls_compression = true,

	-- Rate limiting for compression requests
	rate_limit = {
		enabled = true,
		max_requests_per_minute = 60, -- Max 60 compression negotiations per minute
	},

	-- Compression bomb protection
	max_expansion_ratio = 100, -- Don't allow >100x expansion during decompression
}

-- Monitoring and logging
compression_monitoring = {
	-- Log compression events
	log_level = "info",

	-- Track compression metrics
	metrics = {
		enabled = true,
		track_ratio = true, -- Track compression ratios
		track_cpu = true, -- Track CPU usage
		track_memory = true, -- Track memory usage
	},

	-- Alerts for compression issues
	alerts = {
		low_ratio = 0.1, -- Alert if compression ratio < 10%
		high_cpu = 0.8, -- Alert if compression uses > 80% of limit
		high_memory = 0.9, -- Alert if memory usage > 90% of limit
	},
}
