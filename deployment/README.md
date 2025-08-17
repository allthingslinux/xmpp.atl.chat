# Cloudflared (Cloudflare Tunnel) integration

Cloudflared can proxy HTTP(S) endpoints like WebSocket and BOSH so you can hide your origin IP. Native XMPP TCP ports (5222/5269/5223/5270) require Cloudflare Spectrum (paid). This stack exposes:

- https://$PROSODY_DOMAIN/xmpp-websocket → `xmpp-prosody:5280`
- https://$PROSODY_DOMAIN/http-bind → `xmpp-prosody:5280`

Setup:

1) Create a tunnel and credentials on your workstation:
   - `cloudflared tunnel create xmpp-tunnel`
   - `cloudflared tunnel route dns xmpp-tunnel $PROSODY_DOMAIN`
   - Copy `~/.cloudflared/<TUNNEL_ID>.json` to `./.runtime/cloudflared/`
   - Set `CLOUDFLARE_TUNNEL_ID=<TUNNEL_ID>` in `.env`

2) Config file:
   - Copy `deployment/cloudflared/config.yml.example` to `deployment/cloudflared/config.yml`
   - Adjust hostnames and paths if needed

3) Run:
   - `docker compose up -d cloudflared`

Notes:
- For native XMPP ports via Cloudflare, enable Spectrum and add TCP mappings for 5222/5269.

