-- ===============================================
-- CONFERENCE DOMAIN CONFIGURATION
-- Multi-User Chat (MUC) domain setup
-- XEP-0045: Multi-User Chat
-- ===============================================

local domain = os.getenv("PROSODY_DOMAIN") or "localhost"
local conference_domain = "conference." .. domain

-- Configure MUC component
Component(conference_domain)("muc")

-- MUC-specific modules
modules_enabled = {
	"muc_mam", -- XEP-0313: Message Archive Management for MUC
	"muc_limits", -- Room size and rate limits
	"muc_log", -- Room logging
	"muc_room_metadata", -- Room metadata support
	"muc_moderation", -- Message moderation
	"muc_slow_mode", -- Slow mode for rooms
	"muc_mention_notifications", -- Mention notifications
}

-- MUC configuration
muc_room_locking = true
muc_room_lock_timeout = 300
muc_tombstones = true
muc_tombstone_expiry = 31 * 24 * 60 * 60 -- 31 days

-- Default room configuration
muc_room_default_config = {
	name = "",
	description = "",
	language = "en",
	persistent = false,
	public = true,
	members_only = false,
	moderated = false,
	password = "",
	whois = "moderators", -- or "anyone"
	max_users = 100,
	history_length = 20,
	allow_member_invites = true,
	allow_pm = "participants", -- "moderators", "participants", "none"
	logging = true,
}

-- Archive settings for MUC
muc_log_expires_after = "1y"
max_archive_query_results = 500

-- Rate limiting for MUC
muc_max_nick_length = 50
muc_max_subject_length = 500

print("Conference domain configured: " .. conference_domain)
