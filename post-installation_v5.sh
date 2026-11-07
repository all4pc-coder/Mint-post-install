#!/usr/bin/env bash
# ==============================================================================
# Linux Mint 22 (Cinnamon) Post-Installation Setup & Optimization Script (v5.0)
# ==============================================================================
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[+] $1${NC}"; }
info() { echo -e "${BLUE}[i] $1${NC}"; }
warn() { echo -e "${YELLOW}[!] $1${NC}"; }

if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root (or with sudo)." 1>&2
   exit 1
fi

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(eval echo "~$TARGET_USER")

log "Starting Linux Mint 22 Post-Installation Setup v5.0..."
info "Target User: $TARGET_USER (Home: $TARGET_HOME)"

log "Step 1: Updating Package Repositories..."
apt update && apt upgrade -y

log "Step 2: Installing Codecs, Utilities & Notification Daemon..."
apt install -y mint-meta-codecs ghostscript imagemagick poppler-utils ffmpeg xclip libnotify-bin inxi micro htop curl git

log "Step 3: Enabling UFW Firewall..."
systemctl is-active --quiet ufw || ufw --force enable

log "Step 4: System Performance Tuning..."
SYSCTL_CONF="/etc/sysctl.d/99-mint-tweaks.conf"
if [[ ! -f "$SYSCTL_CONF" ]]; then
    echo "vm.swappiness=10" > "$SYSCTL_CONF"
    sysctl -p "$SYSCTL_CONF" || sysctl vm.swappiness=10
fi
systemctl enable --now fstrim.timer
apt install -y preload

log "Step 5: Configuring User Aliases in .bashrc..."
ALIAS_BLOCK='
# Linux Mint Custom Aliases
alias update="sudo apt update && sudo apt upgrade -y"
alias cleanup="sudo apt autoremove -y && sudo apt clean"
alias sysinfo="inxi -Fz"
alias pdfcompress="gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH"
alias png2webp="convert"
'
USER_BASHRC="$TARGET_HOME/.bashrc"
if [[ -f "$USER_BASHRC" ]] && ! grep -q "Linux Mint Custom Aliases" "$USER_BASHRC"; then
    echo "$ALIAS_BLOCK" >> "$USER_BASHRC"
fi

log "Step 6: Deploying Nemo Action Context Files..."
NEMO_DIR="$TARGET_HOME/.local/share/nemo/actions"
mkdir -p "$NEMO_DIR"

for action_file in *.nemo_action; do
    if [[ -f "$action_file" ]]; then
        info "Installing context action: $action_file"
        cp "$action_file" "$NEMO_DIR/"
        chmod 644 "$NEMO_DIR/$action_file"
    fi
done
chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.local/share/nemo"

log "Step 7: System Cleanup..."
apt autoremove -y
apt clean

log "Post-installation v5.0 complete!"
