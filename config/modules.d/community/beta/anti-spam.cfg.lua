-- ============================================================================
-- ANTI-SPAM MODULES (BETA)
-- ============================================================================
-- Stability Level: 🟡 Beta (Mostly Stable)
-- Spam reporting and monitoring features

-- ============================================================================
-- mod_spam_reporting - XEP-0377: Spam Reporting
-- ============================================================================
-- Allow users to report spam messages to server administrators
-- XEP-0377: https://xmpp.org/extensions/xep-0377.html

spam_reporting_threshold = tonumber(os.getenv("PROSODY_SPAM_THRESHOLD")) or 3
spam_reporting_notification = os.getenv("PROSODY_SPAM_NOTIFICATION") or "admin@localhost"

-- ============================================================================
-- mod_watch_spam_reports - Notify Admins About Spam Reports
-- ============================================================================
-- Notify admins about incoming XEP-0377 spam reports
-- Provides real-time alerts for spam detection

watch_spam_reports_notify_jid = os.getenv("PROSODY_SPAM_WATCH_JID") or "admin@localhost"
watch_spam_reports_auto_action = os.getenv("PROSODY_SPAM_AUTO_ACTION") or "none" -- none, warn, block

-- ============================================================================
-- mod_admin_blocklist - Block S2S Connections Based on Admin Blocklist
-- ============================================================================
-- Block s2s connections based on admin-maintained blocklist
-- More advanced than basic DNS blocklists

admin_blocklist_file = os.getenv("PROSODY_ADMIN_BLOCKLIST") or "/etc/prosody/admin_blocklist.txt"
admin_blocklist_auto_update = os.getenv("PROSODY_ADMIN_BLOCKLIST_AUTO_UPDATE") == "true"
