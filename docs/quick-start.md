# 🚀 Quick Start Guide

Get your XMPP server running in minutes with our unified configuration approach and `prosody-manager` CLI tool.

## 📋 Prerequisites

- Docker and Docker Compose
- Domain name with DNS control
- SSL certificate (Let's Encrypt recommended)
- Basic Linux command line knowledge

## ⚡ Fast Track Setup

### 1. Clone and Setup

```bash
git clone https://github.com/allthingslinux/xmpp.atl.chat.git
cd xmpp.atl.chat
./prosody-manager setup
```

### 2. Configure Environment

```bash
# Copy and edit environment file
cp templates/env/env.example .env
nano .env
```

**Required Environment Variables:**

```bash
DOMAIN=your-domain.com
ADMIN_EMAIL=admin@your-domain.com
MYSQL_ROOT_PASSWORD=secure_password
MYSQL_PASSWORD=prosody_password
```

### 3. Start Services

```bash
# Development
docker-compose -f docker-compose.dev.yml up -d

# Production
docker-compose up -d
```

### 4. Initialize with prosody-manager

```bash
# Make prosody-manager executable
chmod +x prosody-manager

# Run health check
./prosody-manager health

# Create admin user
./prosody-manager user create admin@your-domain.com --admin

# Install SSL certificate
./prosody-manager cert install
```

## 🔧 Essential Commands

### User Management

```bash
# Create user
./prosody-manager user create username@domain.com

# Delete user
./prosody-manager user delete username@domain.com

# List users
./prosody-manager user list
```

### Health Monitoring

```bash
# Full system check
./prosody-manager health

# Check specific component
./prosody-manager health --ports
./prosody-manager health --cert
./prosody-manager health --config
```

### Service Control

```bash
# Restart services
./prosody-manager deploy restart

# View logs
./prosody-manager deploy logs

# Check status
./prosody-manager deploy status
```

## 🌐 Access Your Server

After setup, you can access:

- **XMPP Server**: `your-domain.com:5222` (client connections)
- **Admin Panel**: `https://your-domain.com/admin/`
- **Web Registration**: `https://your-domain.com/register/`
- **Web Client**: `https://your-domain.com/webclient/`

## 🔍 Troubleshooting

### Common Issues

**Connection Problems:**

```bash
./prosody-manager health --ports
```

**Certificate Issues:**

```bash
./prosody-manager cert check
./prosody-manager cert renew
```

**Configuration Problems:**

```bash
./prosody-manager health --config
```

**View Detailed Logs:**

```bash
./prosody-manager deploy logs --follow
```

## 📚 Next Steps

- **Users**: See [User Guide](guides/users/user-guide.md)
- **Administrators**: See [Administration Guide](guides/administration/administration.md)
- **Developers**: See [Development Guide](guides/development/development-guide.md)
- **Deployment**: See [Deployment Guide](guides/deployment/deployment.md)

## 🆘 Getting Help

- Check the [Troubleshooting Guide](guides/troubleshooting/common-issues.md)
- Review [Configuration Reference](reference/configuration-reference.md)
- See [Module Documentation](reference/modules-reference.md)
- Join our community: `#allthingslinux@your-domain.com`

---

*This guide gets you running quickly. For detailed explanations and advanced configuration, see the comprehensive guides linked above.*
