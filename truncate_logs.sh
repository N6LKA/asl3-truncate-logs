#!/bin/bash
# truncate_logs.sh - Truncate oversized log files to prevent disk space issues
#
# N6LKA 2025-11-20 for ASL3
#
# To add files to check, define these variables and call truncate_log:
#
#   FILE=          Full path and filename to monitor
#   maximumsize=   Maximum allowed size in bytes
#   text_truncate= Message to echo and log if file was truncated
#   text_ok=       Message to echo and log if size is OK
#
# This script can be run manually or scheduled with cron (minimum: once daily).
# Update the path below to match where the script is installed.
#
# Example cron entry (runs weekly, Sundays at 4:05 AM):
#   05 04 * * 0 /etc/asterisk/scripts/truncate_logs.sh

function truncate_log {
    if [[ ! -f "$FILE" ]]; then
        echo "SKIP - File not found: $FILE"
        return
    fi

    local actualsize
    actualsize=$(wc -c < "$FILE")

    if [[ $actualsize -ge $maximumsize ]]; then
        local tmpfile
        tmpfile=$(mktemp /tmp/truncate_log.XXXXXX)
        tail -c "$maximumsize" "$FILE" > "$tmpfile"
        cp "$tmpfile" "$FILE"
        rm -f "$tmpfile"
        echo "$text_truncate"
        logger "$text_truncate"
    else
        echo "$text_ok"
        logger "$text_ok"
    fi
}

# =============================================================================
# Files to monitor
# Add or modify entries below. Each block defines one file to check.
# =============================================================================

FILE="/var/log/asterisk/messages.log"
maximumsize=300000
text_truncate="LOG - Asterisk messages.log size adjusted"
text_ok="LOG - Asterisk messages.log size OK"
truncate_log

# Connection log written by asl3-connection-log (https://github.com/N6LKA/asl3-connection-log)
# Originally connections.log on HamVoIP; ASL3 uses connectlog (no extension)
FILE="/var/log/asterisk/connectlog"
maximumsize=100000
text_truncate="LOG - Asterisk connectlog size adjusted"
text_ok="LOG - Asterisk connectlog size OK"
truncate_log

# ASL3 uses Apache2, not httpd
FILE="/var/log/apache2/access.log"
maximumsize=300000
text_truncate="LOG - Apache2 access.log size adjusted"
text_ok="LOG - Apache2 access.log size OK"
truncate_log

FILE="/var/log/apache2/error.log"
maximumsize=20000
text_truncate="LOG - Apache2 error.log size adjusted"
text_ok="LOG - Apache2 error.log size OK"
truncate_log
