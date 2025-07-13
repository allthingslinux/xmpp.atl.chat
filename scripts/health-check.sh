#!/bin/bash
set -euo pipefail

# Professional Prosody XMPP Server Health Check
# Comprehensive health monitoring for Docker containers

# ============================================================================
# CONSTANTS
# ============================================================================

readonly PROSODY_CONFIG_DIR="/etc/prosody"
readonly PROSODY_DATA_DIR="/var/lib/prosody/data"
readonly PROSODY_LOG_DIR="/var/log/prosody"
readonly PROSODY_DOMAIN="${PROSODY_DOMAIN:-localhost}"

# Exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_FAILURE=1

# ============================================================================
# HEALTH CHECK FUNCTIONS
# ============================================================================

# Check if prosody process is running using prosodyctl status
check_process() {
    # Use prosodyctl status if available (more reliable)
    if command -v prosodyctl >/dev/null 2>&1; then
        if prosodyctl status >/dev/null 2>&1; then
            echo "INFO: Prosody is running (prosodyctl status)"
            return 0
        else
            echo "ERROR: Prosody process not running (prosodyctl status)"
            return 1
        fi
    else
        # Fallback to process check
        if pgrep -f "prosody" >/dev/null 2>&1; then
            echo "INFO: Prosody process found (pgrep fallback)"
            return 0
        else
            echo "ERROR: Prosody process not running (pgrep fallback)"
            return 1
        fi
    fi
}

# Check if prosody is listening on required ports
check_ports() {
    local ports=(5222 5269)
    local failed=0

    # Add HTTP port if enabled
    if [[ "${PROSODY_ENABLE_HTTP:-false}" == "true" ]]; then
        ports+=(5280)
    fi

    for port in "${ports[@]}"; do
        if ! netstat -tln 2>/dev/null | grep -q ":${port} "; then
            echo "ERROR: Prosody not listening on port $port"
            failed=1
        fi
    done

    return $failed
}

# Check prosody configuration with enhanced prosodyctl checks
check_config() {
    if [[ -f "${PROSODY_CONFIG_DIR}/prosody.cfg.lua" ]]; then
        if command -v prosodyctl >/dev/null 2>&1; then
            # Run comprehensive prosodyctl checks
            local failed_checks=0

            # Configuration check (critical)
            if ! prosodyctl check config >/dev/null 2>&1; then
                echo "ERROR: Prosody configuration validation failed"
                ((failed_checks++))
            fi

            # Features check (non-critical)
            if ! prosodyctl check features >/dev/null 2>&1; then
                echo "WARN: Some Prosody features may be missing or unconfigured"
            fi

            # Certificate check (if certificates exist)
            if ! prosodyctl check certs >/dev/null 2>&1; then
                echo "WARN: Certificate issues detected"
            fi

            # DNS check (if domain is configured)
            if [[ -n "${PROSODY_DOMAIN:-}" ]]; then
                if ! prosodyctl check dns >/dev/null 2>&1; then
                    echo "WARN: DNS configuration issues for ${PROSODY_DOMAIN}"
                fi
            fi

            return $failed_checks
        else
            echo "WARN: prosodyctl not available - basic config validation skipped"
            return 0
        fi
    else
        echo "ERROR: Prosody configuration file not found"
        return 1
    fi
}

# Check SSL certificates
check_certificates() {
    local cert_file="${PROSODY_CONFIG_DIR}/certs/${PROSODY_DOMAIN}.crt"
    local key_file="${PROSODY_CONFIG_DIR}/certs/${PROSODY_DOMAIN}.key"

    if [[ ! -f "$cert_file" ]] || [[ ! -f "$key_file" ]]; then
        echo "WARNING: SSL certificates not found"
        return 0 # Not critical for health check
    fi

    # Check certificate expiry (warn if expires within 7 days)
    if ! openssl x509 -in "$cert_file" -noout -checkend 604800 >/dev/null 2>&1; then
        echo "WARNING: SSL certificate expires within 7 days"
    fi

    return 0
}

# Check database connectivity
check_database() {
    case "${PROSODY_STORAGE:-sqlite}" in
    sqlite)
        local db_file="${PROSODY_DATA_DIR}/prosody.sqlite"
        if [[ -f "$db_file" ]] && [[ -r "$db_file" ]]; then
            return 0
        else
            echo "ERROR: SQLite database not accessible"
            return 1
        fi
        ;;
    sql)
        # For external databases, check if prosody can connect
        # This is implicit in the port check and process check
        return 0
        ;;
    esac
}

# Check log files
check_logs() {
    local log_files=(
        "${PROSODY_LOG_DIR}/prosody.log"
        "${PROSODY_LOG_DIR}/error.log"
    )

    for log_file in "${log_files[@]}"; do
        if [[ ! -f "$log_file" ]]; then
            echo "WARNING: Log file not found: $log_file"
        elif [[ ! -w "$log_file" ]]; then
            echo "ERROR: Cannot write to log file: $log_file"
            return 1
        fi
    done

    return 0
}

# Check for recent errors in logs
check_log_errors() {
    local error_log="${PROSODY_LOG_DIR}/error.log"

    if [[ -f "$error_log" ]]; then
        # Check for errors in the last 5 minutes
        local recent_errors
        recent_errors=$(find "$error_log" -mmin -5 -exec grep -c "ERROR\|FATAL" {} \; 2>/dev/null || echo "0")

        if [[ "$recent_errors" -gt 5 ]]; then
            echo "WARNING: High error rate detected in logs"
        fi
    fi

    return 0
}

# Check memory usage
check_memory() {
    local prosody_pid
    prosody_pid=$(pgrep -f "prosody" | head -n1)

    if [[ -n "$prosody_pid" ]]; then
        local memory_kb
        memory_kb=$(ps -o rss= -p "$prosody_pid" 2>/dev/null || echo "0")
        local memory_mb=$((memory_kb / 1024))

        # Warn if using more than 512MB
        if [[ "$memory_mb" -gt 512 ]]; then
            echo "WARNING: High memory usage: ${memory_mb}MB"
        fi
    fi

    return 0
}

# Check disk space
check_disk_space() {
    local data_usage
    data_usage=$(df "${PROSODY_DATA_DIR}" | awk 'NR==2 {print $5}' | sed 's/%//')

    if [[ "$data_usage" -gt 90 ]]; then
        echo "ERROR: Disk usage critical: ${data_usage}%"
        return 1
    elif [[ "$data_usage" -gt 80 ]]; then
        echo "WARNING: Disk usage high: ${data_usage}%"
    fi

    return 0
}

# Test XMPP connectivity
check_xmpp_connectivity() {
    # Simple TCP connection test to C2S port
    if command -v nc >/dev/null 2>&1; then
        if ! nc -z localhost 5222 2>/dev/null; then
            echo "ERROR: Cannot connect to XMPP C2S port"
            return 1
        fi
    fi

    return 0
}

# ============================================================================
# MAIN HEALTH CHECK
# ============================================================================

main() {
    local exit_code=0
    local warnings=0

    echo "=== Prosody Health Check ==="
    echo "Timestamp: $(date)"
    echo "Domain: ${PROSODY_DOMAIN}"
    echo "Storage: ${PROSODY_STORAGE:-sqlite}"
    echo ""

    # Run all health checks
    local checks=(
        "check_process:Process Check"
        "check_ports:Port Check"
        "check_config:Configuration Check"
        "check_certificates:Certificate Check"
        "check_database:Database Check"
        "check_logs:Log File Check"
        "check_log_errors:Log Error Check"
        "check_memory:Memory Check"
        "check_disk_space:Disk Space Check"
        "check_xmpp_connectivity:XMPP Connectivity Check"
    )

    for check in "${checks[@]}"; do
        local func_name="${check%%:*}"
        local check_name="${check##*:}"

        echo -n "[$check_name] "

        if $func_name; then
            echo "OK"
        else
            echo "FAILED"
            exit_code=1
        fi
    done

    echo ""

    # Summary
    if [[ $exit_code -eq 0 ]]; then
        echo "✓ Health check PASSED"
        if [[ $warnings -gt 0 ]]; then
            echo "  ($warnings warnings)"
        fi
    else
        echo "✗ Health check FAILED"
    fi

    return $exit_code
}

# ============================================================================
# SCRIPT EXECUTION
# ============================================================================

# Run main function
main "$@"
