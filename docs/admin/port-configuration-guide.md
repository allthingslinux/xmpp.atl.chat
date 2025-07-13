# Port Configuration Guide: Avoid Specifying Ports

This guide shows you **3 ways** to access Prosody's web services without specifying ports (like `https://yourdomain.com/admin` instead of `https://yourdomain.com:5281/admin`).

## 🎯 **Current Setup vs Goal**

**Current:** Access with ports  

- Admin Panel: `https://yourdomain.com:5281/admin`
- Metrics: `https://yourdomain.com:5281/metrics`
- File Upload: `https://yourdomain.com:5281/upload`

**Goal:** Access without ports  

- Admin Panel: `https://yourdomain.com/admin`
- Metrics: `https://yourdomain.com/metrics`
- File Upload: `https://yourdomain.com/upload`

## 🔧 **Option 1: Docker Port Mapping (Recommended)**

**Pros:** ✅ Simplest setup, ✅ No additional containers, ✅ Works immediately  
**Cons:** ⚠️ Uses ports 80/443 on host (can't run other web servers)

### **Implementation:**

1. **Edit your `.env` file:**

```bash
# Change these lines in your .env file:
PROSODY_HTTP_PORT=80
PROSODY_HTTPS_PORT=443
```

2. **Restart containers:**

```bash
docker-compose down && docker-compose up -d
```

3. **Access services:**

- ✅ Admin Panel: `https://yourdomain.com/admin`
- ✅ Metrics: `https://yourdomain.com/metrics`
- ✅ File Upload: `https://yourdomain.com/upload`
- ✅ WebSocket: `wss://yourdomain.com/xmpp-websocket`

**Note:** Requires ports 80/443 to be available on your host.

---

## 🌐 **Option 2: nginx Reverse Proxy (Production)**

**Pros:** ✅ Production-ready, ✅ Can run other web services, ✅ Better caching, ✅ Load balancing  
**Cons:** ⚠️ Additional container, ⚠️ More complex configuration

### **Implementation:**

1. **Create nginx configuration:**

```bash
# Use the provided nginx example
cp examples/nginx-websocket.conf /etc/nginx/sites-available/prosody
```

2. **Add nginx to docker-compose:**

```yaml
# Add this to your docker-compose.yml
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./examples/nginx-websocket.conf:/etc/nginx/conf.d/default.conf:ro
      - prosody_certs:/etc/nginx/ssl:ro
    depends_on:
      - prosody
    restart: unless-stopped
```

3. **Update your domain configuration:**

```bash
# In your .env file, keep default Prosody ports:
PROSODY_HTTP_PORT=5280
PROSODY_HTTPS_PORT=5281
```

4. **Access services through nginx:**

- ✅ Admin Panel: `https://yourdomain.com/admin`
- ✅ Metrics: `https://yourdomain.com/metrics`
- ✅ All services routed through nginx

---

## ⚙️ **Option 3: Alternative Ports (Fallback)**

**Pros:** ✅ Doesn't conflict with other services, ✅ Easy to remember  
**Cons:** ⚠️ Still requires port specification (but shorter)

### **Implementation:**

1. **Use common web ports:**

```bash
# In your .env file:
PROSODY_HTTP_PORT=8080
PROSODY_HTTPS_PORT=8443
```

2. **Access with shorter ports:**

- Admin Panel: `https://yourdomain.com:8443/admin`
- Metrics: `https://yourdomain.com:8443/metrics`

---

## 🚀 **Quick Setup for Each Option**

### **Option 1: Standard Ports (Fastest)**

```bash
# Edit .env file
sed -i 's/PROSODY_HTTP_PORT=5280/PROSODY_HTTP_PORT=80/' .env
sed -i 's/PROSODY_HTTPS_PORT=5281/PROSODY_HTTPS_PORT=443/' .env

# Restart
docker-compose down && docker-compose up -d

# Test
curl -k https://yourdomain.com/admin
```

### **Option 2: nginx Proxy (Production)**

```bash
# Enable nginx profile
echo "COMPOSE_PROFILES=nginx" >> .env

# Start with nginx
docker-compose --profile nginx up -d

# Test through nginx
curl -k https://yourdomain.com/admin
```

### **Option 3: Alternative Ports (Fallback)**

```bash
# Edit .env file  
sed -i 's/PROSODY_HTTP_PORT=5280/PROSODY_HTTP_PORT=8080/' .env
sed -i 's/PROSODY_HTTPS_PORT=5281/PROSODY_HTTPS_PORT=8443/' .env

# Restart
docker-compose down && docker-compose up -d

# Test
curl -k https://yourdomain.com:8443/admin
```

---

## 📋 **Service Endpoint Summary**

| Service | Default URL | Option 1 (Port 443) | Option 2 (nginx) | Option 3 (Port 8443) |
|---------|-------------|----------------------|-------------------|----------------------|
| **Admin Panel** | `:5281/admin` | `/admin` | `/admin` | `:8443/admin` |
| **Metrics** | `:5281/metrics` | `/metrics` | `/metrics` | `:8443/metrics` |
| **File Upload** | `:5281/upload` | `/upload` | `/upload` | `:8443/upload` |
| **WebSocket** | `:5281/xmpp-websocket` | `/xmpp-websocket` | `/xmpp-websocket` | `:8443/xmpp-websocket` |
| **BOSH** | `:5281/http-bind` | `/http-bind` | `/http-bind` | `:8443/http-bind` |
| **Health Check** | `:5281/health` | `/health` | `/health` | `:8443/health` |

---

## 🔐 **Security Considerations**

### **Option 1 (Standard Ports)**

- ✅ Direct HTTPS encryption
- ⚠️ Exposes Prosody directly
- ✅ Built-in security headers enabled

### **Option 2 (nginx Proxy)**  

- ✅ nginx security features
- ✅ Rate limiting at nginx level
- ✅ Hide Prosody version information
- ✅ DDoS protection

### **Option 3 (Alternative Ports)**

- ✅ Same as Option 1
- ✅ Doesn't conflict with other services

---

## 📊 **Performance Comparison**

| Metric | Option 1 (Direct) | Option 2 (nginx) | Option 3 (Alt Ports) |
|--------|-------------------|-------------------|----------------------|
| **Latency** | Lowest | +1-2ms | Lowest |
| **Throughput** | Highest | High | Highest |
| **Memory** | 100MB | 110MB | 100MB |
| **Complexity** | Simple | Medium | Simple |
| **Scalability** | Good | Excellent | Good |

---

## 💡 **Recommendations**

- **Development:** Use **Option 1** (standard ports) - simplest setup
- **Production:** Use **Option 2** (nginx proxy) - better security and features  
- **Multi-service host:** Use **Option 3** (alternative ports) - avoids conflicts

Choose based on your needs and infrastructure setup!
