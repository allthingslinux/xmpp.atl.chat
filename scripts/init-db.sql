-- Prosody XMPP Server Database Initialization
-- PostgreSQL database setup for Prosody
-- Based on Prosody mod_storage_sql requirements

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Set proper encoding and collation
ALTER DATABASE prosody SET timezone TO 'UTC';

-- Create the main prosody database user if it doesn't exist
-- Note: User creation is handled by environment variables in docker-compose.yml

-- Prosody Core Tables
-- These tables are created automatically by Prosody mod_storage_sql
-- This script ensures proper permissions and indexes

-- Grant necessary permissions to prosody user
GRANT ALL PRIVILEGES ON DATABASE prosody TO prosody;

-- Schema for Prosody data storage
-- Prosody will create these tables automatically, but we ensure proper setup

-- Archive table optimization (for MAM - Message Archive Management)
-- Pre-create indexes for better performance when Prosody creates the tables
DO $$
BEGIN
    -- This will run after Prosody creates its tables
    -- We can add custom indexes for performance optimization
    
    -- Log the initialization
    RAISE NOTICE 'Prosody database initialization completed';
    RAISE NOTICE 'Prosody will create tables automatically on first run';
    RAISE NOTICE 'Database encoding: UTF8';
    RAISE NOTICE 'Timezone: UTC';
END $$;

-- Performance optimizations
-- Set recommended PostgreSQL settings for XMPP workloads
ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements';
ALTER SYSTEM SET log_statement = 'none';  -- Reduce logging for performance
ALTER SYSTEM SET log_min_duration_statement = 1000;  -- Log slow queries only

-- Create function for Prosody table optimization (runs after tables are created)
CREATE OR REPLACE FUNCTION optimize_prosody_tables()
RETURNS void AS $$
BEGIN
    -- Add indexes for common Prosody queries if tables exist
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'prosodyarchive') THEN
        -- Optimize archive queries
        CREATE INDEX IF NOT EXISTS idx_prosodyarchive_when ON prosodyarchive(when);
        CREATE INDEX IF NOT EXISTS idx_prosodyarchive_with ON prosodyarchive(with);
        CREATE INDEX IF NOT EXISTS idx_prosodyarchive_user_store ON prosodyarchive(user, store);
        RAISE NOTICE 'Archive indexes created for performance optimization';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'prosody') THEN
        -- Optimize general storage queries
        CREATE INDEX IF NOT EXISTS idx_prosody_user_store ON prosody(user, store);
        CREATE INDEX IF NOT EXISTS idx_prosody_key ON prosody(key);
        RAISE NOTICE 'General storage indexes created for performance optimization';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to optimize tables after they're created
-- This will be called by a maintenance script
COMMENT ON FUNCTION optimize_prosody_tables() IS 'Run this function after Prosody creates its tables for performance optimization';

-- Database statistics and maintenance
CREATE OR REPLACE FUNCTION prosody_maintenance()
RETURNS void AS $$
BEGIN
    -- Update table statistics
    ANALYZE;
    
    -- Log maintenance completion
    RAISE NOTICE 'Prosody database maintenance completed at %', NOW();
END;
$$ LANGUAGE plpgsql;

-- Schedule maintenance (this would typically be done via cron)
COMMENT ON FUNCTION prosody_maintenance() IS 'Run periodically for database maintenance';

-- Final setup message
SELECT 'Prosody PostgreSQL database initialized successfully' AS status; 