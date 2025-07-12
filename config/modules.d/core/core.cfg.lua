-- ============================================================================
-- CORE PROSODY MODULES CONFIGURATION
-- ============================================================================
-- Status: ✅ Core (Shipped with Prosody)
-- Stability: 🟢 Stable (Production Ready)
-- Risk: Low - Officially maintained and tested
-- 
-- This file contains configuration for all modules shipped with Prosody,
-- including required, autoloaded, and distributed modules.

-- ============================================================================
-- MESSAGE ARCHIVE MANAGEMENT (MAM) - XEP-0313
-- ============================================================================

-- Archive policy: always, never, roster
default_archive_policy = os.getenv("PROSODY_ARCHIVE_POLICY") or "roster"

-- Archive expiration
archive_expires_after = os.getenv("PROSODY_ARCHIVE_EXPIRE") or "1y"

-- Maximum results per archive query
max_archive_query_results = tonumber(os.getenv("PROSODY_ARCHIVE_MAX_RESULTS")) or 50

-- ============================================================================
-- STREAM MANAGEMENT (SMACKS) - XEP-0198
-- ============================================================================

-- Stream management hibernation time is configured in global.cfg.lua

-- Maximum unacked stanzas
smacks_max_unacked_stanzas = tonumber(os.getenv("PROSODY_SMACKS_MAX_UNACKED")) or 256

-- ============================================================================
-- CLIENT STATE INDICATION (CSI) - XEP-0352
-- ============================================================================

-- CSI queue size for inactive clients
csi_queue_size = tonumber(os.getenv("PROSODY_CSI_QUEUE_SIZE")) or 256

-- ============================================================================
-- PERSONAL EVENTING PROTOCOL (PEP) - XEP-0163
-- ============================================================================

-- PEP maximum items per node is configured in global.cfg.lua

-- ============================================================================
-- BOOKMARKS SYNCHRONIZATION - XEP-0048/0402
-- ============================================================================

-- Bookmark storage method: private, pep, or both
bookmark_storage = os.getenv("PROSODY_BOOKMARK_STORAGE") or "pep"

-- ============================================================================
-- CLOUD PUSH NOTIFICATIONS - XEP-0357
-- ============================================================================

-- Push notification settings
push_notification_with_body = os.getenv("PROSODY_PUSH_WITH_BODY") == "true"
push_notification_with_sender = os.getenv("PROSODY_PUSH_WITH_SENDER") == "true"
push_max_errors = tonumber(os.getenv("PROSODY_PUSH_MAX_ERRORS")) or 16

-- ============================================================================
-- INVITATION SYSTEM - XEP-0401
-- ============================================================================

-- Invitation expiry time (7 days)
invite_expiry = tonumber(os.getenv("PROSODY_INVITE_EXPIRY")) or 604800

-- Allow invitations from all users or just admins
invites_from_all_users = os.getenv("PROSODY_INVITES_FROM_ALL") == "true"

-- ============================================================================
-- HTTP SERVICES CONFIGURATION
-- ============================================================================

-- BOSH configuration (XEP-0124/0206)
bosh_max_inactivity = tonumber(os.getenv("PROSODY_BOSH_MAX_INACTIVITY")) or 60
bosh_max_polling = tonumber(os.getenv("PROSODY_BOSH_MAX_POLLING")) or 5
bosh_max_requests = tonumber(os.getenv("PROSODY_BOSH_MAX_REQUESTS")) or 2

-- WebSocket configuration (RFC 7395)
websocket_frame_buffer_limit = tonumber(os.getenv("PROSODY_WS_FRAME_BUFFER")) or 65536
websocket_frame_fragment_limit = tonumber(os.getenv("PROSODY_WS_FRAGMENT_LIMIT")) or 8

-- HTTP File Share configuration (XEP-0447) is handled in components.cfg.lua

-- ============================================================================
-- MULTI-USER CHAT (MUC) - XEP-0045
-- ============================================================================

-- MUC settings are configured in components.cfg.lua

-- ============================================================================
-- TURN EXTERNAL SERVICES - XEP-0215
-- ============================================================================

-- TURN server configuration for A/V calls
turn_external_host = os.getenv("PROSODY_TURN_HOST")
turn_external_port = tonumber(os.getenv("PROSODY_TURN_PORT")) or 3478
turn_external_username = os.getenv("PROSODY_TURN_USERNAME")
turn_external_password = os.getenv("PROSODY_TURN_PASSWORD")

-- ============================================================================
-- LAST ACTIVITY - XEP-0012
-- ============================================================================

-- Track last activity for users
lastactivity_track_presence = true

-- ============================================================================
-- SERVER CONTACT INFORMATION - XEP-0157
-- ============================================================================

-- Contact information is configured in global.cfg.lua

-- ============================================================================
-- REGISTRATION MANAGEMENT
-- ============================================================================

-- Registration limits
registration_throttle_max = tonumber(os.getenv("PROSODY_REGISTRATION_MAX")) or 3
registration_throttle_period = tonumber(os.getenv("PROSODY_REGISTRATION_PERIOD")) or 3600

-- ============================================================================
-- MISCELLANEOUS OFFICIAL MODULES
-- ============================================================================

-- Message of the day
motd_text = os.getenv("PROSODY_MOTD") or "Welcome to our XMPP server!"

-- Welcome message for new users
welcome_message = os.getenv("PROSODY_WELCOME_MESSAGE") or "Welcome! Please read our terms of service."

-- Tombstone expiry is configured in global.cfg.lua

-- Username mimicking protection threshold
mimicking_threshold = tonumber(os.getenv("PROSODY_MIMICKING_THRESHOLD")) or 0.8
mimicking_block_registrations = os.getenv("PROSODY_MIMICKING_BLOCK") == "true"

-- vCard legacy compatibility
vcard_compatibility = true

-- ============================================================================
-- MODERN VCARD SUPPORT - XEP-0292
-- ============================================================================

-- vCard4 configuration (official module)
vcard4_compatibility = true -- Enable vCard-temp compatibility

-- Offline message storage
offline_message_limit = tonumber(os.getenv("PROSODY_OFFLINE_MESSAGE_LIMIT")) or 100

-- ============================================================================
-- METRICS AND MONITORING
-- ============================================================================

-- OpenMetrics (Prometheus) configuration
openmetrics_allow_cidr = os.getenv("PROSODY_METRICS_ALLOW_CIDR") or "127.0.0.1/8"
openmetrics_allow_ips = { "127.0.0.1", "::1" }

-- Statistics collection
statistics_interval = tonumber(os.getenv("PROSODY_STATS_INTERVAL")) or 60 