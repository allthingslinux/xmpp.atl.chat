-- ============================================================================
-- PUSH NOTIFICATIONS MODULES
-- ============================================================================
-- Stability Level: 🟡 Beta (Mostly Stable)
-- Push notification and mobile app integration features

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
-- ANTI-MIMICKING (BETA SECURITY)
-- ============================================================================

-- Username similarity detection
mimicking_threshold = tonumber(os.getenv("PROSODY_MIMICKING_THRESHOLD")) or 0.8
mimicking_block_registrations = os.getenv("PROSODY_MIMICKING_BLOCK") == "true" 