-- ===============================================
-- SECURITY (limits, registration, firewall)
-- ===============================================

limits = {
	c2s = { rate = "10kb/s", burst = "25kb", stanza_size = 1024 * 256 },
	s2s = { rate = "30kb/s", burst = "100kb", stanza_size = 1024 * 512 },
	http_upload = { rate = "2mb/s", burst = "10mb" },
}

max_connections_per_ip = 5

allow_registration = false
registration_throttle_max = 3
registration_throttle_period = 3600

-- Inline firewall rules for mod_firewall
firewall_rules = [=[
%ZONE spam: log=debug
RATE: 10 (burst 15) on full-jid
TO: spam
DROP.

%LENGTH > 262144
BOUNCE: policy-violation (Stanza too large)
]=]
