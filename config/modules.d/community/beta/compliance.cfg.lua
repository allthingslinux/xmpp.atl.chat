-- ============================================================================
-- COMPLIANCE AND STANDARDS MODULES (BETA)
-- ============================================================================
-- Stability Level: 🟡 Beta (Mostly Stable)
-- XMPP compliance testing and service information

-- ============================================================================
-- mod_compliance_2023 - XMPP Compliance Suites 2023 Self-Test
-- ============================================================================
-- Self-test module for XMPP Compliance Suites 2023

compliance_2023_enable = os.getenv("PROSODY_COMPLIANCE_2023") == "true"

-- Compliance testing configuration
compliance_2023_auto_test = os.getenv("PROSODY_COMPLIANCE_AUTO_TEST") == "true"
compliance_2023_report_file = os.getenv("PROSODY_COMPLIANCE_REPORT") or "/var/log/prosody/compliance.log"

-- ============================================================================
-- mod_compliance_latest - XMPP Compliance Suites Self-Test
-- ============================================================================
-- Self-test module for latest XMPP Compliance Suites

compliance_latest_enable = os.getenv("PROSODY_COMPLIANCE_LATEST") == "true"
compliance_latest_auto_test = os.getenv("PROSODY_COMPLIANCE_LATEST_AUTO_TEST") == "true"
compliance_latest_report_file = os.getenv("PROSODY_COMPLIANCE_LATEST_REPORT")
	or "/var/log/prosody/compliance_latest.log"

-- ============================================================================
-- SERVICE OUTAGE STATUS - XEP-0455
-- ============================================================================
-- Service outage communication (not in official beta list - may be custom)

service_outage_enable = os.getenv("PROSODY_SERVICE_OUTAGE_NOTIFICATIONS") == "true"

-- Outage notification settings
service_outage_contact = os.getenv("PROSODY_OUTAGE_CONTACT") or "admin@localhost"
service_outage_status_url = os.getenv("PROSODY_STATUS_URL") or "https://status.example.com"

-- ============================================================================
-- SERVER INFORMATION - XEP-0128
-- ============================================================================
-- Enhanced service discovery information (not in official beta list - may be custom)

server_info_enable = os.getenv("PROSODY_ENHANCED_SERVER_INFO") == "true"

-- Server information fields
server_info_description = os.getenv("PROSODY_SERVER_DESCRIPTION") or "XMPP Server"
server_info_location = os.getenv("PROSODY_SERVER_LOCATION") or "Unknown"
server_info_admin_contact = os.getenv("PROSODY_ADMIN_CONTACT") or "admin@localhost"

-- ============================================================================
-- EXTERNAL SERVICE DISCOVERY - XEP-0215
-- ============================================================================
-- External service discovery configuration (not in official beta list - may be custom)

extdisco_enable = os.getenv("PROSODY_ENABLE_EXTDISCO") == "true"

-- External services configuration
extdisco_services = {
	{
		type = "stun",
		host = os.getenv("PROSODY_STUN_HOST") or "stun.example.com",
		port = tonumber(os.getenv("PROSODY_STUN_PORT")) or 3478,
	},
	{
		type = "turn",
		host = os.getenv("PROSODY_TURN_HOST") or "turn.example.com",
		port = tonumber(os.getenv("PROSODY_TURN_PORT")) or 3478,
		username = os.getenv("PROSODY_TURN_USERNAME"),
		password = os.getenv("PROSODY_TURN_PASSWORD"),
	},
}
