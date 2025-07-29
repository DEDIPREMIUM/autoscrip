#!/bin/bash
# ===================================
#  Test Formatted Account Display
# ===================================
# This script creates sample account files and demonstrates
# the formatted display functionality
# ===================================

# Colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
WHITE="\e[37m"
NC="\e[0m"

# Create sample account files
echo "Creating sample account files..."

# Create directories
mkdir -p /etc/ssh /etc/xray

# Sample VLESS account
echo "### ocean 2025-08-01 xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" > /etc/xray/vless_account

# Sample SSH account
echo "### bumiayu 2025-01-01 vpn" > /etc/ssh/ssh_account

# Sample VMess account
echo "### testuser 2025-06-01 yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy" > /etc/xray/vmess_account

# Sample Trojan account
echo "### trojanuser 2025-07-01 trojanpass123" > /etc/xray/trojan_account

# Sample domain
echo "yourdomain.com" > /etc/vpn_domain

echo -e "${GREEN}Sample account files created!${NC}"
echo ""
echo -e "${CYAN}Now you can test the formatted display:${NC}"
echo -e "${YELLOW}1. Run: ./account-display.sh${NC}"
echo -e "${YELLOW}2. Or run: ./vpn-installer.sh and select option 16${NC}"
echo ""
echo -e "${BLUE}Sample accounts created:${NC}"
echo -e "  VLESS: ocean"
echo -e "  SSH: bumiayu"
echo -e "  VMess: testuser"
echo -e "  Trojan: trojanuser"
echo ""
echo -e "${GREEN}Ready to test!${NC}"