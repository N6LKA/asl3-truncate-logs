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
echo "Recommended cron entry (Sundays at 4:05 AM):"
echo "  05 04 * * 0 /etc/asterisk/scripts/truncate_logs.sh"
echo "  Add with: crontab -e"
echo "=============================================="
echo ""
