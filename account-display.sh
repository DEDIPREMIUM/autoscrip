#!/bin/bash
# ===================================
#  Account Display Formatter
# ===================================
# Displays VPN accounts in formatted style
# ===================================

# Colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
WHITE="\e[37m"
NC="\e[0m"

# Get domain
DOMAIN=$(cat /etc/vpn_domain 2>/dev/null || curl -s ifconfig.me 2>/dev/null || echo "yourdomain.com")

# Function to display VLESS account
display_vless_account() {
    local user=$1
    local uuid=$2
    local expdate=$3
    
    clear
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}        VLESS Account${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Remarks        :${NC} $user"
    echo -e "${CYAN}Domain         :${NC} $DOMAIN"
    echo -e "${CYAN}Wildcard       :${NC} (bug.com).$DOMAIN"
    echo -e "${CYAN}Port TLS       :${NC} 443"
    echo -e "${CYAN}Port none TLS  :${NC} 80"
    echo -e "${CYAN}Port gRPC      :${NC} 443"
    echo -e "${CYAN}id             :${NC} $uuid"
    echo -e "${CYAN}Encryption     :${NC} none"
    echo -e "${CYAN}Network        :${NC} ws"
    echo -e "${CYAN}Path           :${NC} /vless"
    echo -e "${CYAN}Path gRPC      :${NC} vless-grpc"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Link TLS       :${NC} vless://$uuid@$DOMAIN:443?path=/vless&security=tls&encryption=none&type=ws#$user"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Link none TLS  :${NC} vless://$uuid@$DOMAIN:80?path=/vless&encryption=none&type=ws#$user"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Link gRPC      :${NC} vless://$uuid@$DOMAIN:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=bug.com#$user"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Expired On     :${NC} $expdate"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Press any key to back on VLESS${NC}"
    read -n1 -r
}

# Function to display SSH/OpenVPN account
display_ssh_account() {
    local user=$1
    local pass=$2
    local expdate=$3
    
    clear
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━◇${NC}"
    echo -e "${WHITE}     SSH OPENVPN${NC}"
    echo -e "${WHITE}◇━━━━━━━━━━━━━━━━━◇${NC}"
    echo -e "${CYAN}Remark      :${NC} $user"
    echo -e "${CYAN}Username    :${NC} $user"
    echo -e "${CYAN}Password    :${NC} $pass"
    echo -e "${CYAN}Limit IP    :${NC} 1 Device"
    echo -e "${CYAN}Domain      :${NC} $DOMAIN"
    echo -e "${CYAN}ISP         :${NC} Rumahweb Indonesia"
    echo -e "${CYAN}OpenSSH     :${NC} 22, 80, 443"
    echo -e "${CYAN}SSH WS      :${NC} 80, 8080, 8880, 2082"
    echo -e "${CYAN}SSL/TLS     :${NC} 443"
    echo -e "${CYAN}OVPN UDP    :${NC} 2200"
    echo -e "${WHITE}◇━━━━━━━━━━━━━━━━━◇${NC}"
    echo -e "${CYAN}Port 80     :${NC} $DOMAIN:80@$user:$pass"
    echo -e "${CYAN}Port 443    :${NC} $DOMAIN:443@$user:$pass"
    echo -e "${CYAN}Udp Custom  :${NC} $DOMAIN:1-65535@$user:$pass"
    echo -e "${CYAN}OpenVpn     :${NC} https://$DOMAIN:81/"
    echo -e "${CYAN}Account     :${NC} https://$DOMAIN:81/ssh-$user.txt"
    echo -e "${WHITE}◇━━━━━━━━━━━━━━━━━◇${NC}"
    echo -e "${CYAN}Payload WS  :${NC} GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: websocket[crlf][crlf]"
    echo -e "${WHITE}◇━━━━━━━━━━━━━━━━━◇${NC}"
    echo -e "${CYAN}Payload TLS :${NC} GET wss://$DOMAIN/ HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: websocket[crlf][crlf]"
    echo -e "${WHITE}◇━━━━━━━━━━━━━━━━━◇${NC}"
    echo -e "${CYAN}Payload ENCD:${NC} HEAD / HTTP/1.1[crlf]Host: Masukan_Bug[crlf][crlf]PATCH / HTTP/1.1[crlf]Host: [host][crlf]Upgrade: websocket[crlf][crlf][split]HTTP/ 1[crlf][crlf]"
    echo -e "${WHITE}◇━━━━━━━━━━━━━━━━━◇${NC}"
    echo -e "${CYAN}Expiry in  :${NC} $expdate"
    echo -e "${WHITE}◇━━━━━━━━━━━━━━━━━◇${NC}"
    echo -e "${YELLOW}Press any key to continue...${NC}"
    read -n1 -r
}

# Function to display VMess account
display_vmess_account() {
    local user=$1
    local uuid=$2
    local expdate=$3
    
    clear
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}        VMess Account${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Remarks        :${NC} $user"
    echo -e "${CYAN}Domain         :${NC} $DOMAIN"
    echo -e "${CYAN}Wildcard       :${NC} (bug.com).$DOMAIN"
    echo -e "${CYAN}Port TLS       :${NC} 443"
    echo -e "${CYAN}Port none TLS  :${NC} 80"
    echo -e "${CYAN}Port gRPC      :${NC} 443"
    echo -e "${CYAN}id             :${NC} $uuid"
    echo -e "${CYAN}AlterId        :${NC} 0"
    echo -e "${CYAN}Security       :${NC} auto"
    echo -e "${CYAN}Network        :${NC} ws"
    echo -e "${CYAN}Path           :${NC} /vmess"
    echo -e "${CYAN}Path gRPC      :${NC} vmess-grpc"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Link TLS       :${NC} vmess://$(echo "{\"v\":\"2\",\"ps\":\"$user-CF443\",\"add\":\"$DOMAIN\",\"port\":\"443\",\"id\":\"$uuid\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"$DOMAIN\",\"path\":\"/vmess\",\"tls\":\"tls\"}" | base64 -w 0)"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Link none TLS  :${NC} vmess://$(echo "{\"v\":\"2\",\"ps\":\"$user-CF80\",\"add\":\"$DOMAIN\",\"port\":\"80\",\"id\":\"$uuid\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"$DOMAIN\",\"path\":\"/vmess\",\"tls\":\"none\"}" | base64 -w 0)"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Link gRPC      :${NC} vmess://$(echo "{\"v\":\"2\",\"ps\":\"$user-CF443\",\"add\":\"$DOMAIN\",\"port\":\"443\",\"id\":\"$uuid\",\"aid\":\"0\",\"net\":\"grpc\",\"type\":\"gun\",\"host\":\"$DOMAIN\",\"path\":\"vmess-grpc\",\"tls\":\"tls\"}" | base64 -w 0)"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Expired On     :${NC} $expdate"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Press any key to back on VMess${NC}"
    read -n1 -r
}

# Function to display Trojan account
display_trojan_account() {
    local user=$1
    local pass=$2
    local expdate=$3
    
    clear
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}       Trojan Account${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Remarks        :${NC} $user"
    echo -e "${CYAN}Domain         :${NC} $DOMAIN"
    echo -e "${CYAN}Wildcard       :${NC} (bug.com).$DOMAIN"
    echo -e "${CYAN}Port TLS       :${NC} 443"
    echo -e "${CYAN}Port none TLS  :${NC} 80"
    echo -e "${CYAN}Port gRPC      :${NC} 443"
    echo -e "${CYAN}Password       :${NC} $pass"
    echo -e "${CYAN}Network        :${NC} ws"
    echo -e "${CYAN}Path           :${NC} /trojan"
    echo -e "${CYAN}Path gRPC      :${NC} trojan-grpc"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Link TLS       :${NC} trojan://$pass@$DOMAIN:443?type=ws&security=tls&host=$DOMAIN&path=%2Ftrojan#$user"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Link none TLS  :${NC} trojan://$pass@$DOMAIN:80?type=ws&security=none&host=$DOMAIN&path=%2Ftrojan#$user"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Link gRPC      :${NC} trojan://$pass@$DOMAIN:443?type=grpc&security=tls&host=$DOMAIN&serviceName=trojan-grpc#$user"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Expired On     :${NC} $expdate"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Press any key to back on Trojan${NC}"
    read -n1 -r
}

# Main menu
main_menu() {
    clear
    echo -e "${BLUE}===================================${NC}"
    echo -e "${BLUE}     Account Display Formatter${NC}"
    echo -e "${BLUE}===================================${NC}"
    echo ""
    echo -e "${CYAN}[1]${NC} Display VLESS Account"
    echo -e "${CYAN}[2]${NC} Display SSH/OpenVPN Account"
    echo -e "${CYAN}[3]${NC} Display VMess Account"
    echo -e "${CYAN}[4]${NC} Display Trojan Account"
    echo -e "${CYAN}[5]${NC} List All Accounts"
    echo -e "${CYAN}[0]${NC} Exit"
    echo ""
    read -rp "Choose menu: " menu_choice
    
    case $menu_choice in
        1) vless_menu ;;
        2) ssh_menu ;;
        3) vmess_menu ;;
        4) trojan_menu ;;
        5) list_all_accounts ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid choice!${NC}"; sleep 1; main_menu ;;
    esac
}

# VLESS menu
vless_menu() {
    clear
    echo -e "${BLUE}==== VLESS Account Display ====${NC}"
    echo ""
    
    if [ ! -f "/etc/xray/vless_account" ]; then
        echo -e "${RED}No VLESS accounts found!${NC}"
        read -n1 -r -p "Press any key..."; main_menu; return
    fi
    
    echo -e "${CYAN}Available VLESS accounts:${NC}"
    echo ""
    cat /etc/xray/vless_account | while IFS=' ' read -r mark user expdate uuid; do
        if [ "$mark" = "###" ]; then
            echo -e "${YELLOW}$user${NC} - Expires: $expdate"
        fi
    done
    echo ""
    read -rp "Enter username to display: " username
    
    # Get account info
    account_line=$(grep "^### $username " /etc/xray/vless_account)
    if [ -z "$account_line" ]; then
        echo -e "${RED}User not found!${NC}"
        sleep 1; vless_menu; return
    fi
    
    # Parse account info
    expdate=$(echo "$account_line" | awk '{print $3}')
    uuid=$(echo "$account_line" | awk '{print $4}')
    
    display_vless_account "$username" "$uuid" "$expdate"
    vless_menu
}

# SSH menu
ssh_menu() {
    clear
    echo -e "${BLUE}==== SSH/OpenVPN Account Display ====${NC}"
    echo ""
    
    if [ ! -f "/etc/ssh/ssh_account" ]; then
        echo -e "${RED}No SSH accounts found!${NC}"
        read -n1 -r -p "Press any key..."; main_menu; return
    fi
    
    echo -e "${CYAN}Available SSH accounts:${NC}"
    echo ""
    cat /etc/ssh/ssh_account | while IFS=' ' read -r mark user expdate pass; do
        if [ "$mark" = "###" ]; then
            echo -e "${YELLOW}$user${NC} - Expires: $expdate"
        fi
    done
    echo ""
    read -rp "Enter username to display: " username
    
    # Get account info
    account_line=$(grep "^### $username " /etc/ssh/ssh_account)
    if [ -z "$account_line" ]; then
        echo -e "${RED}User not found!${NC}"
        sleep 1; ssh_menu; return
    fi
    
    # Parse account info
    expdate=$(echo "$account_line" | awk '{print $3}')
    pass=$(echo "$account_line" | awk '{print $4}')
    
    display_ssh_account "$username" "$pass" "$expdate"
    ssh_menu
}

# VMess menu
vmess_menu() {
    clear
    echo -e "${BLUE}==== VMess Account Display ====${NC}"
    echo ""
    
    if [ ! -f "/etc/xray/vmess_account" ]; then
        echo -e "${RED}No VMess accounts found!${NC}"
        read -n1 -r -p "Press any key..."; main_menu; return
    fi
    
    echo -e "${CYAN}Available VMess accounts:${NC}"
    echo ""
    cat /etc/xray/vmess_account | while IFS=' ' read -r mark user expdate uuid; do
        if [ "$mark" = "###" ]; then
            echo -e "${YELLOW}$user${NC} - Expires: $expdate"
        fi
    done
    echo ""
    read -rp "Enter username to display: " username
    
    # Get account info
    account_line=$(grep "^### $username " /etc/xray/vmess_account)
    if [ -z "$account_line" ]; then
        echo -e "${RED}User not found!${NC}"
        sleep 1; vmess_menu; return
    fi
    
    # Parse account info
    expdate=$(echo "$account_line" | awk '{print $3}')
    uuid=$(echo "$account_line" | awk '{print $4}')
    
    display_vmess_account "$username" "$uuid" "$expdate"
    vmess_menu
}

# Trojan menu
trojan_menu() {
    clear
    echo -e "${BLUE}==== Trojan Account Display ====${NC}"
    echo ""
    
    if [ ! -f "/etc/xray/trojan_account" ]; then
        echo -e "${RED}No Trojan accounts found!${NC}"
        read -n1 -r -p "Press any key..."; main_menu; return
    fi
    
    echo -e "${CYAN}Available Trojan accounts:${NC}"
    echo ""
    cat /etc/xray/trojan_account | while IFS=' ' read -r mark user expdate pass; do
        if [ "$mark" = "###" ]; then
            echo -e "${YELLOW}$user${NC} - Expires: $expdate"
        fi
    done
    echo ""
    read -rp "Enter username to display: " username
    
    # Get account info
    account_line=$(grep "^### $username " /etc/xray/trojan_account)
    if [ -z "$account_line" ]; then
        echo -e "${RED}User not found!${NC}"
        sleep 1; trojan_menu; return
    fi
    
    # Parse account info
    expdate=$(echo "$account_line" | awk '{print $3}')
    pass=$(echo "$account_line" | awk '{print $4}')
    
    display_trojan_account "$username" "$pass" "$expdate"
    trojan_menu
}

# List all accounts
list_all_accounts() {
    clear
    echo -e "${BLUE}==== All Active Accounts ====${NC}"
    echo ""
    
    echo -e "${CYAN}SSH Accounts:${NC}"
    if [ -f "/etc/ssh/ssh_account" ]; then
        cat /etc/ssh/ssh_account | while IFS=' ' read -r mark user expdate pass; do
            if [ "$mark" = "###" ]; then
                echo -e "  ${YELLOW}$user${NC} - Expires: $expdate"
            fi
        done
    else
        echo -e "  ${RED}No SSH accounts${NC}"
    fi
    echo ""
    
    echo -e "${CYAN}VLESS Accounts:${NC}"
    if [ -f "/etc/xray/vless_account" ]; then
        cat /etc/xray/vless_account | while IFS=' ' read -r mark user expdate uuid; do
            if [ "$mark" = "###" ]; then
                echo -e "  ${YELLOW}$user${NC} - Expires: $expdate"
            fi
        done
    else
        echo -e "  ${RED}No VLESS accounts${NC}"
    fi
    echo ""
    
    echo -e "${CYAN}VMess Accounts:${NC}"
    if [ -f "/etc/xray/vmess_account" ]; then
        cat /etc/xray/vmess_account | while IFS=' ' read -r mark user expdate uuid; do
            if [ "$mark" = "###" ]; then
                echo -e "  ${YELLOW}$user${NC} - Expires: $expdate"
            fi
        done
    else
        echo -e "  ${RED}No VMess accounts${NC}"
    fi
    echo ""
    
    echo -e "${CYAN}Trojan Accounts:${NC}"
    if [ -f "/etc/xray/trojan_account" ]; then
        cat /etc/xray/trojan_account | while IFS=' ' read -r mark user expdate pass; do
            if [ "$mark" = "###" ]; then
                echo -e "  ${YELLOW}$user${NC} - Expires: $expdate"
            fi
        done
    else
        echo -e "  ${RED}No Trojan accounts${NC}"
    fi
    echo ""
    
    read -n1 -r -p "Press any key..."; main_menu
}

# Start the script
main_menu