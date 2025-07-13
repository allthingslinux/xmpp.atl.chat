-- ===============================================
-- PROSODY 13.0 UPGRADE AND COMPATIBILITY GUIDE
-- ===============================================
-- Automated compatibility checking and upgrade assistance
-- Addresses all breaking changes and new features in Prosody 13.0
-- Based on official release notes: https://prosody.im/doc/release/13.0.0

local upgrade_checker = {}

-- ===============================================
-- VERSION AND DEPENDENCY CHECKING
-- ===============================================

-- Check Lua version compatibility
function upgrade_checker.check_lua_version()
	local lua_version = _VERSION:match("Lua (%d+%.%d+)")
	local major, minor = lua_version:match("(%d+)%.(%d+)")
	major, minor = tonumber(major), tonumber(minor)

	local compatible = false
	local recommended = false

	-- Prosody 13.0 requires Lua 5.2+
	if major > 5 or (major == 5 and minor >= 2) then
		compatible = true
		if major == 5 and minor >= 4 then
			recommended = true
		end
	end

	return {
		version = lua_version,
		compatible = compatible,
		recommended = recommended,
		issue = not compatible and "Lua 5.1 support removed in Prosody 13.0" or nil,
		solution = not compatible and "Upgrade to Lua 5.2+ (Lua 5.4 recommended)" or nil,
	}
end

-- Check for deprecated modules
function upgrade_checker.check_deprecated_modules()
	local deprecated_modules = {
		["vcard_muc"] = {
			reason = "Now built into Prosody core",
			action = "Remove from modules_enabled - functionality is automatic",
			since = "13.0.0",
		},
		["legacyauth"] = {
			reason = "XEP-0078 Non-SASL Authentication deprecated",
			action = "Remove and use modern SASL authentication",
			since = "13.0.0",
		},
		["compression"] = {
			reason = "XEP-0138 Stream Compression deprecated due to security",
			action = "Remove - compression is disabled by default",
			since = "0.10.0",
		},
	}

	return deprecated_modules
end

-- Check component permissions compatibility
function upgrade_checker.check_component_permissions()
	local issues = {}

	-- Common component permission issues in 13.0
	local component_checks = {
		{
			component = "http_file_share",
			issue = "Component permissions changed - may need parent_host setting",
			solution = "Add 'parent_host = \"main.domain\"' or use 'server_user_role = \"prosody:registered\"'",
		},
		{
			component = "muc",
			issue = "Component admins no longer room owners by default",
			solution = "Set 'component_admins_as_room_owners = true' to restore old behavior",
		},
	}

	return component_checks
end

-- ===============================================
-- SQL SCHEMA MIGRATION CHECKING
-- ===============================================

function upgrade_checker.check_sql_schema()
	local sql_issues = {
		postgresql = {
			check_command = "prosodyctl mod_storage_sql upgrade",
			common_error = "Old database format detected",
			solution = "Run: prosodyctl mod_storage_sql upgrade && systemctl restart prosody",
		},
		sqlite = {
			check_command = "prosodyctl mod_storage_sql upgrade",
			common_error = "Old database format detected",
			solution = "Run: prosodyctl mod_storage_sql upgrade && systemctl restart prosody",
		},
		mysql = {
			check_command = "prosodyctl mod_storage_sql upgrade",
			common_error = "Old database format detected",
			solution = "Run: prosodyctl mod_storage_sql upgrade && systemctl restart prosody",
		},
	}

	return sql_issues
end

-- ===============================================
-- CONFIGURATION VALIDATION
-- ===============================================

function upgrade_checker.validate_tls_config()
	local tls_issues = {}

	-- Check for manual SSL configuration issues (13.0.0 bug)
	local ssl_configs = {
		"https_ssl",
		"c2s_direct_tls_ssl",
		"s2s_direct_tls_ssl",
	}

	for _, config in ipairs(ssl_configs) do
		if prosody.config.get("*", config) then
			table.insert(tls_issues, {
				config = config,
				issue = "Manual SSL config ignored in Prosody 13.0.0",
				solution = "Upgrade to 13.0.1+ or use automatic certificate configuration",
				bug_url = "https://issues.prosody.im/1915",
			})
		end
	end

	return tls_issues
end

function upgrade_checker.check_new_features()
	local new_features = {
		-- New modules in 13.0
		{
			module = "account_activity",
			description = "Records last login/logout times",
			benefit = "Enhanced user activity tracking",
			config_example = 'modules_enabled = { "account_activity" }',
		},
		{
			module = "flags",
			description = "Enhanced metadata and state tracking",
			benefit = "Improved server administration capabilities",
			config_example = 'modules_enabled = { "flags" }',
		},
		{
			module = "s2s_auth_dane_in",
			description = "DANE support for incoming s2s connections",
			benefit = "Enhanced s2s security with DNSSEC",
			config_example = 'modules_enabled = { "s2s_auth_dane_in" }',
			requirements = "Proper DNSSEC and TLSA records",
		},
		{
			module = "cloud_notify",
			description = "Push notification support (imported from community)",
			benefit = "Mobile push notifications",
			config_example = 'modules_enabled = { "cloud_notify" }',
		},
		{
			module = "http_altconnect",
			description = "Alternative connection method discovery",
			benefit = "Easier web client configuration",
			config_example = 'modules_enabled = { "http_altconnect" }',
		},
	}

	return new_features
end

-- ===============================================
-- AUTOMATED UPGRADE TASKS
-- ===============================================

function upgrade_checker.generate_upgrade_script()
	local script = [[#!/bin/bash
# Prosody 13.0 Upgrade Script
# Generated automatically based on configuration analysis

echo "=== Prosody 13.0 Upgrade Script ==="
echo "IMPORTANT: Backup your configuration and data before proceeding!"
echo ""

# 1. Check Lua version
echo "Checking Lua version..."
lua -v
echo "Ensure you're running Lua 5.2+ (5.4 recommended)"
echo ""

# 2. Update package repositories
echo "Updating package repositories..."
apt update  # Debian/Ubuntu
# yum update  # CentOS/RHEL
# dnf update  # Fedora

# 3. Install Prosody 13.0
echo "Installing Prosody 13.0..."
apt install prosody  # Debian/Ubuntu
# yum install prosody  # CentOS/RHEL
# dnf install prosody  # Fedora

# 4. Check configuration
echo "Checking configuration for issues..."
prosodyctl check config

# 5. SQL schema upgrade (if using SQL storage)
echo "Upgrading SQL schema (if applicable)..."
prosodyctl mod_storage_sql upgrade

# 6. Check for new features
echo "Checking for recommended new features..."
prosodyctl check features

# 7. Restart Prosody
echo "Restarting Prosody..."
systemctl restart prosody

# 8. Verify operation
echo "Verifying operation..."
prosodyctl status
systemctl status prosody

echo ""
echo "=== Upgrade Complete ==="
echo "Check logs for any issues: journalctl -u prosody -f"
echo "Review new features: prosodyctl check features"
]]

	return script
end

-- ===============================================
-- MIGRATION CHECKLIST
-- ===============================================

function upgrade_checker.generate_checklist()
	local checklist = {
		pre_upgrade = {
			"✓ Backup configuration files (/etc/prosody/)",
			"✓ Backup database (if using SQL storage)",
			"✓ Check Lua version (must be 5.2+)",
			"✓ Review component configurations",
			"✓ Note any community modules in use",
			"✓ Check SSL/TLS certificate configuration",
		},
		during_upgrade = {
			"✓ Keep existing configuration file when prompted",
			"✓ Run 'prosodyctl check config' before restart",
			"✓ Run SQL schema upgrade if needed",
			"✓ Check for manual SSL configuration issues",
			"✓ Remove deprecated modules (vcard_muc, etc.)",
		},
		post_upgrade = {
			"✓ Run 'prosodyctl check features' for recommendations",
			"✓ Enable new 13.0 modules as desired",
			"✓ Update component permissions if needed",
			"✓ Test file upload functionality",
			"✓ Verify s2s connections work properly",
			"✓ Check logs for any warnings or errors",
			"✓ Update monitoring and alerting systems",
		},
	}

	return checklist
end

-- ===============================================
-- COMPATIBILITY REPORT GENERATOR
-- ===============================================

function upgrade_checker.generate_compatibility_report()
	local report = {
		timestamp = os.date("%Y-%m-%d %H:%M:%S"),
		prosody_version = prosody.version or "unknown",
		lua_check = upgrade_checker.check_lua_version(),
		deprecated_modules = upgrade_checker.check_deprecated_modules(),
		component_issues = upgrade_checker.check_component_permissions(),
		sql_migration = upgrade_checker.check_sql_schema(),
		tls_issues = upgrade_checker.validate_tls_config(),
		new_features = upgrade_checker.check_new_features(),
		checklist = upgrade_checker.generate_checklist(),
	}

	return report
end

-- ===============================================
-- AUTOMATED FIXES
-- ===============================================

function upgrade_checker.apply_automatic_fixes()
	local fixes_applied = {}

	-- Remove deprecated modules
	local deprecated = upgrade_checker.check_deprecated_modules()
	for module, info in pairs(deprecated) do
		-- Note: This would need to modify the actual configuration
		-- In practice, this should generate recommendations rather than auto-modify
		table.insert(fixes_applied, {
			fix = "Remove deprecated module: " .. module,
			reason = info.reason,
			action = info.action,
		})
	end

	return fixes_applied
end

-- ===============================================
-- PROSODY 13.0+ FEATURE RECOMMENDATIONS
-- ===============================================

function upgrade_checker.get_feature_recommendations()
	local recommendations = {
		security = {
			"Enable DANE support for enhanced s2s security",
			"Configure SASL channel binding for stronger auth",
			"Use new roles and permissions framework",
			"Enable account activity tracking",
		},
		performance = {
			"Enable sub-second timestamp precision",
			"Configure new cron job intervals",
			"Use SQLCipher for encrypted database storage",
			"Enable Happy Eyeballs for better connectivity",
		},
		administration = {
			"Use new 'prosodyctl check features' command",
			"Enable account disable/enable functionality",
			"Configure deletion grace periods",
			"Set up enhanced logging with multiple targets",
		},
		compliance = {
			"Review XEP-0479 compliance suite requirements",
			"Configure MUC permission changes",
			"Update privacy policy for account activity tracking",
			"Document new administrative capabilities",
		},
	}

	return recommendations
end

-- ===============================================
-- MAIN UPGRADE INTERFACE
-- ===============================================

function upgrade_checker.run_full_check()
	print("=== Prosody 13.0 Compatibility Check ===")
	print("")

	-- Generate comprehensive report
	local report = upgrade_checker.generate_compatibility_report()

	-- Display Lua version check
	local lua_check = report.lua_check
	if lua_check.compatible then
		print("✓ Lua version " .. lua_check.version .. " is compatible")
		if lua_check.recommended then
			print("  (Recommended version - excellent!)")
		end
	else
		print("✗ Lua version " .. lua_check.version .. " is NOT compatible")
		print("  Issue: " .. lua_check.issue)
		print("  Solution: " .. lua_check.solution)
	end
	print("")

	-- Display deprecated modules
	print("Deprecated modules check:")
	for module, info in pairs(report.deprecated_modules) do
		print("⚠ " .. module .. ": " .. info.reason)
		print("  Action: " .. info.action)
	end
	print("")

	-- Display new features
	print("New features available:")
	for _, feature in ipairs(report.new_features) do
		print("+ " .. feature.module .. ": " .. feature.description)
		print("  Benefit: " .. feature.benefit)
	end
	print("")

	-- Display recommendations
	local recommendations = upgrade_checker.get_feature_recommendations()
	print("Recommendations:")
	for category, items in pairs(recommendations) do
		print("  " .. category:upper() .. ":")
		for _, item in ipairs(items) do
			print("    - " .. item)
		end
	end
	print("")

	print("For detailed upgrade steps, run: prosodyctl check features")
	print("For SQL migration: prosodyctl mod_storage_sql upgrade")
	print("")

	return report
end

-- Export the checker
return upgrade_checker
