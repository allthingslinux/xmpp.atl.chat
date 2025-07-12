-- ===============================================
-- CONFERENCE ROOM CONFIGURATIONS
-- Default room templates and policies
-- ===============================================

-- Room templates for different use cases
room_templates = {
	-- Public discussion room
	public = {
		name = "Public Discussion",
		description = "Open discussion room for all users",
		persistent = true,
		public = true,
		members_only = false,
		moderated = false,
		max_users = 200,
		history_length = 50,
		allow_pm = "participants",
		logging = true,
	},

	-- Private team room
	team = {
		name = "Team Room",
		description = "Private room for team collaboration",
		persistent = true,
		public = false,
		members_only = true,
		moderated = false,
		max_users = 50,
		history_length = 100,
		allow_pm = "participants",
		logging = true,
	},

	-- Moderated announcement room
	announcement = {
		name = "Announcements",
		description = "Moderated room for announcements",
		persistent = true,
		public = true,
		members_only = false,
		moderated = true,
		max_users = 500,
		history_length = 20,
		allow_pm = "moderators",
		logging = true,
	},

	-- Temporary meeting room
	meeting = {
		name = "Meeting Room",
		description = "Temporary room for meetings",
		persistent = false,
		public = false,
		members_only = true,
		moderated = false,
		max_users = 20,
		history_length = 30,
		allow_pm = "participants",
		logging = false,
	},
}

-- Default rooms to create on startup
default_rooms = {
	-- General discussion
	{
		jid = "general@conference." .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
		template = "public",
		subject = "General discussion for all users",
	},

	-- Support room
	{
		jid = "support@conference." .. (os.getenv("PROSODY_DOMAIN") or "localhost"),
		template = "public",
		subject = "Technical support and help",
	},
}

-- Room moderation policies
moderation_policies = {
	-- Spam prevention
	max_messages_per_minute = 10,
	max_message_length = 5000,

	-- Content filtering
	filter_profanity = false,
	filter_spam = true,

	-- Automatic moderation
	auto_kick_flood = true,
	auto_ban_repeat_offenders = true,

	-- Moderator privileges
	moderator_can_kick = true,
	moderator_can_ban = true,
	moderator_can_change_subject = true,
	moderator_can_destroy_room = false,
}

print("Conference room templates and policies loaded")
