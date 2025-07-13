-- ===============================================
-- CREDENTIAL MANAGEMENT CONFIGURATION
-- ===============================================
-- Prosody 13.0+ Credential and File Management Features
-- Secure handling of sensitive configuration data
-- RFC 7468: Textual Encodings of PKIX, PKCS, and CMS Structures

-- ===============================================
-- CREDENTIAL DIRECTIVES (Prosody 13.0+)
-- ===============================================

-- Database credentials
-- Uses CREDENTIALS_DIRECTORY environment variable
-- Compatible with systemd credentials and podman secrets
-- Example: database_password = Credential("db_password")

-- LDAP integration credentials
-- For enterprise directory integration
-- Example: ldap_bind_password = Credential("ldap_password")

-- Component shared secrets
-- For external component authentication (XEP-0114)
-- Example: component_secret = Credential("component_secret")

-- External service API keys
-- For webhooks, OAuth providers, etc.
-- Example: oauth_client_secret = Credential("oauth_secret")

-- ===============================================
-- FILE CONTENT DIRECTIVES (Prosody 13.0+)
-- ===============================================

-- Administrator list from external file
-- Allows dynamic management without config changes
-- Example: admins = FileLines("admins.txt")

-- Message of the Day from external file
-- For announcements and server information
-- Example: motd_text = FileContents("/etc/motd")

-- SSL/TLS certificate paths from external configuration
-- Enables certificate rotation without service restart
-- Example: ssl_cert_path = FileLine("ssl_cert_path.txt")

-- Firewall rules and access control lists
-- External file management for security policies
-- Example: blocked_domains = FileLines("blocked_domains.txt")

-- ===============================================
-- ENVIRONMENT INTEGRATION
-- ===============================================

local function setup_credential_management()
	local credentials_dir = os.getenv("CREDENTIALS_DIRECTORY")

	if credentials_dir then
		-- Prosody 13.0+ credential support available
		print("Credential management: Using systemd/podman credentials")

		-- Set up credential-based configuration
		-- Uncomment and customize as needed:

		-- Database authentication
		-- sql = {
		--     driver = "PostgreSQL",
		--     database = "prosody",
		--     username = "prosody",
		--     password = Credential("db_password"),
		--     host = "localhost"
		-- }

		-- LDAP integration
		-- ldap_base = "dc=example,dc=com"
		-- ldap_server = "ldap://ldap.example.com"
		-- ldap_rootdn = "cn=prosody,ou=services,dc=example,dc=com"
		-- ldap_password = Credential("ldap_password")

		-- Component secrets
		-- Component "transport.example.com"
		--     component_secret = Credential("transport_secret")
	else
		-- Fallback to environment variables
		print("Credential management: Using environment variables")

		-- Traditional environment variable approach
		-- local db_password = os.getenv("PROSODY_DB_PASSWORD")
		-- local ldap_password = os.getenv("PROSODY_LDAP_PASSWORD")
		-- etc.
	end
end

-- Initialize credential management
setup_credential_management()

-- ===============================================
-- SECURITY BEST PRACTICES
-- ===============================================

-- File permissions for credential files should be 600 (owner read/write only)
-- Credential directory should be owned by prosody user
-- Use systemd DynamicUser=true with LoadCredential= for maximum security
-- Consider using podman secrets for containerized deployments

-- Example systemd service configuration:
-- [Service]
-- DynamicUser=true
-- LoadCredential=db_password:/etc/prosody/secrets/db_password
-- LoadCredential=ldap_password:/etc/prosody/secrets/ldap_password
-- Environment=CREDENTIALS_DIRECTORY=%d/credentials

-- Example podman secret usage:
-- podman secret create prosody_db_password /path/to/password/file
-- podman run --secret prosody_db_password prosody
