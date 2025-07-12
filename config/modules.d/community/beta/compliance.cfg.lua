-- ============================================================================
-- COMPLIANCE AND STANDARDS MODULES
-- ============================================================================
-- Stability Level: 🟡 Beta (Mostly Stable)
-- XMPP compliance testing and service information

-- ============================================================================
-- XMPP COMPLIANCE SUITES 2023 - XEP-0479
-- ============================================================================

-- Enable compliance testing
compliance_2023_enable = os.getenv("PROSODY_COMPLIANCE_2023") == "true"

-- Compliance testing configuration
compliance_2023_auto_test = os.getenv("PROSODY_COMPLIANCE_AUTO_TEST") == "true"
compliance_2023_report_file = os.getenv("PROSODY_COMPLIANCE_REPORT") or "/var/log/prosody/compliance.log"

-- ============================================================================
-- SERVICE OUTAGE STATUS - XEP-0455
-- ============================================================================

-- Service outage communication
service_outage_enable = os.getenv("PROSODY_SERVICE_OUTAGE_NOTIFICATIONS") == "true"

-- Outage notification settings
service_outage_contact = os.getenv("PROSODY_OUTAGE_CONTACT") or "admin@localhost"
service_outage_status_url = os.getenv("PROSODY_STATUS_URL") or "https://status.example.com"

-- ============================================================================
-- SERVER INFORMATION - XEP-0128
-- ============================================================================

-- Enhanced service discovery information
server_info_enable = os.getenv("PROSODY_ENHANCED_SERVER_INFO") == "true"

-- Server information fields
server_info_description = os.getenv("PROSODY_SERVER_DESCRIPTION") or "XMPP Server"
server_info_location = os.getenv("PROSODY_SERVER_LOCATION") or "Unknown"
server_info_admin_contact = os.getenv("PROSODY_ADMIN_CONTACT") or "admin@localhost"

-- ============================================================================
-- EXTERNAL SERVICE DISCOVERY - XEP-0215
-- ============================================================================

-- External service discovery configuration
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
