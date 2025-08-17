#!/usr/bin/env bash
set -euo pipefail

TERMINATE=false

on_term() {
	TERMINATE=true
}

trap on_term TERM INT

CERT_CHECK_INTERVAL="${CERT_CHECK_INTERVAL:-3600}"

while true; do
	/app/scripts/certificate-monitor.sh monitor || true
	# Sleep in an interruptible way so TERM breaks promptly
	SECONDS_TO_SLEEP="$CERT_CHECK_INTERVAL"
	while [ "$SECONDS_TO_SLEEP" -gt 0 ]; do
		if [ "$TERMINATE" = "true" ]; then
			exit 0
		fi
		sleep 1 || true
		SECONDS_TO_SLEEP=$((SECONDS_TO_SLEEP - 1))
	done
	if [ "$TERMINATE" = "true" ]; then
		exit 0
	fi
done


