# Prosody HTTP Services Guide

This document outlines all HTTP services and endpoints available in your Prosody XMPP server configuration.

## 🌐 HTTP Server Configuration

### **Core HTTP Server**

- **HTTP Port**: 5280 (localhost only for security)
- **HTTPS Port**: 5281 (all interfaces for public access)
- **SSL/TLS**: Automatic certificate discovery (Prosody 0.12+)
- **Security Headers**: Full security headers enabled (HSTS, CSP, etc.)

## 📁 Available HTTP Endpoints

### **Web Administration**

- **Admin Interface**: `https://yourdomain.com:5281/admin`
  - Web-based server administration
  - Module management, user management
  - Real-time server statistics
  
- **Admin REST API**: `https://yourdomain.com:5281/rest`
  - RESTful API for server administration
  - Programmatic server management
  - User and module management via API

### **File Upload & Sharing**

- **File Upload**: `https://upload.yourdomain.com:5281/upload`
  - **XEP-0363: HTTP File Upload** implementation
  - **Limits**: 50-100MB per file, 100MB-1GB daily quota
  - **Security**: File type restrictions, virus scanning hooks
  - **Cleanup**: Automatic expiration (7-30 days)

### **Web Client Connectivity**

- **BOSH Endpoint**: `https://yourdomain.com:5281/http-bind`
  - **XEP-0124: BOSH** (legacy web clients)
  - HTTP long-polling for XMPP connections
  
- **WebSocket Endpoint**: `wss://yourdomain.com:5281/xmpp-websocket`
  - **RFC 7395: WebSocket XMPP Subprotocol**
  - Modern real-time web client connectivity
  - Lower latency than BOSH

### **Monitoring & Metrics**

- **Health Check**: `https://yourdomain.com:5281/api/health`
  - Server health status for load balancers
  - No authentication required
  
- **Prometheus Metrics**: `https://yourdomain.com:5281/metrics`
  - **OpenMetrics format** for monitoring
  - Authentication required
  - Integration with Grafana dashboards

### **Static File Serving**

- **Static Files**: `https://yourdomain.com:5281/files`
  - Static file serving capability
  - Customizable document root

## 🔧 Component Services

### **Multi-User Chat (MUC)**

- **Domain**: `conference.yourdomain.com`
- **HTTP Archive**: Access to chat history via HTTP
- **Room Management**: Web-based room administration

### **Publish-Subscribe (PubSub)**

- **Domain**: `pubsub.yourdomain.com`
- **HTTP Publishing**: Publish to PubSub nodes via HTTP
- **Subscription Management**: Web-based subscription management

### **SOCKS5 Proxy**

- **Domain**: `proxy.yourdomain.com`
- **Purpose**: File transfer proxy for XMPP clients
- **Protocol**: SOCKS5 Bytestreams (XEP-0065)

## 🔐 Security Features

### **Authentication**

- **Web Admin**: Admin user credentials required
- **REST API**: Token-based authentication
- **File Upload**: User authentication required
- **Metrics**: Admin authentication required

### **CORS Configuration**

- **File Upload**: CORS enabled for web clients
- **BOSH/WebSocket**: CORS disabled for security
- **Admin Interface**: Same-origin policy enforced

### **Rate Limiting**

- **File Upload**: 10MB/minute per user
- **API Endpoints**: Custom rate limits per endpoint
- **Global Limits**: Connection and bandwidth limits

## 🚀 Getting Started

### **Accessing Web Admin**

1. Navigate to: `https://yourdomain.com:5281/admin`
2. Log in with admin credentials
3. Manage users, modules, and server settings

### **Using File Upload**

1. Configure XMPP client with upload domain: `upload.yourdomain.com`
2. Upload files up to 100MB
3. Files automatically expire after 30 days

### **Connecting Web Clients**

- **Modern clients**: Use WebSocket endpoint
- **Legacy clients**: Use BOSH endpoint
- **URL format**: Include domain and port in client configuration

## 📊 Monitoring Integration

### **Prometheus Metrics**

- **Endpoint**: `/metrics`
- **Format**: OpenMetrics
- **Metrics**: Connection counts, message rates, error rates, memory usage

### **Grafana Dashboard**

- Pre-configured dashboards available
- Real-time monitoring of all services
- Alerting on critical metrics

## 🛠️ Configuration Files

- **HTTP Configuration**: `config/stack/07-interfaces/http.cfg.lua`
- **Upload Configuration**: `config/domains/upload/domain.cfg.lua`
- **Security Policies**: `config/domains/upload/policies.cfg.lua`
- **Monitoring Config**: `docker/docker-compose.monitoring.yml`

## 🔧 Advanced Features

### **Reverse Proxy Support**

- **Trusted Proxies**: Configured for X-Forwarded-For headers
- **SSL Termination**: Support for external SSL termination
- **Load Balancing**: Health check endpoint for load balancers

### **External Service Discovery**

- **XEP-0156**: Alternative connection methods
- **Service Discovery**: Automatic client configuration
- **TURN/STUN Integration**: WebRTC support configured

## 📝 Notes

- All HTTP services are enabled and ready for production use
- Web admin interface requires explicit admin user creation
- File upload component uses enhanced Prosody 13.0+ permissions
- CORS policies are security-focused by default
- All endpoints support both HTTP and HTTPS (HTTPS recommended)

For detailed configuration changes, see the layer-based configuration in `config/stack/07-interfaces/http.cfg.lua`.
