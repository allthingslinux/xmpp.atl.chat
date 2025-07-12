-- ============================================================================
-- DATABASE CONFIGURATION
-- ============================================================================
-- Storage backend configuration, database connections, and data management

-- ============================================================================
-- STORAGE BACKEND SELECTION
-- ============================================================================

-- Storage backend selection
local storage_backend = os.getenv("PROSODY_STORAGE") or "sql"
default_storage = storage_backend

-- ============================================================================
-- SQL DATABASE CONFIGURATION
-- ============================================================================

if storage_backend == "sql" then
    sql = {
        driver = os.getenv("PROSODY_DB_DRIVER") or "PostgreSQL";
        database = os.getenv("PROSODY_DB_NAME") or "prosody";
        host = os.getenv("PROSODY_DB_HOST") or "localhost";
        port = tonumber(os.getenv("PROSODY_DB_PORT")) or 5432;
        username = os.getenv("PROSODY_DB_USER") or "prosody";
        password = os.getenv("PROSODY_DB_PASSWORD") or "prosody";
        -- Connection pooling
        pool_size = tonumber(os.getenv("PROSODY_DB_POOL_SIZE")) or 5;
        max_connections = tonumber(os.getenv("PROSODY_DB_MAX_CONNECTIONS")) or 20;
        connection_timeout = tonumber(os.getenv("PROSODY_DB_TIMEOUT")) or 30;
    }

-- ============================================================================
-- SQLITE DATABASE CONFIGURATION
-- ============================================================================

elseif storage_backend == "sqlite" then
    sql = {
        driver = "SQLite3";
        database = "/var/lib/prosody/data/prosody.sqlite";
        -- SQLite optimization
        pragma = {
            journal_mode = "WAL";
            synchronous = "NORMAL";
            cache_size = 10000;
            temp_store = "MEMORY";
            mmap_size = 268435456; -- 256MB
        };
    }
end

-- ============================================================================
-- STORAGE CONFIGURATION
-- ============================================================================

-- Archive configuration for message storage
archive_expires_after = os.getenv("PROSODY_ARCHIVE_EXPIRE") or "1y"
max_archive_query_results = tonumber(os.getenv("PROSODY_ARCHIVE_MAX_RESULTS")) or 50

-- Storage paths
data_path = "/var/lib/prosody/data"
plugin_paths = { "/etc/prosody/plugins" }

-- ============================================================================
-- BACKUP AND MAINTENANCE
-- ============================================================================

-- Automatic cleanup settings
archive_cleanup_interval = tonumber(os.getenv("PROSODY_CLEANUP_INTERVAL")) or 86400 -- 24 hours

-- Storage quotas (if enabled)
if os.getenv("PROSODY_ENABLE_QUOTAS") == "true" then
    user_storage_quota = tonumber(os.getenv("PROSODY_USER_QUOTA")) or 104857600 -- 100MB
end 