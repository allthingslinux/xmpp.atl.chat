-- ============================================================================
-- USER EXPERIENCE MODULES
-- ============================================================================
-- Stability Level: 🟢 Stable (Production Ready)
-- Modules focused on improving user experience and avatar management

-- ============================================================================
-- AVATAR SYNCHRONIZATION - XEP-0084/0153
-- ============================================================================

-- Sync avatars between vCard and PEP
pep_vcard_avatar_sync = os.getenv("PROSODY_AVATAR_SYNC") ~= "false"

-- ============================================================================
-- CHAT STATE FILTERING - XEP-0085
-- ============================================================================

-- Filter chat states for inactive sessions to reduce bandwidth
filter_chatstates_inactive_timeout = tonumber(os.getenv("PROSODY_CHATSTATE_TIMEOUT")) or 300 -- 5 minutes

-- ============================================================================
-- MESSAGE PROCESSING HINTS - XEP-0334
-- ============================================================================

-- Respect message processing hints (no-store, no-copy, etc.)
offline_hints_respect_no_store = os.getenv("PROSODY_RESPECT_NO_STORE") ~= "false"
offline_hints_respect_no_copy = os.getenv("PROSODY_RESPECT_NO_COPY") ~= "false"

-- ============================================================================
-- PROFILE MANAGEMENT - XEP-0054/0292
-- ============================================================================

-- Enhanced vCard with vCard4 support and PEP integration
profile_vcard4_support = os.getenv("PROSODY_VCARD4_SUPPORT") ~= "false"
profile_pep_integration = os.getenv("PROSODY_PROFILE_PEP") ~= "false"
