#!/bin/bash
# ===================================
#  VPN Testing Script
# ===================================

echo "==================================="
echo "  VPN Server Testing"
echo "==================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "Script harus dijalankan sebagai root!" 
   exit 1
fi

# Test Services
echo "Testing Services..."
echo "1. Xray Core: $(systemctl is-active xray)"
echo "2. Nginx: $(systemctl is-active nginx)"
echo "3. Dropbear: $(systemctl is-active dropbear)"
echo "4. Squid: $(systemctl is-active squid)"

# Test Ports
echo ""
echo "Testing Ports..."
echo "1. Port 443 (VMess): $(ss -tuln | grep :443 | wc -l) connections"
echo "2. Port 8443 (VLESS): $(ss -tuln | grep :8443 | wc -l) connections"
echo "3. Port 9443 (Trojan): $(ss -tuln | grep :9443 | wc -l) connections"
echo "4. Port 3128 (Squid): $(ss -tuln | grep :3128 | wc -l) connections"

# Test Config Files
echo ""
echo "Testing Config Files..."
echo "1. Xray Config: $(test -f /etc/xray/config.json && echo "OK" || echo "MISSING")"
echo "2. SSH Banner: $(test -f /etc/ssh/banner && echo "OK" || echo "MISSING")"
echo "3. Nginx Config: $(test -f /etc/nginx/sites-available/default && echo "OK" || echo "MISSING")"

# Test Account Files
echo ""
echo "Testing Account Files..."
echo "1. SSH Accounts: $(test -f /etc/ssh/ssh_account && echo "OK" || echo "MISSING")"
echo "2. VMess Accounts: $(test -f /etc/xray/vmess_account && echo "OK" || echo "MISSING")"
echo "3. VLESS Accounts: $(test -f /etc/xray/vless_account && echo "OK" || echo "MISSING")"
echo "4. Trojan Accounts: $(test -f /etc/xray/trojan_account && echo "OK" || echo "MISSING")"

# Show Account Counts
echo ""
echo "Account Counts:"
echo "1. SSH: $(grep -c '^###' /etc/ssh/ssh_account 2>/dev/null || echo 0)"
echo "2. VMess: $(grep -c '^###' /etc/xray/vmess_account 2>/dev/null || echo 0)"
echo "3. VLESS: $(grep -c '^###' /etc/xray/vless_account 2>/dev/null || echo 0)"
echo "4. Trojan: $(grep -c '^###' /etc/xray/trojan_account 2>/dev/null || echo 0)"

# Test Internet Connectivity
echo ""
echo "Testing Internet Connectivity..."
if ping -c 1 8.8.8.8 &>/dev/null; then
    echo "Internet: OK"
else
    echo "Internet: FAILED"
fi

# Test Domain Resolution
echo ""
echo "Testing Domain Resolution..."
domain=$(curl -s ifconfig.me 2>/dev/null || echo "unknown")
echo "Server IP: $domain"

echo ""
echo "==================================="
echo "  Testing Complete!"
echo "==================================="