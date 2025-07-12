-- ============================================================================
-- MODERN AUTHENTICATION MODULES
-- ============================================================================
-- Stability Level: 🟡 Beta (Mostly Stable)
-- Next-generation authentication and security features

-- ============================================================================
-- SASL2 - XEP-0388: Extensible SASL Profile
-- ============================================================================

-- Enable SASL2 for modern authentication
sasl2_enable = os.getenv("PROSODY_ENABLE_SASL2") == "true"

-- SASL2 configuration
sasl2_channel_binding = os.getenv("PROSODY_SASL2_CHANNEL_BINDING") ~= "false"
sasl2_tls_unique = os.getenv("PROSODY_SASL2_TLS_UNIQUE") ~= "false"

-- ============================================================================
-- BIND2 - XEP-0386: Bind 2
-- ============================================================================

-- Streamlined connection setup
bind2_enable = os.getenv("PROSODY_ENABLE_BIND2") == "true"

-- ============================================================================
-- FAST AUTHENTICATION - XEP-0484
-- ============================================================================

-- Fast Authentication Streamlining Tokens
sasl2_fast_enable = os.getenv("PROSODY_SASL2_FAST_TOKENS") == "true"
sasl2_fast_token_lifetime = tonumber(os.getenv("PROSODY_FAST_TOKEN_LIFETIME")) or 86400 -- 24 hours

-- ============================================================================
-- SASL SCRAM DOWNGRADE PROTECTION - XEP-0474
-- ============================================================================

-- Prevent SASL downgrade attacks
sasl_ssdp_enable = os.getenv("PROSODY_SASL_SSDP") ~= "false"
sasl_ssdp_strict_mode = os.getenv("PROSODY_SASL_SSDP_STRICT") == "true"

-- ============================================================================
-- INSTANT STREAM RESUMPTION - XEP-0397
-- ============================================================================

-- Instant stream resumption for faster reconnection
isr_enable = os.getenv("PROSODY_ENABLE_ISR") == "true"
isr_token_lifetime = tonumber(os.getenv("PROSODY_ISR_TOKEN_LIFETIME")) or 3600 -- 1 hour
