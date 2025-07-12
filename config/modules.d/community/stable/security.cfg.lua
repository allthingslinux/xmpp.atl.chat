-- ============================================================================
-- SECURITY MODULES (STABLE)
-- ============================================================================
-- Stability Level: 🟢 Stable (Production Ready)
-- Security, authentication, and access control modules

-- ============================================================================
-- mod_auth_sql - SQL Database Authentication Module
-- ============================================================================
-- Authenticate users against SQL databases (MySQL, PostgreSQL, SQLite)
-- Useful for integrating with existing user databases

auth_sql_driver = os.getenv("PROSODY_AUTH_SQL_DRIVER") or "MySQL"
auth_sql_database = os.getenv("PROSODY_AUTH_SQL_DATABASE") or "prosody"
auth_sql_host = os.getenv("PROSODY_AUTH_SQL_HOST") or "localhost"
auth_sql_port = tonumber(os.getenv("PROSODY_AUTH_SQL_PORT")) or 3306
auth_sql_username = os.getenv("PROSODY_AUTH_SQL_USERNAME") or "prosody"
auth_sql_password = os.getenv("PROSODY_AUTH_SQL_PASSWORD") or ""

-- ============================================================================
-- mod_host_guard - Granular Remote Host Blacklisting Plugin
-- ============================================================================
-- Block communication from specific remote hosts/domains
-- Helps prevent spam and abuse from known bad actors

host_guard_blacklist = "/etc/prosody/host_blacklist.txt"
host_guard_whitelist = "/etc/prosody/host_whitelist.txt"
host_guard_block_communication = os.getenv("PROSODY_HOST_GUARD_BLOCK_COMM") ~= "false"

-- ============================================================================
-- mod_log_auth - Log Failed Authentication Attempts with IP Address
-- ============================================================================
-- Security logging for failed login attempts, useful for intrusion detection
-- Logs IP addresses of failed authentication attempts

log_auth_file = os.getenv("PROSODY_AUTH_LOG_FILE") or "/var/log/prosody/auth.log"
log_auth_include_successful = os.getenv("PROSODY_LOG_AUTH_SUCCESS") == "true"

-- ============================================================================
-- mod_require_otr - Enforce a Policy for OTR-Encrypted Messages
-- ============================================================================
-- Enforce Off-the-Record (OTR) encryption policy for messages
-- Can require, prefer, or make OTR optional

require_otr_policy = os.getenv("PROSODY_OTR_POLICY") or "optional" -- optional, preferred, required
require_otr_whitelist = "/etc/prosody/otr_whitelist.txt"

-- ============================================================================
-- mod_saslname - XEP-0233: XMPP Server Registration for use with Kerberos V5
-- ============================================================================
-- Kerberos V5 integration for enterprise authentication
-- XEP-0233: https://xmpp.org/extensions/xep-0233.html

saslname_realm = os.getenv("PROSODY_KERBEROS_REALM") or "EXAMPLE.COM"
saslname_service = os.getenv("PROSODY_KERBEROS_SERVICE") or "xmpp"
