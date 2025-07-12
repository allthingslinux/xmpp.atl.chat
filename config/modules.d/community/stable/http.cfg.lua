-- ============================================================================
-- HTTP MODULES (STABLE)
-- ============================================================================
-- Stability Level: 🟢 Stable (Production Ready)
-- HTTP services, web features, and JavaScript libraries

-- ============================================================================
-- mod_http_libjs - Serve Common Javascript Libraries
-- ============================================================================
-- Serve popular JavaScript libraries (jQuery, Bootstrap, etc.) from your server
-- Reduces external dependencies and improves privacy for web clients

http_libjs_path = os.getenv("PROSODY_LIBJS_PATH") or "/usr/share/javascript"
http_libjs_cache_time = tonumber(os.getenv("PROSODY_LIBJS_CACHE_TIME")) or 86400 -- 24 hours

-- Serve common libraries (jQuery, etc.)
http_libjs_serve = {
	jquery = os.getenv("PROSODY_SERVE_JQUERY") ~= "false",
	bootstrap = os.getenv("PROSODY_SERVE_BOOTSTRAP") == "true",
}

-- ============================================================================
-- mod_pubsub_post - Publish to PubSub Nodes from via HTTP POST/WebHooks
-- ============================================================================
-- Accept HTTP POST requests to publish items to PubSub nodes
-- Enables integration with external services and webhooks

pubsub_post_actor = os.getenv("PROSODY_PUBSUB_POST_ACTOR") or "admin@localhost"
pubsub_post_realm = os.getenv("PROSODY_PUBSUB_POST_REALM") or "pubsub"

-- Webhook security
pubsub_post_secret = os.getenv("PROSODY_PUBSUB_POST_SECRET") -- Required for security
pubsub_post_max_content_length = tonumber(os.getenv("PROSODY_PUBSUB_POST_MAX_SIZE")) or 1048576 -- 1MB
