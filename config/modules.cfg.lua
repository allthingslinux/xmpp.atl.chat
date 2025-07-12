-- ============================================================================
-- MODULE MANAGEMENT CONFIGURATION
-- ============================================================================
-- Module loading, organization by source and requirements

-- ============================================================================
-- CORE MODULES (SHIPPED WITH PROSODY)
-- ============================================================================

-- All modules shipped with Prosody - includes required, autoloaded, and distributed modules
-- Simplified organization: all Prosody-shipped modules in one category
local core_modules = {
	-- Essential modules (required - cannot be disabled)
	"roster",
	"saslauth",
	"tls",
	"dialback",
	"disco",
	"c2s",
	"s2s",
	"private",
	"vcard",
	"version",
	"uptime",
	"time",
	"ping",

	-- Autoloaded modules (loaded by default but can be disabled)
	"presence",
	"message",
	"iq",
	"offline",
	"s2s_auth_certs",

	-- Modern XMPP features (shipped with Prosody)
	"carbons",
	"mam",
	"smacks",
	"csi",
	"csi_simple",
	"bookmarks",
	"blocklist",
	"lastactivity",
	"pep",

	-- Security and administration
	"limits",
	"admin_adhoc",
	"admin_shell",
	"invites",
	"invites_adhoc",
	"invites_register",
	"tombstones",
	"server_contact_info",
	"watchregistrations",

	-- HTTP services
	"http",
	"http_errors",
	"http_files",
	"http_file_share",
	"bosh",
	"websocket",
	"http_openmetrics",

	-- Multi-user chat
	"muc",
	"muc_mam",
	"muc_unique",

	-- File transfer and media
	"proxy65",
	"turn_external",

	-- User profiles and vCard
	"vcard4",
	"vcard_legacy",

	-- Miscellaneous modules
	"motd",
	"welcome",
	"announce",
	"register_ibr",
	"register_limits",
	"user_account_management",
	"mimicking",
	"cloud_notify",
	"statistics",
}

-- ============================================================================
-- COMMUNITY MODULES (THIRD-PARTY)
-- ============================================================================

-- Community modules (third-party - use with caution)
local community_stable_modules = {
	-- Official stable community modules from prosody-modules
	-- These modules are stable and should be safe to use

	-- Authentication and security
	"auth_sql", -- SQL Database authentication module
	"host_guard", -- Granular remote host blacklisting plugin
	"log_auth", -- Log failed authentication attempts with their IP address
	"require_otr", -- Enforce a policy for OTR-encrypted messages
	"saslname", -- XEP-0233: XMPP Server Registration for use with Kerberos V5

	-- Connection management
	"c2s_conn_throttle", -- c2s connections throttling module
	"s2s_idle_timeout", -- Close idle server-to-server connections

	-- Communication features
	"broadcast", -- Broadcast a message to online users
	"pastebin", -- Redirect long messages to built-in pastebin
	"vcard_muc", -- Support for MUC vCards and avatars
	"webpresence", -- Display your online status in web pages

	-- HTTP and web features
	"http_libjs", -- Serve common Javascript libraries
	"pubsub_post", -- Publish to PubSub nodes from via HTTP POST/WebHooks

	-- Registration and user management
	"register_json", -- Token based JSON registration & verification servlet
	"register_redirect", -- XEP-077 IBR Registration Redirect
	"support_contact", -- Add a support contact to new registrations

	-- Monitoring and administration
	"ipcheck", -- XEP-0279: Server IP Check
	"log_slow_events", -- Log warning when event handlers take too long
	"reload_modules", -- Automatically reload modules with the config
	"server_status", -- Server status plugin
	"stanza_counter", -- Simple incoming and outgoing stanza counter

	-- Security modules
	"firewall", -- Network firewall rules
	"block_registrations", -- Block user registrations
}

-- Beta community modules (working, but need more testing)
local community_beta_modules = {
	-- Administration and management
	"admin_blocklist", -- Block s2s connections based on admin blocklist
	"admin_message", -- IM-based administration console
	"admin_web", -- Web administration interface

	-- Authentication and security
	"auth_ha1", -- Authentication module for 'HA1' hashed credentials
	"auth_internal_yubikey", -- Two-factor authentication using Yubikeys
	"spam_reporting", -- XEP-0377: Spam Reporting
	"watch_spam_reports", -- Notify admins about incoming XEP-0377 spam reports

	-- Modern SASL and authentication
	"sasl2", -- XEP-0388: Extensible SASL Profile
	"sasl2_bind2", -- Bind 2 integration with SASL2
	"sasl2_fast", -- Fast Authentication Streamlining Tokens

	-- Push notifications
	"cloud_notify_extensions", -- Tigase custom push extensions for iOS

	-- Compliance and testing
	"compliance_2023", -- XMPP Compliance Suites 2023 self-test
	"compliance_latest", -- XMPP Compliance Suites self-test

	-- User experience
	"auto_accept_subscriptions", -- Automatically accept incoming subscription requests
	"client_management", -- Manage clients with access to your account
	"default_vcard", -- Automatically populate vcard based on account details
	"group_bookmarks", -- mod_groups for chatrooms

	-- HTTP and web features
	"http_admin_api", -- Admin API from the snikket projects web portal
	"http_authentication", -- Enforces HTTP Basic authentication across all HTTP endpoints
	"http_index", -- Generate an index of local HTTP services
	"http_muc_log", -- Provides a web interface to stored chatroom logs
	"http_upload_external", -- Variant of mod_http_upload that delegates HTTP handling

	-- Invitations and registration
	"invites_api", -- Authenticated HTTP API to create invites
	"invites_page", -- Generate friendly web page for invitations
	"invites_register_web", -- Register accounts via the web using invite tokens
	"register_apps", -- Manage list of compatible client apps
	"captcha_registration", -- Provides captcha protection for registration form

	-- MUC enhancements
	"muc_auto_member", -- Automatically register new MUC participants as members
	"muc_limits", -- Impose rate-limits on a MUC
	"muc_moderation", -- Let moderators remove spam and abuse messages

	-- Logging and monitoring
	"lastlog", -- Log last login time
	"lastlog2", -- Record last timestamp of events
	"message_logging", -- Log/archive all user messages
	"munin", -- Implementation of the Munin node protocol

	-- PubSub enhancements
	"pubsub_eventsource", -- Subscribe to pubsub nodes using the HTML5 EventSource API
	"pubsub_forgejo", -- Turn forgejo/github/gitlab webhooks into atom-in-pubsub
	"pubsub_github", -- Publish Github commits over pubsub

	-- Server management
	"host_status_check", -- Host status check
	"host_status_heartbeat", -- Host status heartbeat
	"isolate_host", -- Prevent communication between hosts
	"s2s_keepalive", -- Keepalive s2s connections

	-- Miscellaneous
	"delegation", -- XEP-0355 (Namespace Delegation) implementation
	"privilege", -- XEP-0356 (Privileged Entity) implementation
	"roster_allinall", -- Add everyone to everyones roster on the server
	"welcome_page", -- Serve a welcome page to users
}

-- Alpha/Experimental modules (use with extreme caution)
local community_alpha_modules = {
	-- Monitoring and enterprise features
	"measure_cpu",
	"measure_memory",
	"measure_message_e2e",
	"json_logs",
	"audit",
	"compliance_policy",
}

-- ============================================================================
-- MODULE LOADING LOGIC
-- ============================================================================

-- Build module list based on environment and requirements
local function build_module_list()
	local modules = {}

	-- Core modules (all Prosody-shipped modules, enabled by default)
	if os.getenv("PROSODY_ENABLE_CORE") ~= "false" then
		for _, module in ipairs(core_modules) do
			table.insert(modules, module)
		end
	end

	-- Community stable modules (security-focused, enabled by default)
	if os.getenv("PROSODY_ENABLE_SECURITY") ~= "false" then
		for _, module in ipairs(community_stable_modules) do
			table.insert(modules, module)
		end
	end

	-- Community beta modules (opt-in for modern features)
	if os.getenv("PROSODY_ENABLE_BETA") == "true" then
		for _, module in ipairs(community_beta_modules) do
			table.insert(modules, module)
		end
	end

	-- Community alpha modules (explicitly opt-in only)
	if os.getenv("PROSODY_ENABLE_ALPHA") == "true" then
		for _, module in ipairs(community_alpha_modules) do
			table.insert(modules, module)
		end
	end

	return modules
end

modules_enabled = build_module_list()

-- ============================================================================
-- MODULE STABILITY INFORMATION
-- ============================================================================

-- Log module stability information on startup
local function log_module_stability()
	local stability_info = {
		core = #core_modules,
		community_stable = #community_stable_modules,
		community_beta = #community_beta_modules,
		community_alpha = #community_alpha_modules,
	}

	log(
		"info",
		"Module profile: Core=%d, Community(Stable=%d, Beta=%d, Alpha=%d)",
		stability_info.core,
		stability_info.community_stable,
		stability_info.community_beta,
		stability_info.community_alpha
	)

	-- Log total enabled modules
	log("info", "Total enabled modules: %d", #modules_enabled)
end

-- Call on startup
log_module_stability()

-- ============================================================================
-- MODULE CONFIGURATION INCLUDES
-- ============================================================================

-- Include modular configuration files based on enabled module categories

-- Always include core modules configuration (shipped with Prosody)
Include("/etc/prosody/modules.d/core/*.cfg.lua")

-- Include community stable modules configuration (security-focused)
if os.getenv("PROSODY_ENABLE_SECURITY") ~= "false" then
	Include("/etc/prosody/modules.d/community/stable/*.cfg.lua")
end

-- Include community beta modules configuration if enabled
if os.getenv("PROSODY_ENABLE_BETA") == "true" then
	Include("/etc/prosody/modules.d/community/beta/*.cfg.lua")
end

-- Include community alpha modules configuration if explicitly enabled
if os.getenv("PROSODY_ENABLE_ALPHA") == "true" then
	Include("/etc/prosody/modules.d/community/alpha/*.cfg.lua")
end

-- Include any additional configuration
Include("/etc/prosody/conf.d/*.cfg.lua")
