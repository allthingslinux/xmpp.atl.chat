-- Layer 06: Storage - Backends Configuration
-- Database backends, storage drivers, and data persistence
-- SQL, NoSQL, and file-based storage options for different deployment scenarios

local storage_backends = {
	-- SQL Database Backends
	-- Production-ready SQL storage for scalability
	sql_backends = {
		"storage_sql", -- SQL storage driver (community)
		"storage_sql2", -- Enhanced SQL storage (community)
	},

	-- File-based Storage
	-- Default file storage for simple deployments
	file_storage = {
		"storage_internal", -- Default internal storage (core)
		"storage_none", -- Disable storage for specific data (core)
	},

	-- Memory Storage
	-- High-performance in-memory storage
	memory_storage = {
		"storage_memory", -- In-memory storage (community)
	},

	-- Archive Storage
	-- Specialized storage for message archives
	archive_storage = {
		"storage_xmlarchive", -- XML-based archive storage (community)
	},
}

-- Storage Backend Configuration
-- Configure storage drivers for different data types
local storage_config = {
	-- Default storage backend
	default_storage = "internal", -- Use internal file storage by default

	-- Per-data-type storage configuration
	storage = {
		-- User accounts and authentication data
		accounts = "internal",

		-- Roster (contact list) storage
		roster = "internal",

		-- Private XML storage (XEP-0049)
		private = "internal",

		-- vCard storage (XEP-0054)
		vcard = "internal",

		-- Message archive storage (XEP-0313)
		archive = "internal", -- Can be changed to "sql" for production

		-- Offline message storage
		offline = "internal",

		-- PubSub node storage
		pubsub = "internal",

		-- Multi-User Chat (MUC) data
		muc_log = "internal",
		muc_config = "internal",
	},

	-- SQL Database Configuration (when using SQL storage)
	sql = {
		driver = "SQLite3", -- Options: SQLite3, PostgreSQL, MySQL
		database = "prosody.sqlite", -- Database file/name
		-- host = "localhost", -- Database host (for PostgreSQL/MySQL)
		-- port = 5432, -- Database port
		-- username = "prosody", -- Database username
		-- password = "password", -- Database password
	},
}

-- Storage Module Loading
-- Load appropriate storage modules based on configuration
local function load_storage_modules()
	local modules = {}

	-- Always load core storage modules
	for _, module in ipairs(storage_backends.file_storage) do
		table.insert(modules, module)
	end

	-- Load SQL modules if SQL storage is configured
	if storage_config.sql and storage_config.sql.driver then
		for _, module in ipairs(storage_backends.sql_backends) do
			table.insert(modules, module)
		end
	end

	-- Load memory storage if configured
	for _, store_type in pairs(storage_config.storage) do
		if store_type == "memory" then
			for _, module in ipairs(storage_backends.memory_storage) do
				table.insert(modules, module)
			end
			break
		end
	end

	return modules
end

-- Export configuration
return {
	modules = load_storage_modules(),
	config = storage_config,
}
