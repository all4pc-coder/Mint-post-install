#!/usr/bin/env bash
# ==============================================================================
# Linux Mint 22.3 (Cinnamon) Setup & Verification Test Script
# ==============================================================================
# Checks CLI tools, system performance settings, firewall, Nemo actions, and notifications.
# ==============================================================================

set -u

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASSED_CHECKS=0
FAILED_CHECKS=0

check_cmd() {
    local cmd_name="$1"
    local friendly_name="$2"
    if command -v "$cmd_name" &> /dev/null; then
        echo -e "${GREEN}[PASS]${NC} Installed: $friendly_name ($cmd_name)"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}[FAIL]${NC} Missing: $friendly_name ($cmd_name)"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

check_file() {
    local file_path="$1"
    local friendly_name="$2"
    if [[ -f "$file_path" ]]; then
        echo -e "${GREEN}[PASS]${NC} Found: $friendly_name"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}[FAIL]${NC} Missing: $friendly_name ($file_path)"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

echo -e "${BLUE}==============================================================================${NC}"
echo -e "${BLUE} Linux Mint 22 Verification & Health Check ${NC}"
echo -e "${BLUE}==============================================================================${NC}"

# 1. Checking Core Productivity & Media CLI Dependencies
echo -e "\n${YELLOW}1. Core CLI & GUI Utilities${NC}"
check_cmd "gs" "Ghostscript (PDF Compression)"
check_cmd "convert" "ImageMagick (Image Conversion)"
check_cmd "pdfinfo" "Poppler Utilities (PDF Metadata)"
check_cmd "ffmpeg" "FFmpeg (Media Processing)"
check_cmd "xclip" "xclip (Clipboard Management)"
check_cmd "inxi" "inxi (System Information)"
check_cmd "pdfarranger" "PDF Arranger"
check_cmd "xournalpp" "Xournal++"
check_cmd "okular" "Okular PDF Viewer"
check_cmd "preload" "Preload Launch Daemon"
check_cmd "notify-send" "libnotify-bin (Desktop Notifications)"

# 2. System Settings & Tuning Verification
echo -e "\n${YELLOW}2. System Tuning & Security Configuration${NC}"

# Check Swappiness
CURRENT_SWAP=$(sysctl -n vm.swappiness 2>/dev/null || cat /proc/sys/vm/swappiness 2>/dev/null || echo "unknown")
if [[ "$CURRENT_SWAP" == "10" ]]; then
    echo -e "${GREEN}[PASS]${NC} Swappiness value is set to 10 (Optimal)"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${YELLOW}[WARN]${NC} Swappiness value is $CURRENT_SWAP (Recommended: 10)"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check SSD TRIM Timer
if systemctl is-enabled fstrim.timer &>/dev/null; then
    echo -e "${GREEN}[PASS]${NC} SSD TRIM timer is enabled (fstrim.timer)"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}[FAIL]${NC} SSD TRIM timer is disabled"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check UFW Firewall Status
if command -v ufw &>/dev/null; then
    UFW_STATUS=$(sudo ufw status 2>/dev/null | grep -i "Status:" || echo "inactive")
    if [[ "$UFW_STATUS" =~ "active" ]]; then
        echo -e "${GREEN}[PASS]${NC} UFW Firewall is active"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${YELLOW}[WARN]${NC} UFW Firewall is installed but inactive"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
fi

# 3. Checking Custom Nemo Actions
echo -e "\n${YELLOW}3. Custom Nemo Actions Deployment${NC}"
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(eval echo "~$TARGET_USER")
NEMO_DIR="$TARGET_HOME/.local/share/nemo/actions"

check_file "$NEMO_DIR/pdf-compress.nemo_action" "PDF Compress Nemo Action"
check_file "$NEMO_DIR/convert-to-webp.nemo_action" "Convert to WebP Nemo Action"
check_file "$NEMO_DIR/open-in-vscode.nemo_action" "Open in VS Code Nemo Action"
check_file "$NEMO_DIR/extract-mp3.nemo_action" "Extract MP3 audio from any video file"

# 4. Desktop Notification Functional Test
echo -e "\n${YELLOW}4. Desktop Notification Functional Test${NC}"
NOTIFY_ERR=""
NOTIFY_STATUS=0

if [[ $EUID -eq 0 ]] && [[ -n "${SUDO_USER:-}" ]]; then
    USER_UID=$(id -u "$SUDO_USER" 2>/dev/null || echo "1000")
    USER_DBUS="unix:path=/run/user/${USER_UID}/bus"
    NOTIFY_ERR=$(sudo -u "$SUDO_USER" DBUS_SESSION_BUS_ADDRESS="$USER_DBUS" notify-send "Linux Mint Health Check" "Desktop notification system is functional!" 2>&1)
    NOTIFY_STATUS=$?
else
    NOTIFY_ERR=$(notify-send "Linux Mint Health Check" "Desktop notification system is functional!" 2>&1)
    NOTIFY_STATUS=$?
fi

if [[ $NOTIFY_STATUS -eq 0 ]] && [[ -z "$NOTIFY_ERR" ]]; then
    echo -e "${GREEN}[PASS]${NC} Test notification sent to desktop session"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}[FAIL]${NC} Desktop notification failed: ${NOTIFY_ERR:-Unknown error}"
    echo -e "       ${YELLOW}Tip: Run verification without 'sudo' so it connects to your desktop session.${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# 5. Final Summary
echo -e "\n${BLUE}==============================================================================${NC}"
echo -e "${BLUE} Verification Summary${NC}"
echo -e "${BLUE}==============================================================================${NC}"
echo -e " Passed Checks: ${GREEN}$PASSED_CHECKS${NC}"
echo -e " Issues / Warnings: ${RED}$FAILED_CHECKS${NC}"
echo -e "${BLUE}==============================================================================${NC}"

if [[ $FAILED_CHECKS -eq 0 ]]; then
    echo -e "${GREEN}All system tweaks, utilities, and Nemo actions are active and ready!${NC}"
else
    echo -e "${YELLOW}Some checks require attention. Run post-installation.sh to fix missing items.${NC}"
fi
