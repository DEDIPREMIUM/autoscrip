#!/bin/bash
# ===================================
#  VPN Installer - Quick Setup
# ===================================

echo "==================================="
echo "  All-in-One Auto Installer VPN"
echo "==================================="
echo "  Installing VPN Server..."
echo "==================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "Script harus dijalankan sebagai root!" 
   echo "Gunakan: sudo bash install.sh"
   exit 1
fi

# Download main script
echo "Downloading VPN installer..."
wget -O /root/vpn-installer.sh https://raw.githubusercontent.com/DEDIPREMIUM/autoscrip/main/vpn-installer.sh
chmod +x /root/vpn-installer.sh

# Run installer
echo "Starting VPN installation..."
/root/vpn-installer.sh

echo "==================================="
echo "  Installation Complete!"
echo "==================================="
echo "  Run: /root/vpn-installer.sh"
echo "==================================="
