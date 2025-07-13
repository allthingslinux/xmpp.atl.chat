# Prosody Logs Directory

This directory contains log files from the Prosody XMPP server.

## Log Files

```
logs/
├── prosody.log              # Main server log (info level)
├── prosody.err              # Error and warning log
├── security.log             # Security-related events
└── error.log                # System error log
```

## Log Levels

- **info**: General server operation information
- **warn**: Warning messages that don't stop operation
- **error**: Error messages requiring attention
- **debug**: Detailed debugging information (when enabled)

## Log Management

### Viewing Logs

```bash
# Follow all logs in real-time
tail -f logs/prosody.log

# Follow error logs only
tail -f logs/prosody.err

# Search for specific events
grep -i "authentication" logs/prosody.log
```

### Log Rotation

Docker Compose is configured with automatic log rotation:

- Maximum file size: 50MB
- Maximum files: 5
- Compression: enabled

### Log Level Configuration

Set log level via environment variable:

```bash
PROSODY_LOG_LEVEL=debug  # debug, info, warn, error
```

## Monitoring Integration

These logs can be integrated with:

- **Prometheus**: Via log-based metrics
- **ELK Stack**: For centralized logging
- **Grafana**: For log visualization
- **Alerting**: For error detection
