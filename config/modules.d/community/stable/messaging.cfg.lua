-- ============================================================================
-- MESSAGING MODULES (STABLE)
-- ============================================================================
-- Stability Level: 🟢 Stable (Production Ready)
-- Enhanced messaging, broadcasting, and communication features

-- ============================================================================
-- mod_broadcast - Broadcast a Message to Online Users
-- ============================================================================
-- Send broadcast messages to all online users or specific groups
-- Useful for server announcements and maintenance notifications

broadcast_to_online_only = os.getenv("PROSODY_BROADCAST_ONLINE_ONLY") ~= "false"
broadcast_admin_only = os.getenv("PROSODY_BROADCAST_ADMIN_ONLY") ~= "false"

-- ============================================================================
-- mod_pastebin - Redirect Long Messages to Built-in Pastebin
-- ============================================================================
-- Automatically redirect long messages to a built-in pastebin service
-- Reduces message clutter and improves readability in group chats

pastebin_threshold = tonumber(os.getenv("PROSODY_PASTEBIN_THRESHOLD")) or 500 -- characters
pastebin_line_threshold = tonumber(os.getenv("PROSODY_PASTEBIN_LINE_THRESHOLD")) or 4 -- lines
pastebin_expire_after = tonumber(os.getenv("PROSODY_PASTEBIN_EXPIRE")) or 2592000 -- 30 days
pastebin_trigger = os.getenv("PROSODY_PASTEBIN_TRIGGER") or "!paste"

-- ============================================================================
-- mod_vcard_muc - Support for MUC vCards and Avatars
-- ============================================================================
-- Add vCard and avatar support to Multi-User Chat (MUC) rooms
-- Allows rooms to have descriptions, avatars, and other metadata

vcard_muc_enable_avatars = os.getenv("PROSODY_MUC_AVATARS") ~= "false"
vcard_muc_max_avatar_size = tonumber(os.getenv("PROSODY_MUC_AVATAR_MAX_SIZE")) or 32768 -- 32KB

-- ============================================================================
-- mod_webpresence - Display Your Online Status in Web Pages
-- ============================================================================
-- Provide web-accessible presence information for embedding in websites
-- Allows users to show their XMPP status on external web pages

webpresence_url_template = os.getenv("PROSODY_WEBPRESENCE_URL") or "https://example.com/presence/{jid}"
webpresence_default_message = os.getenv("PROSODY_WEBPRESENCE_DEFAULT") or "Offline"
