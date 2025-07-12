-- ============================================================================
-- BETA ADVANCED XMPP MODULES CONFIGURATION
-- ============================================================================
-- Stability Level: 🟡 Beta (Mostly Stable)
-- Advanced features that are mostly stable but may have edge cases

-- ============================================================================
-- PUSH NOTIFICATIONS - XEP-0357
-- ============================================================================

-- Push notification settings
push_notification_with_body = os.getenv("PROSODY_PUSH_WITH_BODY") == "true"
push_notification_with_sender = os.getenv("PROSODY_PUSH_WITH_SENDER") == "true"
push_max_errors = tonumber(os.getenv("PROSODY_PUSH_MAX_ERRORS")) or 16

-- Cloud notify settings
cloud_notify_priority_threshold = tonumber(os.getenv("PROSODY_CLOUD_NOTIFY_PRIORITY")) or 1

-- ============================================================================
-- MODERN VCARD SUPPORT - XEP-0292
-- ============================================================================

-- Note: vCard4 is now an official module and configured in official/modules.cfg.lua

-- ============================================================================
-- WEB-BASED REGISTRATION - XEP-0401 Extensions
-- ============================================================================

-- Web registration settings
invites_register_web_template = "/etc/prosody/templates/register.html"
invites_register_web_url = os.getenv("PROSODY_REGISTER_WEB_URL") or "https://your-domain.com/register"

-- Password reset functionality
password_reset_url = os.getenv("PROSODY_PASSWORD_RESET_URL") or "https://your-domain.com/reset"
password_reset_token_ttl = tonumber(os.getenv("PROSODY_PASSWORD_RESET_TTL")) or 3600 -- 1 hour

-- ============================================================================
-- ALTERNATIVE CONNECTION METHODS - XEP-0156
-- ============================================================================

-- HTTP connection alternatives
http_altconnect_file = "/etc/prosody/host-meta.json"

-- ============================================================================
-- SERVER INFORMATION PUBLISHING - XEP-0157
-- ============================================================================

-- Publish server information via PubSub
pubsub_serverinfo_node = "urn:xmpp:serverinfo:0"

-- ============================================================================
-- ANTI-MIMICKING (BETA SECURITY)
-- ============================================================================

-- Username similarity detection
mimicking_threshold = tonumber(os.getenv("PROSODY_MIMICKING_THRESHOLD")) or 0.8
mimicking_block_registrations = os.getenv("PROSODY_MIMICKING_BLOCK") == "true" 