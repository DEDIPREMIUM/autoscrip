#!/bin/bash
# ===================================
#  VPN Installer - Quick Setup
# ===================================

echo "==================================="
echo "  All-in-One Auto Installer VPN"
echo "==================================="
echo "  Installing VPN Server..."
echo "==================================="

# Download main script
wget -O /root/vpn-installer.sh https://raw.githubusercontent.com/your-repo/vpn-installer.sh/main/vpn-installer.sh
chmod +x /root/vpn-installer.sh

# Run installer
/root/vpn-installer.sh

echo "==================================="
echo "  Installation Complete!"
echo "==================================="
echo "  Run: /root/vpn-installer.sh"
echo "==================================="