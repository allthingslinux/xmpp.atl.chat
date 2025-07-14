# 👥 Complete User Guide

Everything users need to know about using your XMPP server, from setup to advanced features.

## 📋 Table of Contents

1. [Getting Started](#-getting-started)
2. [Client Setup](#-client-setup)
3. [Core Features](#-core-features)
4. [File Sharing](#-file-sharing)
5. [Group Chats (MUC)](#-group-chats-muc)
6. [Message History](#-message-history)
7. [Advanced Features](#-advanced-features)
8. [Troubleshooting](#-troubleshooting)

## 🚀 Getting Started

### Account Registration

**Web Registration** (Easiest):

1. Visit `https://your-domain.com/register/`
2. Fill out the registration form
3. Complete CAPTCHA verification
4. Check email for confirmation (if enabled)

**Admin-Created Accounts**:

- Contact your server administrator
- Provide desired username and email
- Administrator will create account using `prosody-manager`

### First Login

1. **Download an XMPP client** (recommendations below)
2. **Configure connection**:
   - **Server**: `your-domain.com`
   - **Port**: `5222` (STARTTLS) or `5223` (Direct TLS)
   - **Username**: `yourname@your-domain.com`
   - **Password**: Your account password

## 📱 Client Setup

### Recommended XMPP Clients

**Mobile:**

- **Conversations** (Android) - Best overall experience
- **Siskin IM** (iOS) - Full-featured iOS client
- **Monal** (iOS) - Alternative iOS option

**Desktop:**

- **Gajim** (Windows/Linux/macOS) - Feature-rich
- **Dino** (Linux) - Modern, clean interface
- **Beagle IM** (macOS) - Native macOS client

**Web:**

- **Converse.js** - Available at `https://your-domain.com/webclient/`

### Connection Settings

| Setting | Value |
|---------|-------|
| **Server/Domain** | `your-domain.com` |
| **Port (STARTTLS)** | `5222` |
| **Port (Direct TLS)** | `5223` |
| **Encryption** | Required (STARTTLS or Direct TLS) |
| **Certificate** | Valid Let's Encrypt certificate |

### Advanced Connection Options

**For Power Users:**

- **BOSH URL**: `https://your-domain.com:5281/http-bind`
- **WebSocket URL**: `wss://your-domain.com:5281/xmpp-websocket`
- **Proxy65 (File Transfer)**: `proxy.your-domain.com:5000`

## 🔧 Core Features

### Basic Messaging

**Text Messages**:

- Send/receive instant messages
- Message delivery receipts
- Read receipts (if supported by client)
- Typing notifications

**Rich Text Support**:

- Markdown formatting (client-dependent)
- Emoji support 😊
- URL previews (client-dependent)

### Presence and Status

**Availability States**:

- **Available** - Online and ready to chat
- **Away** - Temporarily away
- **Do Not Disturb** - Busy, only urgent messages
- **Extended Away** - Away for extended period
- **Offline** - Not connected

**Custom Status Messages**:

- Set custom status text
- Share what you're working on
- Indicate your mood or activity

### Contact Management

**Adding Contacts**:

1. Use "Add Contact" in your client
2. Enter full JID: `username@domain.com`
3. Send subscription request
4. Wait for approval

**Contact Organization**:

- Create contact groups/categories
- Set custom contact names
- Block unwanted contacts

## 📤 File Sharing

### HTTP File Upload (XEP-0363)

**Supported File Types**:

- Images: JPG, PNG, GIF, WebP
- Documents: PDF, DOC, TXT, etc.
- Archives: ZIP, TAR, etc.
- Media: MP4, MP3, etc.

**Upload Limits**:

- **Maximum file size**: 100MB
- **Daily quota**: 1GB per user
- **Retention**: Files kept for 30 days

**How to Share Files**:

1. **In your client**: Click attach/upload button
2. **Select file** from your device
3. **File uploads** to server automatically
4. **Share link** sent to recipient
5. **Recipients click** to download

**Direct File Transfer**:

- Some clients support direct peer-to-peer transfer
- Uses SOCKS5 proxy for NAT traversal
- Faster for large files between online users

### File Upload Tips

**Best Practices**:

- Compress large files before uploading
- Use descriptive filenames
- Be mindful of daily quota limits
- Clean up old files regularly

**Privacy Notes**:

- Uploaded files are accessible via direct URL
- Files expire after 30 days automatically
- Administrators can see upload statistics

## 💬 Group Chats (MUC)

### Joining Group Chats

**Public Rooms**:

1. **Discover rooms**: Use service discovery in client
2. **Join room**: `roomname@conference.your-domain.com`
3. **Choose nickname**: Pick a display name for the room

**Private Rooms**:

- Invitation-only rooms
- Must be invited by room administrator
- Password-protected options available

### Room Features

**Standard Features**:

- Persistent rooms (stay active when empty)
- Message history for late joiners
- Room subject/topic setting
- Member-only or public rooms

**Moderation Features**:

- **Roles**: Visitor, Participant, Moderator
- **Affiliations**: None, Member, Admin, Owner
- **Actions**: Kick, Ban, Voice control
- **Room configuration**: Various settings

**Advanced Features**:

- Message Archive Management (MAM)
- Room logging and history
- File sharing in rooms
- Room avatars and descriptions

### Creating Your Own Room

1. **Join non-existent room**: `newroom@conference.your-domain.com`
2. **Become owner**: First to join becomes owner
3. **Configure room**: Set name, description, rules
4. **Invite members**: Add initial participants
5. **Set permissions**: Configure who can join/speak

## 📚 Message History

### Message Archive Management (MAM)

**Automatic Archiving**:

- All private messages archived by default
- Group chat messages archived per room settings
- Searchable message history
- Synchronized across all your devices

**Accessing History**:

- **New devices**: Automatically sync recent history
- **Search**: Find old messages by content
- **Date ranges**: Browse messages by time period
- **Export**: Some clients allow message export

**Privacy Controls**:

- **Retention period**: Messages kept for configured time
- **User control**: Can disable archiving for your account
- **Room control**: Room owners set archiving policy

### Offline Message Delivery

**How it Works**:

- Messages sent while offline are stored
- Delivered when you come back online
- Works across all your connected devices
- Ensures you never miss important messages

## 🔐 Advanced Features

### Multi-Device Support

**Device Synchronization**:

- **OMEMO encryption** keys sync across devices
- **Message history** available on all devices
- **Contact lists** synchronized automatically
- **Room memberships** shared across devices

**Managing Devices**:

- View connected devices in client settings
- Remove old/unused device keys
- Trust new devices for encryption

### End-to-End Encryption (OMEMO)

**What is OMEMO**:

- Signal Protocol for XMPP
- End-to-end encryption for messages
- Forward secrecy and deniability
- Works in both private chats and groups

**Setting Up OMEMO**:

1. **Enable in client**: Turn on OMEMO in settings
2. **Generate keys**: Client creates encryption keys
3. **Trust contacts**: Verify contact key fingerprints
4. **Encrypted messaging**: Messages automatically encrypted

**Key Management**:

- **Fingerprint verification**: Compare key fingerprints
- **Trust on first use**: Simple trust model
- **Key rotation**: Keys change periodically for security

### Push Notifications

**Mobile Push Support**:

- Receive notifications when offline
- Battery-efficient implementation
- Works with device sleep modes
- Configurable notification preferences

**Setup Requirements**:

- Compatible mobile client
- Proper server configuration
- Push service registration

### Service Discovery

**Finding Services**:

- Discover available server features
- Find public group chat rooms
- Locate file upload services
- Browse server components

**Using Discovery**:

1. **Client menu**: Look for "Service Discovery"
2. **Browse services**: Explore available features
3. **Join services**: Connect to discovered rooms/services

## 🔍 Troubleshooting

### Connection Issues

**Cannot Connect**:

1. **Check server address**: Ensure correct domain
2. **Verify ports**: Try both 5222 and 5223
3. **Test connectivity**: Use web client to test
4. **Check firewall**: Ensure ports aren't blocked

**Certificate Errors**:

- Update your client to latest version
- Check if certificate has expired
- Try different connection method (STARTTLS vs Direct TLS)

**Login Failures**:

- Verify username format: `user@domain.com`
- Check password (passwords are case-sensitive)
- Contact administrator if account locked

### Message Delivery Issues

**Messages Not Delivered**:

1. **Check recipient status**: Are they online?
2. **Verify JID**: Ensure correct recipient address
3. **Network issues**: Check your internet connection
4. **Server issues**: Contact administrator

**Missing Message History**:

- Enable Message Archive Management in client
- Check client history settings
- Verify server supports MAM (XEP-0313)

### File Upload Problems

**Upload Failures**:

- Check file size (max 100MB)
- Verify daily quota not exceeded
- Ensure stable internet connection
- Try different file format

**Download Issues**:

- Check if file has expired (30 day limit)
- Verify file URL is accessible
- Try downloading from web browser

### Group Chat Issues

**Cannot Join Room**:

- Verify room address format
- Check if room requires password
- Ensure you're not banned from room
- Contact room administrator

**Missing Messages in Rooms**:

- Check room history settings
- Verify you have appropriate permissions
- Ensure client supports room features

## 🆘 Getting Help

### Support Resources

**Documentation**:

- [Admin Guide](../administration/complete-admin-guide.md) - For server administrators
- [Configuration Reference](../../reference/configuration-reference.md) - Technical details
- [XEP Compliance](../../reference/xep-compliance.md) - Supported standards

**Community Support**:

- Join `#support@your-domain.com` for help
- Contact server administrator
- Check client-specific documentation

**Technical Support**:

- Report server issues to administrator
- Check server status page (if available)
- Review client logs for error details

### Common Error Messages

**"Authentication failed"**:

- Check username and password
- Verify account exists and is active
- Contact administrator if account locked

**"Server not found"**:

- Check internet connection
- Verify server domain is correct
- Try alternative connection methods

**"Certificate error"**:

- Update client to latest version
- Check system date/time is correct
- Contact administrator about certificate issues

**"Resource conflict"**:

- Another device using same resource
- Change resource name in client settings
- Log out from other devices

---

*This guide covers the most common user scenarios. For technical details or advanced configuration, see the administrator documentation.*
