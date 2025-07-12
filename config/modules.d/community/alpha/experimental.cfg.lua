-- ============================================================================
-- ALPHA/EXPERIMENTAL MODULES CONFIGURATION
-- ============================================================================
-- Stability Level: 🟠 Alpha (Experimental)
-- WARNING: These modules are experimental and may have bugs or breaking changes
-- Use only in development/testing environments

-- ============================================================================
-- PERFORMANCE MONITORING (ALPHA)
-- ============================================================================

-- CPU usage monitoring
measure_cpu_interval = tonumber(os.getenv("PROSODY_CPU_MEASURE_INTERVAL")) or 60
measure_cpu_threshold = tonumber(os.getenv("PROSODY_CPU_THRESHOLD")) or 80

-- Memory usage monitoring
measure_memory_interval = tonumber(os.getenv("PROSODY_MEMORY_MEASURE_INTERVAL")) or 60
measure_memory_threshold = tonumber(os.getenv("PROSODY_MEMORY_THRESHOLD")) or 512*1024*1024 -- 512MB

-- End-to-end message metrics (PRIVACY SENSITIVE)
measure_message_e2e_track_presence = os.getenv("PROSODY_E2E_TRACK_PRESENCE") == "true"
measure_message_e2e_track_carbon = os.getenv("PROSODY_E2E_TRACK_CARBON") == "true"

-- ============================================================================
-- ENTERPRISE LOGGING (ALPHA)
-- ============================================================================

-- JSON logging configuration
json_logs_sink = os.getenv("PROSODY_JSON_LOGS_SINK") or "file"
json_logs_file = os.getenv("PROSODY_JSON_LOGS_FILE") or "/var/log/prosody/prosody.json"

-- ============================================================================
-- SECURITY AUDITING (ALPHA)
-- ============================================================================

-- Audit logging configuration
audit_log_file = os.getenv("PROSODY_AUDIT_LOG") or "/var/log/prosody/audit.log"
audit_log_level = os.getenv("PROSODY_AUDIT_LEVEL") or "info"

-- Track sensitive operations
audit_track_logins = os.getenv("PROSODY_AUDIT_LOGINS") == "true"
audit_track_registrations = os.getenv("PROSODY_AUDIT_REGISTRATIONS") == "true"
audit_track_admin_actions = os.getenv("PROSODY_AUDIT_ADMIN") == "true"

-- ============================================================================
-- COMPLIANCE POLICY (ALPHA)
-- ============================================================================

-- Compliance policy configuration
compliance_policy_file = os.getenv("PROSODY_COMPLIANCE_POLICY") or "/etc/prosody/compliance.json"

-- Data retention policies
compliance_retention_messages = os.getenv("PROSODY_COMPLIANCE_MSG_RETENTION") or "2y"
compliance_retention_logs = os.getenv("PROSODY_COMPLIANCE_LOG_RETENTION") or "1y"

-- Privacy controls
compliance_anonymize_logs = os.getenv("PROSODY_COMPLIANCE_ANONYMIZE") == "true"
compliance_gdpr_mode = os.getenv("PROSODY_COMPLIANCE_GDPR") == "true"

-- ============================================================================
-- EXPERIMENTAL FEATURES WARNING
-- ============================================================================

-- Log warning about experimental features
module:log("warn", "Alpha/Experimental modules are enabled. Use with caution in production!")
module:log("warn", "These features may have bugs, performance issues, or breaking changes.")
module:log("info", "Alpha modules: measure_cpu, measure_memory, measure_message_e2e, json_logs, audit, compliance_policy") 