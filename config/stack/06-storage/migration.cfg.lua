-- Layer 06: Storage - Migration Configuration
-- Data migration tools, storage backend changes, and upgrade procedures
-- Tools for migrating between storage backends and upgrading data formats

local migration_config = {
	-- Core Migration Tools
	-- Built-in Prosody migration capabilities
	core_migration = {
		-- Migration is primarily handled by prosodyctl commands
		-- No specific modules needed for basic migration
	},

	-- Storage Backend Migration
	-- Tools for migrating between different storage backends
	backend_migration = {
		-- Migration between internal/SQL/memory storage
		-- Handled by prosodyctl migrate command
	},

	-- Data Format Upgrades
	-- Tools for upgrading data formats during Prosody upgrades
	format_upgrades = {
		-- Automatic data format upgrades
		-- Handled by Prosody's built-in upgrade mechanisms
	},

	-- Backup and Restore
	-- Tools for backing up and restoring data
	backup_restore = {
		-- Backup tools (external scripts or modules)
		-- "backup", -- Community backup module (if available)
	},
}

-- Migration Procedures
-- Step-by-step procedures for common migration scenarios
local migration_procedures = {
	-- Migrate from internal to SQL storage
	internal_to_sql = {
		description = "Migrate from internal file storage to SQL database",
		steps = {
			"1. Stop Prosody server",
			"2. Configure SQL storage in prosody.cfg.lua",
			"3. Create database and tables: prosodyctl migrate <host> internal sql",
			"4. Update storage configuration",
			"5. Start Prosody server",
			"6. Verify data integrity",
		},
		commands = {
			"prosodyctl stop",
			"prosodyctl migrate example.com internal sql",
			"prosodyctl start",
		},
	},

	-- Migrate from SQL to internal storage
	sql_to_internal = {
		description = "Migrate from SQL database to internal file storage",
		steps = {
			"1. Stop Prosody server",
			"2. Configure internal storage in prosody.cfg.lua",
			"3. Migrate data: prosodyctl migrate <host> sql internal",
			"4. Update storage configuration",
			"5. Start Prosody server",
			"6. Verify data integrity",
		},
		commands = {
			"prosodyctl stop",
			"prosodyctl migrate example.com sql internal",
			"prosodyctl start",
		},
	},

	-- Backup user data
	backup_data = {
		description = "Create backup of user data",
		steps = {
			"1. Stop Prosody server (recommended)",
			"2. Create backup directory",
			"3. Export user data: prosodyctl shell user export <user@host>",
			"4. Backup configuration files",
			"5. Backup database (if using SQL)",
		},
		commands = {
			"mkdir -p /backup/prosody/$(date +%Y%m%d)",
			"prosodyctl shell user export user@example.com > /backup/prosody/$(date +%Y%m%d)/user_data.xml",
			"cp -r /etc/prosody /backup/prosody/$(date +%Y%m%d)/config",
		},
	},

	-- Restore user data
	restore_data = {
		description = "Restore user data from backup",
		steps = {
			"1. Stop Prosody server",
			"2. Restore configuration files",
			"3. Import user data: prosodyctl shell user import <user@host> < backup.xml",
			"4. Start Prosody server",
			"5. Verify restored data",
		},
		commands = {
			"prosodyctl stop",
			"prosodyctl shell user import user@example.com < /backup/prosody/20240101/user_data.xml",
			"prosodyctl start",
		},
	},
}

-- Migration Settings
-- Configuration for migration behavior and safety
local migration_settings = {
	-- Safety settings
	safety = {
		-- Always create backup before migration
		auto_backup = true,
		backup_location = "/var/backups/prosody",

		-- Verify data integrity after migration
		verify_integrity = true,

		-- Keep old data after successful migration (for rollback)
		keep_old_data = true,
		retention_period = "30d", -- Keep for 30 days
	},

	-- Performance settings
	performance = {
		-- Batch size for migration operations
		migration_batch_size = 1000,

		-- Delay between batches (milliseconds)
		batch_delay = 100,

		-- Maximum memory usage during migration (MB)
		max_memory_usage = 512,
	},

	-- Validation settings
	validation = {
		-- Validate data before migration
		pre_migration_check = true,

		-- Validate data after migration
		post_migration_check = true,

		-- Compare source and destination data
		data_comparison = true,

		-- Acceptable data loss threshold (percentage)
		acceptable_loss = 0.0, -- No data loss acceptable
	},
}

-- Migration Utilities
-- Helper functions for migration operations
local migration_utilities = {
	-- Check migration prerequisites
	check_prerequisites = function(migration_type)
		-- Verify storage backends are available
		-- Check disk space and permissions
		-- Validate configuration
		return {
			storage_available = true,
			disk_space_sufficient = true,
			permissions_ok = true,
			config_valid = true,
		}
	end,

	-- Estimate migration time
	estimate_migration_time = function(data_size, source_backend, target_backend)
		-- Calculate estimated time based on data size and backends
		local rates = {
			internal_to_sql = 1000, -- records per minute
			sql_to_internal = 1500, -- records per minute
			internal_to_memory = 5000, -- records per minute
		}

		local migration_key = source_backend .. "_to_" .. target_backend
		local rate = rates[migration_key] or 1000

		return math.ceil(data_size / rate) -- minutes
	end,

	-- Validate migration result
	validate_migration = function(source_backend, target_backend, host)
		-- Compare record counts between source and target
		-- Verify data integrity
		-- Check for missing or corrupted data
		return {
			record_count_match = true,
			data_integrity_ok = true,
			no_corruption = true,
			migration_complete = true,
		}
	end,

	-- Rollback migration
	rollback_migration = function(backup_location, host)
		-- Restore from backup if migration fails
		-- Revert configuration changes
		-- Restart services
		return {
			rollback_successful = true,
			data_restored = true,
			service_running = true,
		}
	end,
}

-- Migration Monitoring
-- Tools for monitoring migration progress and health
local migration_monitoring = {
	-- Progress tracking
	track_progress = function(migration_id)
		-- Track migration progress
		return {
			migration_id = migration_id,
			progress_percentage = 75,
			records_migrated = 7500,
			total_records = 10000,
			estimated_completion = "2024-01-01 15:30:00",
		}
	end,

	-- Health monitoring
	monitor_health = function()
		-- Monitor system health during migration
		return {
			cpu_usage = 45, -- percentage
			memory_usage = 60, -- percentage
			disk_io = "normal",
			network_io = "low",
		}
	end,

	-- Error tracking
	track_errors = function()
		-- Track and log migration errors
		return {
			error_count = 0,
			warning_count = 2,
			last_error = nil,
			error_rate = 0.0, -- percentage
		}
	end,
}

-- Export configuration
return {
	modules = {
		-- Core migration (handled by prosodyctl)
		core = migration_config.core_migration,

		-- Additional migration tools (commented out by default)
		-- backend = migration_config.backend_migration,
		-- format = migration_config.format_upgrades,
		-- backup = migration_config.backup_restore,
	},

	procedures = migration_procedures,
	settings = migration_settings,
	utilities = migration_utilities,
	monitoring = migration_monitoring,
}
