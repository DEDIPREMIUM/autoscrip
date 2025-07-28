#!/bin/bash
# ===================================
#  VPN Installer - Domain First
# ===================================

echo "==================================="
echo "  All-in-One Auto Installer VPN"
echo "==================================="
echo "  Domain First Installation"
echo "==================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "Script harus dijalankan sebagai root!" 
   echo "Gunakan: sudo bash install-new.sh"
   exit 1
fi

# Input domain first
clear
echo "==================================="
echo "  DOMAIN CONFIGURATION"
echo "==================================="
echo ""

# Get current IP
current_ip=$(curl -s ifconfig.me 2>/dev/null || echo "unknown")
echo "Current IP: $current_ip"

read -rp "Enter your domain (or press Enter to use IP): " domain_input

if [ -z "$domain_input" ]; then
    DOMAIN="$current_ip"
    echo "Using IP: $DOMAIN"
else
    DOMAIN="$domain_input"
    echo "Using Domain: $DOMAIN"
fi

# Save domain to file
echo "$DOMAIN" > /etc/vpn_domain

echo ""
echo "Domain configured successfully!"
echo "Starting installation..."

# Download main script
echo "Downloading VPN installer..."
wget -O /root/vpn-installer.sh https://raw.githubusercontent.com/your-repo/vpn-installer/main/vpn-installer.sh
chmod +x /root/vpn-installer.sh

# Run installer
echo "Starting VPN installation..."
/root/vpn-installer.sh

echo "==================================="
echo "  Installation Complete!"
echo "==================================="
echo "  Run: /root/vpn-installer.sh"
echo "==================================="