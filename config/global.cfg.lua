-- ============================================================================
-- GLOBAL PROSODY CONFIGURATION
-- ============================================================================
-- Basic server settings, administrators, and global options

-- ============================================================================
-- ADMINISTRATOR ACCOUNTS
-- ============================================================================

-- Administrator accounts
admins = {}
local admin_list = os.getenv("PROSODY_ADMINS") or "admin@localhost"
for admin in admin_list:gmatch("([^,]+)") do
	table.insert(admins, admin:match("^%s*(.-)%s*$"))
end

-- ============================================================================
-- PERFORMANCE AND RESOURCE MANAGEMENT
-- ============================================================================

-- Memory management
gc_settings = {
	mode = os.getenv("PROSODY_GC_MODE") or "incremental",
	threshold = tonumber(os.getenv("PROSODY_GC_THRESHOLD")) or 150,
	speed = tonumber(os.getenv("PROSODY_GC_SPEED")) or 500,
}

-- Connection limits and rate limiting
limits = {
	c2s = {
		rate = os.getenv("PROSODY_C2S_RATE") or "1mb/s",
		burst = os.getenv("PROSODY_C2S_BURST") or "2mb",
		-- Stanza size limits (XMPP Safeguarding Manifesto recommendation)
		stanza_size = tonumber(os.getenv("PROSODY_C2S_STANZA_LIMIT")) or 262144, -- 256KB
	},
	s2sin = {
		rate = os.getenv("PROSODY_S2S_RATE") or "500kb/s",
		burst = os.getenv("PROSODY_S2S_BURST") or "1mb",
		-- Stanza size limits (XMPP Safeguarding Manifesto recommendation)
		stanza_size = tonumber(os.getenv("PROSODY_S2S_STANZA_LIMIT")) or 524288, -- 512KB
	},
}

-- Stream management hibernation time (24 hours for mobile devices)
smacks_hibernation_time = tonumber(os.getenv("PROSODY_SMACKS_HIBERNATION")) or 86400

-- PEP (Personal Eventing Protocol) settings
pep_max_items = tonumber(os.getenv("PROSODY_PEP_MAX_ITEMS")) or 10000

-- ============================================================================
-- CONTACT INFORMATION AND COMPLIANCE
-- ============================================================================

-- Server contact information (required for compliance)
contact_info = {
	admin = {
		"xmpp:admin@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
		"mailto:admin@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
	},
	support = {
		"xmpp:admin@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
		"mailto:support@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
	},
	abuse = {
		"xmpp:admin@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
		"mailto:abuse@" .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
	},
}

-- Blocked usernames for registration
block_registrations_users = {
	"admin",
	"administrator",
	"root",
	"xmpp",
	"postmaster",
	"webmaster",
	"hostmaster",
	"abuse",
	"support",
	"help",
	"info",
	"noreply",
	"no-reply",
	"system",
	"daemon",
	"service",
	"test",
	"guest",
	"anonymous",
}

-- Tombstone configuration
user_tombstone_expire = 60 * 86400 -- 2 months

-- ============================================================================
-- LOGGING CONFIGURATION
-- ============================================================================

-- Log levels based on environment
local log_level = os.getenv("PROSODY_LOG_LEVEL") or "info"
local log_format = os.getenv("PROSODY_LOG_FORMAT") or "default"

if log_format == "json" then
	-- JSON logging for enterprise deployments
	log = {
		{ levels = { "error" }, to = "file", filename = "/var/log/prosody/error.log", format = "json" },
		{ levels = { "warn", "info" }, to = "file", filename = "/var/log/prosody/prosody.log", format = "json" },
	}
else
	-- Standard logging
	log = {
		{ levels = { "error" }, to = "file", filename = "/var/log/prosody/error.log" },
		{ levels = { "warn", "info" }, to = "file", filename = "/var/log/prosody/prosody.log" },
	}
end

-- Debug logging if enabled
if log_level == "debug" then
	table.insert(log, { levels = { "debug" }, to = "file", filename = "/var/log/prosody/debug.log" })
end
