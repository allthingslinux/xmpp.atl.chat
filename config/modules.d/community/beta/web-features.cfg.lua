-- ============================================================================
-- WEB FEATURES AND HTTP MODULES
-- ============================================================================
-- Stability Level: 🟡 Beta (Mostly Stable)
-- Web-based registration, HTTP features, and server information publishing

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
