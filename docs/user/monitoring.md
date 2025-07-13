# 📊 Monitoring & Metrics (OpenMetrics/Prometheus)

This guide covers the monitoring and metrics capabilities of your Prosody XMPP server using OpenMetrics (Prometheus) integration via `mod_http_openmetrics`.

## 📋 Overview

Your XMPP server exports comprehensive metrics in OpenMetrics format, compatible with:

- **Prometheus** - Time-series database and monitoring system
- **Grafana** - Visualization and dashboarding
- **VictoriaMetrics** - High-performance time-series database
- **Any OpenMetrics-compatible monitoring system**

## ⚙️ Configuration

All monitoring settings are configured via environment variables in your `.env` file.

### Basic Setup

The monitoring system is enabled by default with secure access controls:

```bash
# Default: Optimized for single Prometheus instance
PROSODY_STATISTICS_INTERVAL=manual

# Metrics endpoint: http://your-domain:5280/metrics
# Access restricted to localhost (127.0.0.1, ::1) by default
```

### Access Control

**Allow specific monitoring servers:**

```bash
# Comma-separated list of IP addresses
PROSODY_METRICS_ALLOW_IPS=192.168.1.100,10.0.0.50
```

**Allow monitoring networks:**

```bash
# CIDR notation for network ranges
PROSODY_METRICS_ALLOW_CIDR=192.168.1.0/24
```

### Statistics Interval

**Single Prometheus instance (recommended):**

```bash
# Use "manual" for optimal performance
PROSODY_STATISTICS_INTERVAL=manual
```

**Multiple Prometheus instances:**

```bash
# Use your scrape interval (in seconds)
PROSODY_STATISTICS_INTERVAL=30
```

## 🔧 Prometheus Configuration

### Scrape Configuration

Add this to your Prometheus `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: "prosody-xmpp"
    metrics_path: "/metrics"
    scheme: "http"
    scrape_interval: 30s
    scrape_timeout: 10s
    
    static_configs:
      - targets: ["xmpp.atl.chat:5280"]
        labels:
          service: "prosody"
          environment: "production"
          instance_type: "xmpp_server"
          domain: "atl.chat"
```

### Complete Example

See `examples/prometheus-scrape-config.yml` for a complete configuration including:

- Prosody XMPP server metrics
- PostgreSQL database metrics (optional)
- System metrics integration

## 📈 Available Metrics

### Connection Metrics

| Metric | Description | Type |
|--------|-------------|------|
| `prosody_c2s_connections_total` | Client connections | Counter |
| `prosody_s2s_connections_total` | Server-to-server connections | Counter |
| `prosody_c2s_auth_success_total` | Successful authentications | Counter |
| `prosody_c2s_auth_failure_total` | Failed authentications | Counter |

### Message Metrics

| Metric | Description | Type |
|--------|-------------|------|
| `prosody_messages_sent_total` | Messages sent | Counter |
| `prosody_messages_received_total` | Messages received | Counter |
| `prosody_presence_sent_total` | Presence updates sent | Counter |
| `prosody_presence_received_total` | Presence updates received | Counter |

### Storage Metrics

| Metric | Description | Type |
|--------|-------------|------|
| `prosody_storage_operations_total` | Database operations | Counter |
| `prosody_storage_errors_total` | Storage errors | Counter |
| `prosody_archive_query_total` | Message archive queries | Counter |

### HTTP Metrics

| Metric | Description | Type |
|--------|-------------|------|
| `prosody_http_requests_total` | HTTP requests (BOSH/WebSocket) | Counter |
| `prosody_http_request_duration_seconds` | HTTP request duration | Histogram |
| `prosody_websocket_connections_total` | WebSocket connections | Counter |

### System Metrics

| Metric | Description | Type |
|--------|-------------|------|
| `prosody_memory_usage_bytes` | Memory usage | Gauge |
| `prosody_cpu_usage_seconds_total` | CPU usage | Counter |
| `prosody_uptime_seconds` | Server uptime | Gauge |

### Module-Specific Metrics

| Metric | Description | Type |
|--------|-------------|------|
| `prosody_muc_rooms_total` | Active MUC rooms | Gauge |
| `prosody_muc_participants_total` | MUC participants | Gauge |
| `prosody_file_uploads_total` | File uploads | Counter |
| `prosody_file_upload_bytes_total` | File upload bytes | Counter |

## 🎯 Key Performance Indicators (KPIs)

### Server Health

```promql
# Server uptime
prosody_uptime_seconds

# Memory usage percentage
(prosody_memory_usage_bytes / node_memory_MemTotal_bytes) * 100

# Authentication success rate
rate(prosody_c2s_auth_success_total[5m]) / 
(rate(prosody_c2s_auth_success_total[5m]) + rate(prosody_c2s_auth_failure_total[5m])) * 100
```

### User Activity

```promql
# Active connections
prosody_c2s_connections_total

# Message throughput (messages per second)
rate(prosody_messages_sent_total[5m])

# User engagement (presence updates per second)
rate(prosody_presence_sent_total[5m])
```

### Service Performance

```promql
# HTTP request latency (95th percentile)
histogram_quantile(0.95, rate(prosody_http_request_duration_seconds_bucket[5m]))

# Storage operation rate
rate(prosody_storage_operations_total[5m])

# Error rate
rate(prosody_storage_errors_total[5m])
```

## 📊 Grafana Dashboards

### Dashboard Recommendations

**1. XMPP Server Overview:**

- Connection counts and trends
- Message throughput
- Authentication metrics
- System resource usage

**2. User Activity Dashboard:**

- Active users over time
- Message volume by hour/day
- Popular MUC rooms
- File upload statistics

**3. Performance Dashboard:**

- Response times and latency
- Database performance
- Error rates and alerts
- Resource utilization

### Sample Grafana Queries

**Active Users (last 24h):**

```promql
max_over_time(prosody_c2s_connections_total[24h])
```

**Message Rate (per minute):**

```promql
rate(prosody_messages_sent_total[1m]) * 60
```

**Storage Performance:**

```promql
rate(prosody_storage_operations_total[5m])
```

## 🚨 Alerting Rules

### Critical Alerts

**Server Down:**

```yaml
- alert: ProsodyDown
  expr: up{job="prosody-xmpp"} == 0
  for: 1m
  labels:
    severity: critical
  annotations:
    summary: "Prosody XMPP server is down"
```

**High Memory Usage:**

```yaml
- alert: ProsodyHighMemory
  expr: (prosody_memory_usage_bytes / node_memory_MemTotal_bytes) * 100 > 80
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Prosody memory usage is above 80%"
```

**Authentication Failures:**

```yaml
- alert: ProsodyAuthFailures
  expr: rate(prosody_c2s_auth_failure_total[5m]) > 10
  for: 2m
  labels:
    severity: warning
  annotations:
    summary: "High authentication failure rate"
```

### Warning Alerts

**Storage Errors:**

```yaml
- alert: ProsodyStorageErrors
  expr: rate(prosody_storage_errors_total[5m]) > 1
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Storage errors detected"
```

**High HTTP Latency:**

```yaml
- alert: ProsodyHighLatency
  expr: histogram_quantile(0.95, rate(prosody_http_request_duration_seconds_bucket[5m])) > 1
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High HTTP request latency"
```

## 🔒 Security Considerations

### Access Control

**Default Security:**

- Metrics endpoint restricted to localhost (`127.0.0.1`, `::1`)
- No authentication required for localhost access
- External access requires explicit IP allowlisting

**Production Security:**

```bash
# Only allow monitoring servers
PROSODY_METRICS_ALLOW_IPS=192.168.1.100

# Or use network ranges
PROSODY_METRICS_ALLOW_CIDR=10.0.0.0/8
```

### Reverse Proxy Protection

If using a reverse proxy, ensure it adds `X-Forwarded-For` headers:

```nginx
# Nginx example
location /metrics {
    proxy_pass http://prosody:5280/metrics;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    
    # Restrict access
    allow 192.168.1.0/24;
    deny all;
}
```

### Sensitive Data

The metrics endpoint may expose:

- **Connection counts** (user activity patterns)
- **Domain names** (server federation info)
- **Performance data** (potential DoS indicators)

**Mitigation:**

- Use network-level access controls
- Monitor access to the metrics endpoint
- Consider VPN access for external monitoring

## 🛠️ Troubleshooting

### Common Issues

**Metrics endpoint not accessible:**

1. **Check access control:**

   ```bash
   # Test from localhost
   curl http://localhost:5280/metrics
   
   # Test from remote (should fail if not configured)
   curl http://your-server:5280/metrics
   ```

2. **Verify configuration:**

   ```bash
   docker compose logs prosody | grep -i metrics
   ```

3. **Check firewall:**

   ```bash
   # Ensure port 5280 is accessible
   netstat -tlnp | grep 5280
   ```

**No metrics data:**

1. **Verify statistics are enabled:**

   ```bash
   docker compose exec prosody prosodyctl check config
   ```

2. **Check module loading:**

   ```bash
   docker compose logs prosody | grep http_openmetrics
   ```

3. **Test statistics collection:**

   ```bash
   # Should show non-zero values after some activity
   curl http://localhost:5280/metrics | grep prosody_c2s_connections
   ```

**Prometheus scraping failures:**

1. **Check Prometheus logs:**

   ```bash
   # Look for scrape errors
   grep "prosody-xmpp" /var/log/prometheus/prometheus.log
   ```

2. **Verify network connectivity:**

   ```bash
   # From Prometheus server
   telnet your-xmpp-server 5280
   ```

3. **Test manual scrape:**

   ```bash
   # From Prometheus server
   curl http://your-xmpp-server:5280/metrics
   ```

### Debug Commands

**Check metrics endpoint:**

```bash
# Basic connectivity
curl -v http://localhost:5280/metrics

# Check specific metrics
curl -s http://localhost:5280/metrics | grep prosody_uptime

# Monitor metrics in real-time
watch -n 5 'curl -s http://localhost:5280/metrics | grep prosody_c2s_connections'
```

**Verify statistics collection:**

```bash
# Check statistics interval
docker compose exec prosody prosodyctl check config | grep statistics

# Check module status
docker compose exec prosody prosodyctl check modules
```

## 📖 Standards Compliance

This implementation follows:

- **OpenMetrics Specification** - Standard metrics format
- **Prometheus Exposition Format** - Compatible with Prometheus ecosystem
- **HTTP Security Best Practices** - Access control and headers

## 🎯 Best Practices

### Configuration

- **Use "manual" statistics interval** for single Prometheus instance
- **Set appropriate scrape intervals** (15-60 seconds recommended)
- **Implement proper access controls** for metrics endpoint
- **Monitor the monitoring system** itself

### Alerting

- **Start with critical alerts** (server down, high resource usage)
- **Add business-specific alerts** (user activity, message volume)
- **Avoid alert fatigue** with appropriate thresholds
- **Test alert delivery** regularly

### Performance

- **Limit metrics retention** based on storage capacity
- **Use recording rules** for complex queries
- **Optimize dashboard queries** to reduce load
- **Monitor Prometheus performance** itself

## 🔗 Related Documentation

- [Prometheus Configuration](https://prometheus.io/docs/prometheus/latest/configuration/)
- [Grafana Dashboard Creation](https://grafana.com/docs/grafana/latest/dashboards/)
- [OpenMetrics Specification](https://openmetrics.io/)
- [Prosody Statistics Module](https://prosody.im/doc/statistics)

## 🆘 Support

If you encounter monitoring issues:

1. **Check server logs** for configuration errors
2. **Verify network connectivity** between monitoring components
3. **Test metrics endpoint** manually with curl
4. **Review Prometheus targets** in the web UI
5. **Contact support** with specific error messages and logs
