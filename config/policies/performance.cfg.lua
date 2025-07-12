-- ===============================================
-- PERFORMANCE POLICY CONFIGURATION
-- Performance tuning based on deployment size
-- ===============================================

-- Performance tier from environment variable
local performance_tier = os.getenv("PROSODY_PERFORMANCE_TIER") or "medium"

-- Performance settings based on tier
if performance_tier == "small" then
	-- Small deployment (<100 users)
	limits = limits or {}
	limits.c2s = { rate = "1kb/s", burst = "2s" }
	limits.s2s = { rate = "5kb/s", burst = "2s" }

	-- Conservative memory settings
	gc = { speed = 100 }
elseif performance_tier == "medium" then
	-- Medium deployment (100-1000 users)
	limits = limits or {}
	limits.c2s = { rate = "5kb/s", burst = "5s" }
	limits.s2s = { rate = "20kb/s", burst = "5s" }

	-- Balanced memory settings
	gc = { speed = 200 }
elseif performance_tier == "large" then
	-- Large deployment (>1000 users)
	limits = limits or {}
	limits.c2s = { rate = "10kb/s", burst = "10s" }
	limits.s2s = { rate = "50kb/s", burst = "10s" }

	-- Aggressive memory settings
	gc = { speed = 500 }

	-- Enable performance modules
	modules_enabled = modules_enabled or {}
	table.insert(modules_enabled, "statistics")
	table.insert(modules_enabled, "measure_memory")
end

print("Performance policy loaded: " .. performance_tier)
