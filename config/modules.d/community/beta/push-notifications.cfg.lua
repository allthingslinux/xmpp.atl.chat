-- ============================================================================
-- PUSH NOTIFICATIONS MODULES
-- ============================================================================
-- Stability Level: 🟡 Beta (Mostly Stable)
-- Push notification and mobile app integration features

-- ============================================================================
-- PUSH NOTIFICATIONS - XEP-0357
-- ============================================================================

-- Push notification settings are configured in core.cfg.lua

-- Cloud notify settings
cloud_notify_priority_threshold = tonumber(os.getenv("PROSODY_CLOUD_NOTIFY_PRIORITY")) or 1

-- ============================================================================
-- ANTI-MIMICKING (BETA SECURITY)
-- ============================================================================

-- Username similarity detection is configured in core.cfg.lua
