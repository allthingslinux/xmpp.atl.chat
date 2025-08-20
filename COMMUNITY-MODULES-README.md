# Prosody Community Modules Setup

This project uses a local-first approach to managing Prosody community modules to avoid rate limiting and network issues during Docker builds.

## 🏗️ How It Works

1. **Local Cache**: We maintain a local cache of community modules (`prosody-modules-cache/`)
2. **Selective Enable**: Only enabled modules are symlinked and copied into Docker builds
3. **No Network During Build**: Docker builds are completely offline for module installation
4. **Easy Updates**: Update the cache locally when needed

## 🚀 Quick Setup

### 1. Download All Modules Locally (One Time)
```bash
./scripts/setup-modules-locally.sh
```

This will:
- Clone/update the prosody-modules repository to `prosody-modules-cache/source/`
- Create symlinks for default modules in `prosody-modules-cache/enabled/`

### 2. Customize Enabled Modules (Optional)
```bash
# Add more modules
ln -s ../source/mod_new_module prosody-modules-cache/enabled/mod_new_module

# Remove modules
rm prosody-modules-cache/enabled/mod_unwanted_module
```

### 3. Build Docker Image
```bash
make dev-up  # or prod-up
```

The Docker build will automatically copy the enabled modules from your local cache.

## 📦 Default Enabled Modules

The following modules are enabled by default:

- `mod_cloud_notify` - Push notifications
- `mod_cloud_notify_extensions` - iOS push notifications
- `mod_muc_notifications` - Group chat notifications
- `mod_muc_offline_delivery` - Offline group messages
- `mod_http_status` - Status endpoint for monitoring
- `mod_admin_web` - Web-based administration interface
- `mod_compliance_latest` - XEP compliance testing

## ⚙️ Custom Configuration

### Environment Variable Override
Set `PROSODY_EXTRA_MODULES` to override the default list:
```bash
PROSODY_EXTRA_MODULES="mod_cloud_notify,mod_http_status,mod_admin_web"
```

### Manual Module Management
You can manually manage which modules are enabled by editing the symlinks in `prosody-modules-cache/enabled/`.

## 🔄 Updating Modules

When you want to update the community modules:

```bash
# Update the local repository
cd prosody-modules-cache/source
hg pull -u

# Rebuild Docker image
make dev-down && make dev-up
```

## 📁 Directory Structure

```
community-modules/
├── source/           # Full prosody-modules repository
└── enabled/          # Symlinks to enabled modules (copied to Docker)
```

## 🐳 Docker Integration

The `Dockerfile` automatically:
1. Copies `community-modules/enabled/` to `/usr/local/lib/prosody/community-modules/enabled/`
2. Sets `plugin_paths` to include the enabled modules directory
3. Makes modules available to Prosody at runtime

## 🛠️ Troubleshooting

### Modules Not Found
1. Run `./scripts/setup-modules-locally.sh` to set up the local cache
2. Rebuild Docker image: `make dev-down && make dev-up`

### New Modules Not Available
1. Check if the module exists: `ls prosody-modules-cache/source/`
2. Enable it: `ln -s ../source/mod_new_module prosody-modules-cache/enabled/mod_new_module`
3. Rebuild Docker image

### Rate Limiting Issues
This approach eliminates rate limiting since all downloads happen locally, not during Docker builds.
