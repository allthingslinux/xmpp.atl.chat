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
-- mod_mam - Message Archive Management (XEP-0313)
-- ============================================================================
-- Message archiving for compliance and history synchronization

-- Archive policy: always, never, roster
default_archive_policy = os.getenv("PROSODY_ARCHIVE_POLICY") or "roster"

-- Archive expiration
archive_expires_after = os.getenv("PROSODY_ARCHIVE_EXPIRE") or "1y"

-- Maximum results per archive query
max_archive_query_results = tonumber(os.getenv("PROSODY_ARCHIVE_MAX_RESULTS")) or 50

-- ============================================================================
-- mod_smacks - Stream Management (XEP-0198)
-- ============================================================================
-- Provides reliability and session resumption for mobile and unreliable connections

-- Stream management hibernation time is configured in global.cfg.lua

-- Maximum unacked stanzas
smacks_max_unacked_stanzas = tonumber(os.getenv("PROSODY_SMACKS_MAX_UNACKED")) or 256

-- ============================================================================
-- mod_csi / mod_csi_simple - Client State Indication (XEP-0352)
-- ============================================================================
-- Allows clients to report their active/inactive state for mobile optimizations

-- CSI queue size for inactive clients
csi_queue_size = tonumber(os.getenv("PROSODY_CSI_QUEUE_SIZE")) or 256

-- ============================================================================
-- mod_pep - Personal Eventing Protocol (XEP-0163)
-- ============================================================================
-- Lets users broadcast various information to interested contacts

-- PEP maximum items per node is configured in global.cfg.lua

-- ============================================================================
-- mod_bookmarks - Bookmark Synchronization (XEP-0048/0402)
-- ============================================================================
-- Converts between old and new ways to store chat room bookmarks

-- Bookmark storage method: private, pep, or both
bookmark_storage = os.getenv("PROSODY_BOOKMARK_STORAGE") or "pep"

-- ============================================================================
-- mod_cloud_notify - Cloud Push Notifications (XEP-0357)
-- ============================================================================
-- Cloud push notifications for mobile devices

-- Push notification settings
push_notification_with_body = os.getenv("PROSODY_PUSH_WITH_BODY") == "true"
push_notification_with_sender = os.getenv("PROSODY_PUSH_WITH_SENDER") == "true"
push_max_errors = tonumber(os.getenv("PROSODY_PUSH_MAX_ERRORS")) or 16

-- ============================================================================
-- mod_invites / mod_invites_adhoc / mod_invites_register - Invitation System (XEP-0401)
-- ============================================================================
-- Invite creation and management for user onboarding

-- Invitation expiry time (7 days)
invite_expiry = tonumber(os.getenv("PROSODY_INVITE_EXPIRY")) or 604800

-- Allow invitations from all users or just admins
invites_from_all_users = os.getenv("PROSODY_INVITES_FROM_ALL") == "true"

-- ============================================================================
-- mod_bosh - BOSH Support (XEP-0124/0206)
-- ============================================================================
-- BOSH (XMPP over HTTP) support for web clients

-- BOSH configuration
bosh_max_inactivity = tonumber(os.getenv("PROSODY_BOSH_MAX_INACTIVITY")) or 60
bosh_max_polling = tonumber(os.getenv("PROSODY_BOSH_MAX_POLLING")) or 5
bosh_max_requests = tonumber(os.getenv("PROSODY_BOSH_MAX_REQUESTS")) or 2

-- ============================================================================
-- mod_websocket - WebSocket Support (RFC 7395)
-- ============================================================================
-- Supports XMPP connections over WebSockets for modern web applications

-- WebSocket configuration
websocket_frame_buffer_limit = tonumber(os.getenv("PROSODY_WS_FRAME_BUFFER")) or 65536
websocket_frame_fragment_limit = tonumber(os.getenv("PROSODY_WS_FRAGMENT_LIMIT")) or 8

-- ============================================================================
-- mod_http_file_share - HTTP File Share (XEP-0363)
-- ============================================================================
-- Let users share files via HTTP upload
-- Configuration is handled in components.cfg.lua

-- ============================================================================
-- mod_turn_external - External TURN Services (XEP-0215)
-- ============================================================================
-- Provides TURN credentials for Audio/Video calls

-- TURN server configuration for A/V calls
turn_external_host = os.getenv("PROSODY_TURN_HOST")
turn_external_port = tonumber(os.getenv("PROSODY_TURN_PORT")) or 3478
turn_external_username = os.getenv("PROSODY_TURN_USERNAME")
turn_external_password = os.getenv("PROSODY_TURN_PASSWORD")

-- ============================================================================
-- mod_lastactivity - Last Activity (XEP-0012)
-- ============================================================================
-- Support querying for user idle times

-- Track last activity for users
lastactivity_track_presence = true

-- ============================================================================
-- mod_offline - Offline Message Storage (XEP-0160)
-- ============================================================================
-- Offline message storage and delayed delivery support

-- Offline message storage limit
offline_message_limit = tonumber(os.getenv("PROSODY_OFFLINE_MESSAGE_LIMIT")) or 100

-- ============================================================================
-- mod_vcard / mod_vcard4 / mod_vcard_legacy - vCard Support (XEP-0054/0292/0398)
-- ============================================================================
-- User profile and avatar management across different vCard formats

-- vCard4 compatibility (XEP-0292)
vcard4_compatibility = true -- Enable vCard-temp compatibility

-- vCard legacy compatibility (XEP-0054)
vcard_compatibility = true

-- ============================================================================
-- mod_register_ibr / mod_register_limits - Registration Management (XEP-0077)
-- ============================================================================
-- In-band registration and account management

-- Registration limits
registration_throttle_max = tonumber(os.getenv("PROSODY_REGISTRATION_MAX")) or 3
registration_throttle_period = tonumber(os.getenv("PROSODY_REGISTRATION_PERIOD")) or 3600

-- ============================================================================
-- mod_motd - Message of the Day
-- ============================================================================
-- Send a MOTD to users on login

-- Message of the day
motd_text = os.getenv("PROSODY_MOTD") or "Welcome to our XMPP server!"

-- ============================================================================
-- mod_welcome - Welcome Message
-- ============================================================================
-- Sends a welcome message to new users

-- Welcome message for new users
welcome_message = os.getenv("PROSODY_WELCOME_MESSAGE") or "Welcome! Please read our terms of service."

-- ============================================================================
-- mod_mimicking - Username Spoofing Prevention (UTS #39)
-- ============================================================================
-- Prevents username spoofing using Unicode confusables

-- Username mimicking protection threshold
mimicking_threshold = tonumber(os.getenv("PROSODY_MIMICKING_THRESHOLD")) or 0.8
mimicking_block_registrations = os.getenv("PROSODY_MIMICKING_BLOCK") == "true"

-- ============================================================================
-- mod_http_openmetrics - OpenMetrics Export
-- ============================================================================
-- Expose statistics in OpenMetrics format for Prometheus monitoring

-- OpenMetrics (Prometheus) configuration
openmetrics_allow_cidr = os.getenv("PROSODY_METRICS_ALLOW_CIDR") or "127.0.0.1/8"
openmetrics_allow_ips = { "127.0.0.1", "::1" }

-- ============================================================================
-- mod_statistics - Statistics Collection
-- ============================================================================
-- Collects and provides server statistics

-- Statistics collection
statistics_interval = tonumber(os.getenv("PROSODY_STATS_INTERVAL")) or 60

-- ============================================================================
-- mod_muc / mod_muc_mam / mod_muc_unique - Multi-User Chat (XEP-0045)
-- ============================================================================
-- Multi-User Chat support with message archiving and unique room names
-- Configuration is handled in components.cfg.lua

-- ============================================================================
-- mod_server_contact_info - Server Contact Information (XEP-0157)
-- ============================================================================
-- Lets you advertise contact addresses for server administration
-- Configuration is handled in global.cfg.lua
