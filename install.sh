#!/bin/bash
# =============================================================================
# install.sh - Installer for asl3-truncate-logs
# https://github.com/N6LKA/asl3-truncate-logs
# =============================================================================

INSTALL_DIR="/etc/asterisk/scripts"
SCRIPT_FILE="$INSTALL_DIR/truncate_logs.sh"
REPO="https://raw.githubusercontent.com/N6LKA/asl3-truncate-logs/main"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "=============================================="
echo "  asl3-truncate-logs - Installer"
echo "  https://github.com/N6LKA/asl3-truncate-logs"
echo "=============================================="
echo ""

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}ERROR: This installer must be run as root or with sudo.${NC}"
    exit 1
fi

# --- Check for existing install ---
if [[ -f "$SCRIPT_FILE" ]]; then
    echo -e "${YELLOW}Existing installation detected. Updating...${NC}"
    BACKUP="$SCRIPT_FILE.bak.$(date +%Y%m%d%H%M%S)"
    cp "$SCRIPT_FILE" "$BACKUP"
    echo "Backup created: $BACKUP"
fi

echo ""
echo "--- Downloading files ---"

# --- Ensure install directory exists ---
mkdir -p "$INSTALL_DIR"

# --- Download main script ---
echo "Downloading truncate_logs.sh..."
curl -fsSL "$REPO/truncate_logs.sh" -o "$SCRIPT_FILE"
if [[ $? -ne 0 ]]; then
    echo -e "${RED}ERROR: Failed to download truncate_logs.sh${NC}"
    if [[ -n "$BACKUP" && -f "$BACKUP" ]]; then
        echo "Restoring backup..."
        cp "$BACKUP" "$SCRIPT_FILE"
    fi
    exit 1
fi
chown root:asterisk "$SCRIPT_FILE"
chmod 750 "$SCRIPT_FILE"

# --- Clean up backup on success ---
[[ -n "$BACKUP" && -f "$BACKUP" ]] && rm -f "$BACKUP"

# --- Set up root cron job ---
echo ""
echo "--- Setting up cron job ---"

CRON_COMMENT="#Truncate Logs daily at 06:00. (Do not use if rebooting weekly. Reboot clears all logs.)"
CRON_JOB="00 06 * * * /etc/asterisk/scripts/truncate_logs.sh >/dev/null 2>&1"
CURRENT_CRON=$(crontab -l 2>/dev/null)

if echo "$CURRENT_CRON" | grep -q "truncate_logs.sh"; then
    # Entry exists — update the cron line and its preceding comment in-place
    NEW_CRON=$(echo "$CURRENT_CRON" | awk -v comment="$CRON_COMMENT" -v job="$CRON_JOB" '
        { lines[NR] = $0 }
        END {
            for (i = 1; i <= NR; i++) {
                if (lines[i] ~ /truncate_logs\.sh/) {
                    if (i > 1 && lines[i-1] ~ /[Tt]runcate/) {
                        lines[i-1] = comment
                    }
                    lines[i] = job
                }
            }
            for (i = 1; i <= NR; i++) print lines[i]
        }')
    echo "$NEW_CRON" | crontab -
    echo -e "${GREEN}Cron job updated.${NC}"
else
    # No existing entry — append with blank line, comment, and cron line
    (crontab -l 2>/dev/null; echo ""; echo "$CRON_COMMENT"; echo "$CRON_JOB") | crontab -
    echo -e "${GREEN}Cron job added (daily at 06:00).${NC}"
fi

echo ""
echo "=============================================="
if [[ -n "$BACKUP" ]]; then
    echo -e "${GREEN}Update complete!${NC}"
else
    echo -e "${GREEN}Installation complete!${NC}"
fi
echo ""
echo "Script installed to: $SCRIPT_FILE"
echo ""
echo "To run manually:"
echo "  /etc/asterisk/scripts/truncate_logs.sh"
echo ""
echo "To change the cron schedule:"
echo "  crontab -e"
echo "=============================================="
echo ""
