-- ============================================================================
-- REGISTRATION MODULES (STABLE)
-- ============================================================================
-- Stability Level: 🟢 Stable (Production Ready)
-- User registration, management, and support contact features

-- ============================================================================
-- mod_register_json - Token Based JSON Registration & Verification Servlet
-- ============================================================================
-- Provide JSON-based user registration with token verification
-- Enables modern web-based registration workflows with security tokens

register_json_url = os.getenv("PROSODY_REGISTER_JSON_URL") or "/register"
register_json_token_secret = os.getenv("PROSODY_REGISTER_JSON_SECRET") -- Required
register_json_token_lifetime = tonumber(os.getenv("PROSODY_REGISTER_JSON_TTL")) or 3600 -- 1 hour

-- Registration validation
register_json_email_required = os.getenv("PROSODY_REGISTER_JSON_EMAIL") ~= "false"
register_json_captcha_required = os.getenv("PROSODY_REGISTER_JSON_CAPTCHA") == "true"

-- ============================================================================
-- mod_register_redirect - XEP-077 IBR Registration Redirect
-- ============================================================================
-- Redirect In-Band Registration (IBR) requests to external registration page
-- XEP-077: https://xmpp.org/extensions/xep-0077.html

register_redirect_url = os.getenv("PROSODY_REGISTER_REDIRECT_URL") or "https://example.com/register"
register_redirect_text = os.getenv("PROSODY_REGISTER_REDIRECT_TEXT") or "Please register at our website"

-- ============================================================================
-- mod_support_contact - Add a Support Contact to New Registrations
-- ============================================================================
-- Automatically add a support contact to new user rosters
-- Provides immediate access to help and improves user onboarding

support_contact_nick = os.getenv("PROSODY_SUPPORT_CONTACT_NICK") or "Support"
support_contact_jid = os.getenv("PROSODY_SUPPORT_CONTACT_JID") or "support@localhost"
support_contact_message = os.getenv("PROSODY_SUPPORT_CONTACT_MSG") or "Welcome! Contact us if you need help."

-- Auto-add support contact to roster
support_contact_auto_add = os.getenv("PROSODY_SUPPORT_CONTACT_AUTO_ADD") ~= "false"
