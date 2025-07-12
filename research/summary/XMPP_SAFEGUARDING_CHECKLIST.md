# XMPP Safeguarding Manifesto 2025 - Compliance Checklist

Based on analysis of your current Prosody XMPP server configuration against the [2025 Safeguarding XMPP Manifesto](https://github.com/divestedcg/safeguarding-xmpp-2025).

## Legend

- ✅ **COMPLIANT** - Requirement is met
- ⚠️ **PARTIAL** - Partially implemented or needs verification
- ❌ **MISSING** - Requirement not met
- 🔧 **CONFIGURABLE** - Can be enabled via environment variables
- 📋 **MANUAL** - Requires manual configuration/verification

---

## 🖥️ SERVERS

### Abuse & Spam Control

| Requirement | Status | Current Implementation | Notes |
|-------------|--------|----------------------|-------|
| **Abuse contacts via XEP-0157** | ✅ | `server_contact_info` module + `contact_info` config | Admin, support, and abuse contacts configured |
| **Respond to reports in reasonable time** | 📋 | Manual process | Requires operational procedures |
| **Real-time JID blocklists (xmppbl.org)** | ❌ | Not configured | Could be added to firewall rules |
| **Long-term server blocklists (JabberSPAM)** | ⚠️ | Basic DNS blocklists in firewall | Has Spamhaus, SpamCop, SORBS but not JabberSPAM |

### Connections

| Requirement | Status | Current Implementation | Notes |
|-------------|--------|----------------------|-------|
| **Encryption required for all connections** | ✅ | `c2s_require_encryption = true`, `s2s_require_encryption = true` | ✅ |
| **Forward secrecy cipher suites** | ✅ | ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20 | ✅ |
| **TLS 1.3 support** | ❌ | `protocol = "tlsv1_2+"` | Need to update to support TLS 1.3 |
| **TLS 1.2 disable if unlikely to impact** | ⚠️ | TLS 1.2+ enabled | Could disable 1.2 for stricter security |
| **Legacy SSL/TLS disabled** | ✅ | `no_sslv2`, `no_sslv3`, `no_tlsv1`, `no_tlsv1_1` | ✅ |
| **S2S certificate enforcement** | ✅ | `s2s_secure_auth = true` | ✅ |
| **Channel binding available** | ❌ | Not configured | Need to add SASL channel binding |
| **STUN on non-standard ports** | ❌ | Not configured | No STUN services configured |
| **Stanza size limits enforced** | ❌ | Not explicitly configured | Need to add limits (recommended: 262,144 C2S, 524,288 S2S) |

### Miscellaneous

| Requirement | Status | Current Implementation | Notes |
|-------------|--------|----------------------|-------|
| **Strong password hashing** | ✅ | `authentication = "internal_hashed"` | ✅ |
| **Failed password attempt limits** | ✅ | `failed_auth_threshold = 5` in security config | ✅ |
| **IP blocking on failed attempts** | ⚠️ | Tracking enabled | Need to verify IP blocking implementation |
| **E2EE not made inoperable** | ✅ | No restrictions on OMEMO/OTR/PGP | ✅ |
| **HTTP Upload random paths** | 🔧 | Configurable when HTTP enabled | ✅ when enabled |
| **HTTP Upload no plain usernames** | 🔧 | Configurable when HTTP enabled | ✅ when enabled |

### Registration

| Requirement | Status | Current Implementation | Notes |
|-------------|--------|----------------------|-------|
| **Captcha for public registration** | ❌ | Not configured | Need captcha module |
| **Weak password rejection** | ❌ | Not configured | Need password policy module |
| **Disable public registration (recommended)** | ✅ | `allow_registration = false` by default | ✅ |
| **Invitation mechanisms (XEP-0401)** | ✅ | `invites`, `invites_adhoc`, `invites_register` modules | ✅ |
| **Registration rate limiting per IP** | ⚠️ | Basic rate limiting in firewall | 3 registrations/hour per IP |
| **Registration monitoring** | ✅ | `watchregistrations` module | ✅ |

---

## 🖥️ HOST SYSTEMS

### System Security

| Requirement | Status | Current Implementation | Notes |
|-------------|--------|----------------------|-------|
| **No password SSH, key-based auth** | 📋 | Manual host configuration | Requires host-level setup |
| **Multi-factor authentication** | 📋 | Manual host configuration | Requires host-level setup |
| **Password-protected keys** | 📋 | Manual host configuration | Requires host-level setup |
| **Systemd sandboxing** | ⚠️ | Docker containerization | Container provides isolation |
| **MAC confinement (SELinux)** | 📋 | Manual host configuration | Requires host-level setup |
| **Service isolation** | ✅ | Docker containers | Each service in own container |
| **Program allowlisting** | 📋 | Manual host configuration | Requires host-level setup |
| **Balanced logging** | ✅ | Configurable log levels | Privacy-conscious logging |
| **Secure Boot** | 📋 | Manual host configuration | Requires host-level setup |
| **Memory encryption** | 📋 | Manual host configuration | Requires host-level setup |
| **Disk encryption** | 📋 | Manual host configuration | Requires host-level setup |
| **No on-disk swap** | 📋 | Manual host configuration | Recommend ZRAM |
| **Multiple time sources** | 📋 | Manual host configuration | Requires host-level setup |

### System Updates

| Requirement | Status | Current Implementation | Notes |
|-------------|--------|----------------------|-------|
| **Non-EOL operating systems** | ✅ | Debian Bookworm (current) | ✅ |
| **Monthly system updates minimum** | 📋 | Manual operational procedure | Requires update schedule |
| **Frequent updates recommended** | 📋 | Manual operational procedure | Requires update schedule |
| **Restart after critical updates** | 📋 | Manual operational procedure | Requires update procedures |
| **Monthly full reboots** | 📋 | Manual operational procedure | Requires reboot schedule |
| **Service restarts after updates** | 📋 | Manual operational procedure | Docker makes this easier |

### System Firewall

| Requirement | Status | Current Implementation | Notes |
|-------------|--------|----------------------|-------|
| **Block malicious IPs** | ⚠️ | Basic DNS blocklists | Has some, could add more sources |
| **Consider CG-NAT/VPN impact** | ⚠️ | Basic implementation | Need to balance security vs accessibility |
| **Tor onion service option** | ❌ | Not configured | Could add for blocked IP users |
| **Use recommended IP lists** | ⚠️ | Partial implementation | Missing some recommended sources |

---

## 🌐 SUPPORTING INFRASTRUCTURE

### DNS

| Requirement | Status | Current Implementation | Notes |
|-------------|--------|----------------------|-------|
| **DNSSEC if supported by TLD** | 📋 | Manual DNS configuration | Requires DNS provider setup |
| **TLSA records for cert fingerprints** | 📋 | Manual DNS configuration | Requires DNS provider setup |

### PKI

| Requirement | Status | Current Implementation | Notes |
|-------------|--------|----------------------|-------|
| **CAA records present** | 📋 | Manual DNS configuration | Requires DNS provider setup |
| **CAA accounturi binding** | 📋 | Manual DNS configuration | Requires DNS provider setup |

---

## 📱 CLIENTS

*Note: These are recommendations for XMPP clients, not server configuration*

### Connections

| Requirement | Status | Server Support | Notes |
|-------------|--------|---------------|-------|
| **DNSSEC enforcement** | N/A | Server doesn't control | Client-side requirement |
| **TLSA record verification** | N/A | Server provides records | Client-side requirement |
| **Channel binding enforcement** | ⚠️ | Server should support | Need to add channel binding |
| **Robust reconnection** | N/A | Server supports | Client-side requirement |

### Messages

| Requirement | Status | Server Support | Notes |
|-------------|--------|---------------|-------|
| **E2EE support required** | ✅ | Server allows all E2EE | ✅ |
| **E2EE by default (1:1 and groups)** | N/A | Server doesn't control | Client-side requirement |

### Privacy

| Requirement | Status | Server Support | Notes |
|-------------|--------|---------------|-------|
| **JID disclosure warnings** | N/A | Server doesn't control | Client-side requirement |
| **No auto-download from strangers** | N/A | Server doesn't control | Client-side requirement |
| **No chat state to strangers** | N/A | Server doesn't control | Client-side requirement |
| **Non-public file storage** | N/A | Server doesn't control | Client-side requirement |
| **No call relay to strangers** | N/A | Server doesn't control | Client-side requirement |

---

## 📊 COMPLIANCE SUMMARY

### ✅ COMPLIANT (Strong): 15 items

- Encryption requirements
- Certificate security
- Authentication security
- E2EE support
- Registration controls
- Container isolation
- Modern XMPP features

### ⚠️ PARTIAL (Needs Attention): 12 items

- TLS 1.3 support
- Stanza size limits
- IP blocking verification
- Comprehensive blocklists
- Channel binding
- System-level security hardening

### ❌ MISSING (Critical): 8 items

- Real-time JID blocklists
- STUN services
- Captcha for registration
- Weak password rejection
- Tor onion service
- TLSA DNS records
- CAA DNS records

### 📋 MANUAL (Operational): 15 items

- Host system security
- Update procedures
- DNS configuration
- Monitoring procedures

---

## 🔧 IMMEDIATE ACTION ITEMS

### High Priority

1. **Add TLS 1.3 support** - Update SSL configuration
2. **Implement stanza size limits** - Add to prosody.cfg.lua
3. **Add channel binding** - Configure SASL channel binding
4. **Configure real-time blocklists** - Add xmppbl.org to firewall
5. **Set up DNS security** - Configure DNSSEC, TLSA, and CAA records

### Medium Priority

1. **Add captcha for registration** - Install captcha module
2. **Implement password policies** - Add password strength checking
3. **Expand IP blocklists** - Add more threat intelligence sources
4. **Document operational procedures** - Create update and monitoring procedures

### Low Priority

1. **Consider Tor onion service** - For users behind blocked IPs
2. **Enhance system hardening** - Implement additional host security measures

---

## 📝 CONFIGURATION RECOMMENDATIONS

### Immediate Config Changes Needed

```lua
-- Add to prosody.cfg.lua
ssl = {
    protocol = "tlsv1_3+";  -- Enable TLS 1.3
    -- ... existing config
}

-- Add stanza size limits
limits = {
    c2s = {
        stanza_size = 262144;  -- 256KB for C2S
        -- ... existing config
    };
    s2s = {
        stanza_size = 524288;  -- 512KB for S2S
        -- ... existing config
    };
}

-- Add channel binding
sasl_mechanisms = { "SCRAM-SHA-256-PLUS", "SCRAM-SHA-1-PLUS" };
```

### DNS Records to Add

```
; DNSSEC - enable at your DNS provider
; CAA records
example.com. CAA 0 issue "letsencrypt.org"
example.com. CAA 0 iodef "mailto:admin@example.com"

; TLSA records (generate after getting certificates)
_5222._tcp.example.com. TLSA 3 1 1 <certificate-hash>
_5269._tcp.example.com. TLSA 3 1 1 <certificate-hash>
```

This checklist shows you have a strong foundation with excellent security practices already in place. The main gaps are in some advanced security features and operational procedures rather than fundamental security flaws.
