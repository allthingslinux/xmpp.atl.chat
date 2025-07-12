-- Layer 06: Storage - Caching Configuration
-- Performance caching, memory optimization, and data acceleration
-- In-memory caching for frequently accessed data and performance optimization

local caching_config = {
	-- Core Caching Modules
	-- Essential caching for performance optimization
	core_caching = {
		-- Note: Most caching in Prosody is built-in and automatic
		-- These are additional caching enhancements
	},

	-- Roster and Presence Caching
	-- Cache contact lists and presence information
	roster_caching = {
		-- Roster caching is built into Prosody core
		-- No additional modules needed for basic roster caching
	},

	-- Service Discovery Caching
	-- Cache service discovery responses for performance
	disco_caching = {
		-- Disco caching is built into the disco module
		-- No additional modules needed
	},

	-- Database Query Caching
	-- Cache database queries for improved performance
	db_caching = {
		-- Database caching depends on storage backend
		-- SQL backends have built-in query caching
	},
}

-- Cache Configuration Settings
-- Configure caching behavior and memory limits
local cache_settings = {
	-- Memory limits for various caches
	max_cache_size = {
		-- Roster cache (number of entries)
		roster = 1000,

		-- Presence cache (number of entries)
		presence = 5000,

		-- Service discovery cache (number of entries)
		disco = 500,

		-- Entity capabilities cache (number of entries)
		caps = 1000,
	},

	-- Cache expiration times (in seconds)
	cache_expiry = {
		-- How long to cache roster entries
		roster = 3600, -- 1 hour

		-- How long to cache presence information
		presence = 300, -- 5 minutes

		-- How long to cache disco responses
		disco = 1800, -- 30 minutes

		-- How long to cache entity capabilities
		caps = 7200, -- 2 hours
	},

	-- Cache cleanup intervals (in seconds)
	cleanup_interval = {
		-- How often to clean up expired cache entries
		general = 300, -- 5 minutes

		-- How often to perform memory cleanup
		memory = 600, -- 10 minutes
	},

	-- Memory usage thresholds
	memory_limits = {
		-- Maximum memory usage for caches (in MB)
		max_cache_memory = 100,

		-- When to start aggressive cleanup (percentage)
		cleanup_threshold = 80,

		-- When to start rejecting new cache entries (percentage)
		rejection_threshold = 95,
	},
}

-- Performance Optimization Settings
-- Additional performance optimizations related to caching
local performance_settings = {
	-- Connection caching
	connection_cache = {
		-- Cache client connections for faster reconnection
		enable_connection_caching = true,
		max_cached_connections = 100,
		connection_cache_timeout = 300, -- 5 minutes
	},

	-- Stream management caching
	stream_management = {
		-- Cache stream management state
		enable_sm_caching = true,
		max_cached_streams = 1000,
		stream_cache_timeout = 1800, -- 30 minutes
	},

	-- Module loading cache
	module_cache = {
		-- Cache loaded modules to speed up reloads
		enable_module_caching = true,
		-- This is handled automatically by Prosody
	},
}

-- Cache Management Functions
-- Utility functions for cache management and monitoring
local cache_management = {
	-- Get cache statistics
	get_cache_stats = function()
		-- This would return cache hit/miss ratios, memory usage, etc.
		-- Implemented via admin interface or monitoring modules
		return {
			hit_ratio = 0.85, -- Example: 85% cache hit ratio
			memory_usage = 45, -- Example: 45MB memory usage
			entries = {
				roster = 750,
				presence = 3200,
				disco = 300,
				caps = 650,
			},
		}
	end,

	-- Clear specific caches
	clear_cache = function(cache_type)
		-- This would clear specific cache types
		-- Implemented via admin commands: prosodyctl shell cache clear <type>
	end,

	-- Optimize cache settings
	optimize_caches = function()
		-- This would analyze usage patterns and optimize cache settings
		-- Manual tuning based on server load and usage patterns
	end,
}

-- Environment-Specific Cache Configuration
-- Different caching strategies for different environments
local function get_environment_cache_config(environment)
	local configs = {
		development = {
			-- Smaller caches for development
			max_cache_size = {
				roster = 100,
				presence = 500,
				disco = 50,
				caps = 100,
			},
			cache_expiry = {
				roster = 300, -- 5 minutes
				presence = 60, -- 1 minute
				disco = 180, -- 3 minutes
				caps = 600, -- 10 minutes
			},
		},

		production = {
			-- Larger caches for production
			max_cache_size = {
				roster = 5000,
				presence = 20000,
				disco = 2000,
				caps = 5000,
			},
			cache_expiry = {
				roster = 7200, -- 2 hours
				presence = 600, -- 10 minutes
				disco = 3600, -- 1 hour
				caps = 14400, -- 4 hours
			},
		},

		testing = {
			-- Minimal caching for testing
			max_cache_size = {
				roster = 50,
				presence = 200,
				disco = 25,
				caps = 50,
			},
			cache_expiry = {
				roster = 60, -- 1 minute
				presence = 30, -- 30 seconds
				disco = 60, -- 1 minute
				caps = 120, -- 2 minutes
			},
		},
	}

	return configs[environment] or configs.production
end

-- Export configuration
return {
	modules = {
		-- Core caching (built into Prosody)
		core = caching_config.core_caching,

		-- Additional caching modules (most are built-in)
		-- roster = caching_config.roster_caching,
		-- disco = caching_config.disco_caching,
		-- db = caching_config.db_caching,
	},

	settings = cache_settings,
	performance = performance_settings,
	management = cache_management,
	get_environment_config = get_environment_cache_config,
}
