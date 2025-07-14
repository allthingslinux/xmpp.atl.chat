# Systemd Service Templates

This directory contains systemd service and timer templates for automating XMPP server maintenance tasks.

## Certificate Renewal

The certificate renewal service automatically renews Let's Encrypt certificates using the configured renewal script.

### Files

- **`xmpp-cert-renewal.service`** - Systemd service that runs the certificate renewal script
- **`xmpp-cert-renewal.timer`** - Systemd timer that schedules daily certificate renewal checks

### Installation

These templates are automatically installed by the setup script (`scripts/setup.sh`). The setup script will:

1. Replace `PROJECT_DIR` with the actual project directory path
2. Replace `USER_NAME` with the current user
3. Install the files to `/etc/systemd/system/`
4. Enable and start the timer

### Manual Installation

If you need to install these manually:

```bash
# Replace placeholders in the service file
sed -e "s|PROJECT_DIR|/opt/xmpp.atl.chat|g" -e "s|USER_NAME|your-user|g" \
    examples/systemd/xmpp-cert-renewal.service | sudo tee /etc/systemd/system/xmpp-cert-renewal.service

# Copy the timer file
sudo cp examples/systemd/xmpp-cert-renewal.timer /etc/systemd/system/

# Enable and start the timer
sudo systemctl daemon-reload
sudo systemctl enable xmpp-cert-renewal.timer
sudo systemctl start xmpp-cert-renewal.timer
```

### Timer Schedule

The timer runs daily with a randomized delay of up to 1 hour to avoid load spikes. The `Persistent=true` setting ensures that if the system was down during the scheduled time, the service will run when the system comes back up.

### Checking Status

```bash
# Check timer status
systemctl status xmpp-cert-renewal.timer

# Check service logs
journalctl -u xmpp-cert-renewal.service

# List all timers
systemctl list-timers
```
