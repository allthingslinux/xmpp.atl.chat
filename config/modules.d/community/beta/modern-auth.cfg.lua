-- ============================================================================
-- MODERN AUTHENTICATION MODULES (BETA)
-- ============================================================================
-- Stability Level: 🟡 Beta (Mostly Stable)
-- Next-generation SASL authentication features

-- ============================================================================
-- mod_sasl2 - XEP-0388: Extensible SASL Profile
-- ============================================================================
-- Enable SASL2 for modern authentication flows

sasl2_enable = os.getenv("PROSODY_ENABLE_SASL2") == "true"

-- SASL2 configuration
sasl2_channel_binding = os.getenv("PROSODY_SASL2_CHANNEL_BINDING") ~= "false"
sasl2_tls_unique = os.getenv("PROSODY_SASL2_TLS_UNIQUE") ~= "false"

-- ============================================================================
-- mod_sasl2_bind2 - Bind 2 Integration with SASL2
-- ============================================================================
-- Streamlined connection setup with SASL2

bind2_enable = os.getenv("PROSODY_ENABLE_BIND2") == "true"

-- ============================================================================
-- mod_sasl2_fast - Fast Authentication Streamlining Tokens
-- ============================================================================
-- Fast Authentication Streamlining Tokens for quicker reconnection

sasl2_fast_enable = os.getenv("PROSODY_SASL2_FAST_TOKENS") == "true"
sasl2_fast_token_lifetime = tonumber(os.getenv("PROSODY_FAST_TOKEN_LIFETIME")) or 86400 -- 24 hours

-- ============================================================================
-- mod_auth_ha1 - Authentication Module for 'HA1' Hashed Credentials
-- ============================================================================
-- Authentication module for 'HA1' hashed credentials in a text file, as used by reTurnServer

auth_ha1_file = os.getenv("PROSODY_AUTH_HA1_FILE") or "/etc/prosody/ha1_credentials.txt"

-- ============================================================================
-- mod_auth_internal_yubikey - Two-Factor Authentication Using Yubikeys
-- ============================================================================
-- Two-factor authentication using Yubikeys for enhanced security

yubikey_api_id = os.getenv("PROSODY_YUBIKEY_API_ID")
yubikey_api_key = os.getenv("PROSODY_YUBIKEY_API_KEY")
yubikey_required = os.getenv("PROSODY_YUBIKEY_REQUIRED") == "true"
