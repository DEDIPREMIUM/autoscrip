#!/bin/bash
# ===================================
#  All-in-One Auto Installer VPN
# ===================================
# Support: SSH, VMess, VLESS, Trojan, Nginx, Dropbear, Xray, WebSocket, Stunnel5, Squid, OpenVPN
# Features: Auto Expired, Auto Renew, Custom Domain, Banner, Backup, Monitoring, Speedtest
# Compatible: HTTP Injector, HTTP Custom, V2RayBox, V2Ray, etc.
# ===================================
# Author: VPN Script
# Version: 2.0
# ===================================

# Cek root
if [[ $EUID -ne 0 ]]; then
   echo "Script harus dijalankan sebagai root!" 
   exit 1
fi

# Warna
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
NC="\e[0m"

# Banner
clear
echo -e "${BLUE}"
echo "==================================="
echo "  All-in-One Auto Installer VPN"
echo "==================================="
echo "  Support: SSH, VMess, VLESS, Trojan"
echo "  Features: Auto Expired, Auto Renew"
echo "  Compatible: HTTP Injector, V2RayBox"
echo "==================================="
echo -e "${NC}"
sleep 2

# Input Domain First
input_domain() {
    clear
    echo -e "${CYAN}===================================${NC}"
    echo -e "${CYAN}  DOMAIN CONFIGURATION${NC}"
    echo -e "${CYAN}===================================${NC}"
    echo ""
    
    # Get current IP
    current_ip=$(curl -s ifconfig.me 2>/dev/null || echo "unknown")
    echo -e "Current IP: ${YELLOW}$current_ip${NC}"
    
    read -rp "Enter your domain (or press Enter to use IP): " domain_input
    
    if [ -z "$domain_input" ]; then
        DOMAIN="$current_ip"
        echo -e "Using IP: ${GREEN}$DOMAIN${NC}"
    else
        DOMAIN="$domain_input"
        echo -e "Using Domain: ${GREEN}$DOMAIN${NC}"
    fi
    
    # Save domain to file
    echo "$DOMAIN" > /etc/vpn_domain
    
    echo ""
    echo -e "${GREEN}Domain configured successfully!${NC}"
    sleep 2
}

# Get VPS Info
get_vps_info() {
    VPS_IP=$(cat /etc/vpn_domain 2>/dev/null || curl -s ifconfig.me 2>/dev/null || echo "unknown")
    VPS_RAM=$(free -h | grep Mem | awk '{print $2}')
    VPS_CORE=$(nproc)
    VPS_OS=$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
    VPS_UPTIME=$(uptime -p)
    VPS_LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs)
}

# Fungsi Cek Status Layanan
check_service() {
    case "$1" in
        "websocat")
            command -v websocat &>/dev/null && echo -e "[✔]" || echo -e "[✘]"
            ;;
        "stunnel5")
            if systemctl is-active --quiet stunnel5 2>/dev/null; then
                echo -e "[✔]"
            elif systemctl is-active --quiet stunnel4 2>/dev/null; then
                echo -e "[✔]"
            else
                echo -e "[✘]"
            fi
            ;;
        "openvpn")
            if systemctl is-active --quiet openvpn@server 2>/dev/null; then
                echo -e "[✔]"
            elif systemctl is-active --quiet openvpn 2>/dev/null; then
                echo -e "[✔]"
            else
                echo -e "[✘]"
            fi
            ;;
        *)
            systemctl is-active --quiet "$1" && echo -e "[✔]" || echo -e "[✘]"
            ;;
    esac
}

# Fungsi Cek Jumlah Akun
count_ssh() {
    grep -cE '^### ' /etc/ssh/ssh_account 2>/dev/null || echo 0
}
count_vmess() {
    grep -cE '^### ' /etc/xray/vmess_account 2>/dev/null || echo 0
}
count_vless() {
    grep -cE '^### ' /etc/xray/vless_account 2>/dev/null || echo 0
}
count_trojan() {
    grep -cE '^### ' /etc/xray/trojan_account 2>/dev/null || echo 0
}

# Fungsi Auto Expired
clean_expired_accounts() {
    today=$(date +%Y-%m-%d)
    echo "Cleaning expired accounts..."
    
    # SSH
    while IFS= read -r line; do
        if [[ $line =~ ^###[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+) ]]; then
            user="${BASH_REMATCH[1]}"
            expdate="${BASH_REMATCH[2]}"
            if [[ "$expdate" < "$today" ]]; then
                userdel "$user" 2>/dev/null
                sed -i "/^### $user /d" /etc/ssh/ssh_account
                echo "SSH Account $user expired and deleted"
            fi
        fi
    done < /etc/ssh/ssh_account 2>/dev/null
    
    # VMess
    while IFS= read -r line; do
        if [[ $line =~ ^###[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+) ]]; then
            user="${BASH_REMATCH[1]}"
            expdate="${BASH_REMATCH[2]}"
            uuid="${BASH_REMATCH[3]}"
            if [[ "$expdate" < "$today" ]]; then
                if [ -f "/etc/xray/config.json" ]; then
                    jq "(.inbounds[0].settings.clients) |= map(select(.id != \"$uuid\"))" /etc/xray/config.json > /tmp/config.json && mv /tmp/config.json /etc/xray/config.json
                fi
                sed -i "/^### $user /d" /etc/xray/vmess_account
                echo "VMess Account $user expired and deleted"
            fi
        fi
    done < /etc/xray/vmess_account 2>/dev/null
    
    # VLESS
    while IFS= read -r line; do
        if [[ $line =~ ^###[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+) ]]; then
            user="${BASH_REMATCH[1]}"
            expdate="${BASH_REMATCH[2]}"
            uuid="${BASH_REMATCH[3]}"
            if [[ "$expdate" < "$today" ]]; then
                if [ -f "/etc/xray/config.json" ]; then
                    idx=$(jq '.inbounds | map(.protocol == "vless") | index(true)' /etc/xray/config.json 2>/dev/null)
                    if [ "$idx" != "null" ] && [ -n "$idx" ]; then
                        jq ".inbounds[$idx].settings.clients |= map(select(.id != \"$uuid\"))" /etc/xray/config.json > /tmp/config.json && mv /tmp/config.json /etc/xray/config.json
                    fi
                fi
                sed -i "/^### $user /d" /etc/xray/vless_account
                echo "VLESS Account $user expired and deleted"
            fi
        fi
    done < /etc/xray/vless_account 2>/dev/null
    
    # Trojan
    while IFS= read -r line; do
        if [[ $line =~ ^###[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+) ]]; then
            user="${BASH_REMATCH[1]}"
            expdate="${BASH_REMATCH[2]}"
            pass="${BASH_REMATCH[3]}"
            if [[ "$expdate" < "$today" ]]; then
                if [ -f "/etc/xray/config.json" ]; then
                    idx=$(jq '.inbounds | map(.protocol == "trojan") | index(true)' /etc/xray/config.json 2>/dev/null)
                    if [ "$idx" != "null" ] && [ -n "$idx" ]; then
                        jq ".inbounds[$idx].settings.clients |= map(select(.password != \"$pass\"))" /etc/xray/config.json > /tmp/config.json && mv /tmp/config.json /etc/xray/config.json
                    fi
                fi
                sed -i "/^### $user /d" /etc/xray/trojan_account
                echo "Trojan Account $user expired and deleted"
            fi
        fi
    done < /etc/xray/trojan_account 2>/dev/null
    
    systemctl restart xray 2>/dev/null
    echo "Expired accounts cleanup completed!"
}

# Check if script is called with --clean-expired argument
if [[ "$1" == "--clean-expired" ]]; then
    clean_expired_accounts
    exit 0
fi

# Fungsi Instalasi Layanan
install_services() {
    echo "Installing required packages..."
    apt update && apt install -y nginx dropbear stunnel4 squid openvpn curl socat xz-utils wget gnupg2 lsb-release jq unzip
    
    # Xray Core
    if ! command -v xray &>/dev/null; then
        echo "Installing Xray Core..."
        wget -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
        unzip /tmp/xray.zip -d /usr/local/bin/
        chmod +x /usr/local/bin/xray
        rm -f /tmp/xray.zip
    fi
    
    # WebSocket (websocat)
    if ! command -v websocat &>/dev/null; then
        echo "Installing WebSocket (websocat)..."
        wget -O /usr/local/bin/websocat https://github.com/vi/websocat/releases/download/v1.11.0/websocat_amd64-linux
        chmod +x /usr/local/bin/websocat
    fi
    
    # Setup Xray service
    cat > /etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=nobody
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF
    
    # Setup Xray config with Cloudflare support
    mkdir -p /etc/xray
    cat > /etc/xray/config.json <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 80,
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vmess"
        }
      }
    },
    {
      "port": 443,
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vmess"
        }
      }
    },
    {
      "port": 8080,
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vmess"
        }
      }
    },
    {
      "port": 8443,
      "protocol": "vless",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vless"
        }
      }
    },
    {
      "port": 2053,
      "protocol": "trojan",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/trojan"
        }
      }
    },
    {
      "port": 2083,
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vmess"
        }
      }
    },
    {
      "port": 2087,
      "protocol": "vless",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vless"
        }
      }
    },
    {
      "port": 2096,
      "protocol": "trojan",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/trojan"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF
    
    # Setup Dropbear
    cat > /etc/default/dropbear <<EOF
NO_START=0
DROPBEAR_PORT=443
DROPBEAR_EXTRA_ARGS=
DROPBEAR_BANNER="/etc/ssh/banner"
DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"
DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"
DROPBEAR_ECDSAKEY="/etc/dropbear/dropbear_ecdsa_host_key"
DROPBEAR_RECEIVE_WINDOW=65536
EOF
    
    # Setup Nginx with Cloudflare support
    cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80;
    server_name $DOMAIN;
    
    # Cloudflare WebSocket Support
    location /vmess {
        proxy_pass http://127.0.0.1:80;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location /vless {
        proxy_pass http://127.0.0.1:8443;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location /trojan {
        proxy_pass http://127.0.0.1:2053;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Additional paths for Cloudflare
    location /ws {
        proxy_pass http://127.0.0.1:80;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
    
    location /cf {
        proxy_pass http://127.0.0.1:443;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
}

# HTTPS server for Cloudflare
server {
    listen 443 ssl http2;
    server_name $DOMAIN;
    
    # SSL configuration for Cloudflare
    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    # Cloudflare WebSocket Support
    location /vmess {
        proxy_pass http://127.0.0.1:443;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location /vless {
        proxy_pass http://127.0.0.1:8443;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location /trojan {
        proxy_pass http://127.0.0.1:2053;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
    
    # Setup Squid
    cat > /etc/squid/squid.conf <<EOF
http_port 3128
http_access allow all
EOF
    
    # Setup banner with domain
    cat > /etc/ssh/banner <<EOF
===================================
    Welcome to VPN Server
===================================
Host: $DOMAIN
Date: $(date)
Cloudflare: Supported
Ports: 80, 443, 8080, 8443, 2053, 2083, 2087, 2096
===================================
EOF
    
    # Setup cron job for auto expired
    (crontab -l 2>/dev/null; echo "0 2 * * * /bin/bash /root/vpn-installer.sh --clean-expired") | crontab -
    
    # Enable and start services
    systemctl daemon-reload
    systemctl enable xray nginx dropbear squid
    systemctl start xray nginx dropbear squid
    
    echo "Services installation completed with Cloudflare support!"
}

# Fungsi Menu dengan layout 1 baris 2 kolom
main_menu() {
    clear
    get_vps_info
    
    echo -e "${CYAN}===================================${NC}"
    echo -e "${CYAN}  VPS INFORMATION${NC}"
    echo -e "${CYAN}===================================${NC}"
    echo -e " ${YELLOW}IP/Domain:${NC} $VPS_IP"
    echo -e " ${YELLOW}RAM:${NC} $VPS_RAM  ${YELLOW}CPU:${NC} $VPS_CORE Core"
    echo -e " ${YELLOW}OS:${NC} $VPS_OS"
    echo -e " ${YELLOW}Uptime:${NC} $VPS_UPTIME  ${YELLOW}Load:${NC} $VPS_LOAD"
    echo -e "${CYAN}===================================${NC}"
    echo -e " ${GREEN}✅ ACTIVE VPN ACCOUNTS${NC}"
    echo -e "${CYAN}===================================${NC}"
    echo -e " 🔐 SSH: $(count_ssh)  💠 VMess: $(count_vmess)  💠 VLESS: $(count_vless)  🔐 Trojan: $(count_trojan)"
    echo -e "${CYAN}===================================${NC}"
    echo -e " ${GREEN}📋 SERVICE STATUS${NC}"
    echo -e "${CYAN}===================================${NC}"
    echo -e " 🔵 Nginx: $(check_service nginx)  🔵 Dropbear: $(check_service dropbear)  🔵 Xray: $(check_service xray)"
    echo -e " 🔵 WebSocket: $(check_service websocat)  🔵 Stunnel: $(check_service stunnel5)  🔵 Squid: $(check_service squid)"
    echo -e "${CYAN}===================================${NC}"
    echo -e " ${GREEN}📌 MAIN MENU${NC}"
    echo -e "${CYAN}===================================${NC}"
    echo -e " [1] SSH Account     [2] VLESS Account"
    echo -e " [3] VMess Account   [4] Trojan Account"
    echo -e " [5] Change Domain   [6] Change Banner"
    echo -e " [7] Check Ports     [8] Restart Services"
    echo -e " [9] Show Accounts   [10] Auto Expired"
    echo -e " [11] Auto Renew     [12] System Info"
    echo -e " [13] Speedtest      [14] Backup Config"
    echo -e " [15] Auto Reboot    [0] Exit"
    echo -e "${CYAN}===================================${NC}"
    read -rp "Select menu: " menu
    case $menu in
        1) manage_ssh ;;
        2) manage_vless ;;
        3) manage_vmess ;;
        4) manage_trojan ;;
        5) change_domain ;;
        6) change_banner ;;
        7) check_ports ;;
        8) restart_services ;;
        9) show_all_accounts ;;
        10) clean_expired_accounts ;;
        11) renew_account ;;
        12) system_info ;;
        13) speed_test ;;
        14) backup_config ;;
        15) auto_reboot ;;
        0) exit 0 ;;
        *) echo "Invalid!"; sleep 1; main_menu ;;
    esac
}

# Fungsi Dummy (bisa dikembangkan)
manage_ssh() {
    clear
    echo "==== SSH Account Menu ===="
    echo "1. Add SSH Account"
    echo "2. Delete SSH Account"
    echo "3. List SSH Accounts"
    echo "0. Back"
    read -rp "Pilih menu: " sshmenu
    case $sshmenu in
        1) add_ssh_account ;;
        2) del_ssh_account ;;
        3) list_ssh_account ;;
        0) main_menu ;;
        *) echo "Invalid!"; sleep 1; manage_ssh ;;
    esac
}

add_ssh_account() {
    read -rp "Username: " user
    read -rp "Password: " pass
    read -rp "Masa aktif (hari): " exp
    if id "$user" &>/dev/null; then
        echo "User sudah ada!"; sleep 1; manage_ssh; return
    fi
    useradd -e $(date -d "+$exp days" +%Y-%m-%d) -s /bin/false -M $user
    echo -e "$pass\n$pass" | passwd $user &>/dev/null
    expdate=$(chage -l $user | grep "Account expires" | awk -F": " '{print $2}')
    echo "### $user $expdate" >> /etc/ssh/ssh_account
    echo "Akun SSH berhasil dibuat!"
    echo "Host/IP: $(curl -s ifconfig.me)"
    echo "Username: $user"
    echo "Password: $pass"
    echo "Port: 22, 443 (Dropbear/OpenSSH)"
    echo "Expired: $expdate"
    read -n1 -r -p "Press any key..."; manage_ssh
}

del_ssh_account() {
    read -rp "Username: " user
    if ! id "$user" &>/dev/null; then
        echo "User tidak ditemukan!"; sleep 1; manage_ssh; return
    fi
    userdel $user
    sed -i "/^### $user /d" /etc/ssh/ssh_account
    echo "Akun SSH $user dihapus!"
    sleep 1; manage_ssh
}

list_ssh_account() {
    echo "==== List SSH Account ===="
    cat /etc/ssh/ssh_account || echo "Belum ada akun."
    read -n1 -r -p "Press any key..."; manage_ssh
}

manage_vless() {
    clear
    echo "==== VLESS Account Menu ===="
    echo "1. Add VLESS Account"
    echo "2. Delete VLESS Account"
    echo "3. List VLESS Accounts"
    echo "0. Back"
    read -rp "Pilih menu: " vlmenu
    case $vlmenu in
        1) add_vless_account ;;
        2) del_vless_account ;;
        3) list_vless_account ;;
        0) main_menu ;;
        *) echo "Invalid!"; sleep 1; manage_vless ;;
    esac
}

add_vless_account() {
    read -rp "Username: " user
    read -rp "Masa aktif (hari): " exp
    uuid=$(cat /proc/sys/kernel/random/uuid)
    expdate=$(date -d "+$exp days" +%Y-%m-%d)
    config="/etc/xray/config.json"
    
    # Add user to all VLESS inbounds
    for i in 3 6; do
        jq ".inbounds[$i].settings.clients += [{\"id\": \"$uuid\", \"email\": \"$user\"}]" $config > /tmp/config.json && mv /tmp/config.json $config
    done
    
    echo "### $user $expdate $uuid" >> /etc/xray/vless_account
    systemctl restart xray
    
    # Output links
    domain=$(cat /etc/vpn_domain 2>/dev/null || curl -s ifconfig.me)
    
    echo "Akun VLESS berhasil dibuat!"
    echo "Username: $user"
    echo "UUID: $uuid"
    echo "Expired: $expdate"
    echo ""
    echo "=== CLOUDFLARE LINKS ==="
    # Port 8443 (Cloudflare)
    vless_link_8443="vless://$uuid@$domain:8443?encryption=none&security=tls&type=ws&host=$domain&path=%2Fvless#${user}-CF8443"
    echo "Port 8443 (CF): $vless_link_8443"
    
    echo ""
    echo "=== DIRECT LINKS ==="
    # Port 2087 (Direct)
    vless_link_2087="vless://$uuid@$domain:2087?encryption=none&security=none&type=ws&host=$domain&path=%2Fvless#${user}-DIR2087"
    echo "Port 2087 (Direct): $vless_link_2087"
    
    read -n1 -r -p "Press any key..."; manage_vless
}

del_vless_account() {
    read -rp "Username: " user
    config="/etc/xray/config.json"
    uuid=$(grep "^### $user " /etc/xray/vless_account | awk '{print $3}')
    if [ -z "$uuid" ]; then
        echo "User tidak ditemukan!"; sleep 1; manage_vless; return
    fi
    idx=$(jq '.inbounds | map(.protocol == "vless") | index(true)' $config)
    jq ".inbounds[$idx].settings.clients |= map(select(.id != \"$uuid\"))" --arg idx "$idx" $config > /tmp/config.json && mv /tmp/config.json $config
    sed -i "/^### $user /d" /etc/xray/vless_account
    systemctl restart xray
    echo "Akun VLESS $user dihapus!"
    sleep 1; manage_vless
}

list_vless_account() {
    echo "==== List VLESS Account ===="
    cat /etc/xray/vless_account || echo "Belum ada akun."
    read -n1 -r -p "Press any key..."; manage_vless
}

manage_vmess() {
    clear
    echo "==== VMess Account Menu ===="
    echo "1. Add VMess Account"
    echo "2. Delete VMess Account"
    echo "3. List VMess Accounts"
    echo "0. Back"
    read -rp "Pilih menu: " vmmenu
    case $vmmenu in
        1) add_vmess_account ;;
        2) del_vmess_account ;;
        3) list_vmess_account ;;
        0) main_menu ;;
        *) echo "Invalid!"; sleep 1; manage_vmess ;;
    esac
}

add_vmess_account() {
    read -rp "Username: " user
    read -rp "Masa aktif (hari): " exp
    uuid=$(cat /proc/sys/kernel/random/uuid)
    expdate=$(date -d "+$exp days" +%Y-%m-%d)
    config="/etc/xray/config.json"
    
    # Add user to all VMess inbounds
    for i in 0 1 2 5; do
        jq ".inbounds[$i].settings.clients += [{\"id\": \"$uuid\", \"alterId\": 0, \"email\": \"$user\"}]" $config > /tmp/config.json && mv /tmp/config.json $config
    done
    
    echo "### $user $expdate $uuid" >> /etc/xray/vmess_account
    systemctl restart xray
    
    # Output links for different ports
    domain=$(cat /etc/vpn_domain 2>/dev/null || curl -s ifconfig.me)
    
    echo "Akun VMess berhasil dibuat!"
    echo "Username: $user"
    echo "UUID: $uuid"
    echo "Expired: $expdate"
    echo ""
    echo "=== CLOUDFLARE LINKS ==="
    # Port 80 (Cloudflare HTTP)
    vmess_json_80="{\"v\":\"2\",\"ps\":\"$user-CF80\",\"add\":\"$domain\",\"port\":\"80\",\"id\":\"$uuid\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"$domain\",\"path\":\"/vmess\",\"tls\":\"none\"}"
    vmess_link_80="vmess://$(echo -n $vmess_json_80 | base64 -w 0)"
    echo "Port 80 (HTTP): $vmess_link_80"
    
    # Port 443 (Cloudflare HTTPS)
    vmess_json_443="{\"v\":\"2\",\"ps\":\"$user-CF443\",\"add\":\"$domain\",\"port\":\"443\",\"id\":\"$uuid\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"$domain\",\"path\":\"/vmess\",\"tls\":\"tls\"}"
    vmess_link_443="vmess://$(echo -n $vmess_json_443 | base64 -w 0)"
    echo "Port 443 (HTTPS): $vmess_link_443"
    
    echo ""
    echo "=== DIRECT LINKS ==="
    # Port 8080 (Direct)
    vmess_json_8080="{\"v\":\"2\",\"ps\":\"$user-DIR8080\",\"add\":\"$domain\",\"port\":\"8080\",\"id\":\"$uuid\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"$domain\",\"path\":\"/vmess\",\"tls\":\"none\"}"
    vmess_link_8080="vmess://$(echo -n $vmess_json_8080 | base64 -w 0)"
    echo "Port 8080 (Direct): $vmess_link_8080"
    
    # Port 2083 (Direct)
    vmess_json_2083="{\"v\":\"2\",\"ps\":\"$user-DIR2083\",\"add\":\"$domain\",\"port\":\"2083\",\"id\":\"$uuid\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"$domain\",\"path\":\"/vmess\",\"tls\":\"none\"}"
    vmess_link_2083="vmess://$(echo -n $vmess_json_2083 | base64 -w 0)"
    echo "Port 2083 (Direct): $vmess_link_2083"
    
    read -n1 -r -p "Press any key..."; manage_vmess
}

del_vmess_account() {
    read -rp "Username: " user
    config="/etc/xray/config.json"
    uuid=$(grep "^### $user " /etc/xray/vmess_account | awk '{print $3}')
    if [ -z "$uuid" ]; then
        echo "User tidak ditemukan!"; sleep 1; manage_vmess; return
    fi
    # Hapus dari config
    jq "(.inbounds[0].settings.clients) |= map(select(.id != \"$uuid\"))" $config > /tmp/config.json && mv /tmp/config.json $config
    sed -i "/^### $user /d" /etc/xray/vmess_account
    systemctl restart xray
    echo "Akun VMess $user dihapus!"
    sleep 1; manage_vmess
}

list_vmess_account() {
    echo "==== List VMess Account ===="
    cat /etc/xray/vmess_account || echo "Belum ada akun."
    read -n1 -r -p "Press any key..."; manage_vmess
}

manage_trojan() {
    clear
    echo "==== Trojan Account Menu ===="
    echo "1. Add Trojan Account"
    echo "2. Delete Trojan Account"
    echo "3. List Trojan Accounts"
    echo "0. Back"
    read -rp "Pilih menu: " trmenu
    case $trmenu in
        1) add_trojan_account ;;
        2) del_trojan_account ;;
        3) list_trojan_account ;;
        0) main_menu ;;
        *) echo "Invalid!"; sleep 1; manage_trojan ;;
    esac
}

add_trojan_account() {
    read -rp "Username: " user
    read -rp "Masa aktif (hari): " exp
    pass=$(cat /proc/sys/kernel/random/uuid)
    expdate=$(date -d "+$exp days" +%Y-%m-%d)
    config="/etc/xray/config.json"
    
    # Add user to all Trojan inbounds
    for i in 4 7; do
        jq ".inbounds[$i].settings.clients += [{\"password\": \"$pass\", \"email\": \"$user\"}]" $config > /tmp/config.json && mv /tmp/config.json $config
    done
    
    echo "### $user $expdate $pass" >> /etc/xray/trojan_account
    systemctl restart xray
    
    # Output links
    domain=$(cat /etc/vpn_domain 2>/dev/null || curl -s ifconfig.me)
    
    echo "Akun Trojan berhasil dibuat!"
    echo "Username: $user"
    echo "Password: $pass"
    echo "Expired: $expdate"
    echo ""
    echo "=== CLOUDFLARE LINKS ==="
    # Port 2053 (Cloudflare)
    trojan_link_2053="trojan://$pass@$domain:2053?type=ws&security=tls&host=$domain&path=%2Ftrojan#${user}-CF2053"
    echo "Port 2053 (CF): $trojan_link_2053"
    
    echo ""
    echo "=== DIRECT LINKS ==="
    # Port 2096 (Direct)
    trojan_link_2096="trojan://$pass@$domain:2096?type=ws&security=none&host=$domain&path=%2Ftrojan#${user}-DIR2096"
    echo "Port 2096 (Direct): $trojan_link_2096"
    
    read -n1 -r -p "Press any key..."; manage_trojan
}

del_trojan_account() {
    read -rp "Username: " user
    config="/etc/xray/config.json"
    pass=$(grep "^### $user " /etc/xray/trojan_account | awk '{print $3}')
    if [ -z "$pass" ]; then
        echo "User tidak ditemukan!"; sleep 1; manage_trojan; return
    fi
    idx=$(jq '.inbounds | map(.protocol == "trojan") | index(true)' $config)
    jq ".inbounds[$idx].settings.clients |= map(select(.password != \"$pass\"))" --arg idx "$idx" $config > /tmp/config.json && mv /tmp/config.json $config
    sed -i "/^### $user /d" /etc/xray/trojan_account
    systemctl restart xray
    echo "Akun Trojan $user dihapus!"
    sleep 1; manage_trojan
}

list_trojan_account() {
    echo "==== List Trojan Account ===="
    cat /etc/xray/trojan_account || echo "Belum ada akun."
    read -n1 -r -p "Press any key..."; manage_trojan
}

change_domain() {
    clear
    echo "==== Change Domain ===="
    current_domain=$(cat /etc/vpn_domain 2>/dev/null || curl -s ifconfig.me)
    echo "Current Domain: $current_domain"
    read -rp "New Domain: " new_domain
    if [ -z "$new_domain" ]; then
        echo "Domain tidak boleh kosong!"; sleep 1; main_menu; return
    fi
    
    # Save new domain
    echo "$new_domain" > /etc/vpn_domain
    
    # Update banner
    sed -i "s/Host: .*/Host: $new_domain/" /etc/ssh/banner 2>/dev/null
    
    # Update nginx config
    sed -i "s/server_name .*/server_name $new_domain;/" /etc/nginx/sites-available/default 2>/dev/null
    
    # Reload nginx (not restart to avoid downtime)
    systemctl reload nginx
    
    echo "Domain berhasil diubah ke: $new_domain"
    echo "Services updated successfully!"
    sleep 1; main_menu
}

change_banner() {
    clear
    echo "==== Change Banner ===="
    read -rp "Masukkan banner baru: " banner
    if [ -z "$banner" ]; then
        echo "Banner tidak boleh kosong!"; sleep 1; main_menu; return
    fi
    echo "$banner" > /etc/ssh/banner
    echo "Banner berhasil diubah!"
    systemctl restart ssh dropbear
    sleep 1; main_menu
}
check_ports() { ss -tuln; read -n1 -r -p "Press any key..."; main_menu; }
restart_services() {
    echo "Restarting all services safely..."
    
    # Restart core services
    systemctl restart nginx 2>/dev/null
    systemctl restart dropbear 2>/dev/null
    systemctl restart xray 2>/dev/null
    systemctl restart squid 2>/dev/null
    
    # Check and restart stunnel if exists
    if systemctl list-unit-files | grep -q stunnel5; then
        systemctl restart stunnel5 2>/dev/null
    elif systemctl list-unit-files | grep -q stunnel4; then
        systemctl restart stunnel4 2>/dev/null
    fi
    
    # Check and restart openvpn if exists
    if systemctl list-unit-files | grep -q openvpn@server; then
        systemctl restart openvpn@server 2>/dev/null
    elif systemctl list-unit-files | grep -q openvpn; then
        systemctl restart openvpn 2>/dev/null
    fi
    
    echo "All services restarted successfully!"
    sleep 1; main_menu;
}
show_all_accounts() {
    echo "== SSH =="; cat /etc/ssh/ssh_account 2>/dev/null || echo "-";
    echo "== VMess =="; cat /etc/xray/vmess_account 2>/dev/null || echo "-";
    echo "== VLESS =="; cat /etc/xray/vless_account 2>/dev/null || echo "-";
    echo "== Trojan =="; cat /etc/xray/trojan_account 2>/dev/null || echo "-";
    read -n1 -r -p "Press any key..."; main_menu;
}

# Fungsi Auto Renew
renew_account() {
    clear
    echo "==== Auto Renew Account ===="
    echo "1. Renew SSH Account"
    echo "2. Renew VMess Account"
    echo "3. Renew VLESS Account"
    echo "4. Renew Trojan Account"
    echo "0. Back"
    read -rp "Pilih menu: " renewmenu
    case $renewmenu in
        1) renew_ssh ;;
        2) renew_vmess ;;
        3) renew_vless ;;
        4) renew_trojan ;;
        0) main_menu ;;
        *) echo "Invalid!"; sleep 1; renew_account ;;
    esac
}

renew_ssh() {
    read -rp "Username: " user
    read -rp "Tambah hari: " days
    if ! id "$user" &>/dev/null; then
        echo "User tidak ditemukan!"; sleep 1; renew_account; return
    fi
    current_exp=$(chage -l $user | grep "Account expires" | awk -F": " '{print $2}')
    new_exp=$(date -d "$current_exp + $days days" +%Y-%m-%d)
    chage -E $new_exp $user
    sed -i "s/^### $user .*/### $user $new_exp/" /etc/ssh/ssh_account
    echo "SSH Account $user renewed until $new_exp"
    sleep 1; renew_account
}

renew_vmess() {
    read -rp "Username: " user
    read -rp "Tambah hari: " days
    if ! grep -q "^### $user " /etc/xray/vmess_account; then
        echo "User tidak ditemukan!"; sleep 1; renew_account; return
    fi
    current_exp=$(grep "^### $user " /etc/xray/vmess_account | awk '{print $2}')
    new_exp=$(date -d "$current_exp + $days days" +%Y-%m-%d)
    sed -i "s/^### $user .*/### $user $new_exp/" /etc/xray/vmess_account
    echo "VMess Account $user renewed until $new_exp"
    sleep 1; renew_account
}

renew_vless() {
    read -rp "Username: " user
    read -rp "Tambah hari: " days
    if ! grep -q "^### $user " /etc/xray/vless_account; then
        echo "User tidak ditemukan!"; sleep 1; renew_account; return
    fi
    current_exp=$(grep "^### $user " /etc/xray/vless_account | awk '{print $2}')
    new_exp=$(date -d "$current_exp + $days days" +%Y-%m-%d)
    sed -i "s/^### $user .*/### $user $new_exp/" /etc/xray/vless_account
    echo "VLESS Account $user renewed until $new_exp"
    sleep 1; renew_account
}

renew_trojan() {
    read -rp "Username: " user
    read -rp "Tambah hari: " days
    if ! grep -q "^### $user " /etc/xray/trojan_account; then
        echo "User tidak ditemukan!"; sleep 1; renew_account; return
    fi
    current_exp=$(grep "^### $user " /etc/xray/trojan_account | awk '{print $2}')
    new_exp=$(date -d "$current_exp + $days days" +%Y-%m-%d)
    sed -i "s/^### $user .*/### $user $new_exp/" /etc/xray/trojan_account
    echo "Trojan Account $user renewed until $new_exp"
    sleep 1; renew_account
}

# Fungsi System Information
system_info() {
    clear
    echo "==== System Information ===="
    echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)"
    echo "RAM: $(free -h | grep Mem | awk '{print $2}')"
    echo "Disk: $(df -h / | tail -1 | awk '{print $2}')"
    echo "Uptime: $(uptime -p)"
    echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo "IP Address: $(curl -s ifconfig.me)"
    echo "Domain: $(cat /etc/vpn_domain 2>/dev/null || echo 'Not set')"
    read -n1 -r -p "Press any key..."; main_menu
}

# Fungsi Speedtest
speed_test() {
    clear
    echo "==== Speedtest ===="
    if ! command -v speedtest-cli &>/dev/null; then
        echo "Installing speedtest-cli..."
        apt install -y speedtest-cli
    fi
    echo "Testing download/upload speed..."
    speedtest-cli --simple
    read -n1 -r -p "Press any key..."; main_menu
}

# Fungsi Backup Config
backup_config() {
    clear
    echo "==== Backup Configuration ===="
    backup_dir="/root/vpn_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup config files
    cp -r /etc/xray "$backup_dir/"
    cp -r /etc/ssh "$backup_dir/"
    cp /etc/nginx/sites-available/default "$backup_dir/" 2>/dev/null
    cp /etc/dropbear/dropbear.conf "$backup_dir/" 2>/dev/null
    cp /etc/squid/squid.conf "$backup_dir/" 2>/dev/null
    
    # Backup account files
    cp /etc/ssh/ssh_account "$backup_dir/" 2>/dev/null
    cp /etc/xray/vmess_account "$backup_dir/" 2>/dev/null
    cp /etc/xray/vless_account "$backup_dir/" 2>/dev/null
    cp /etc/xray/trojan_account "$backup_dir/" 2>/dev/null
    
    # Create restore script
    cat > "$backup_dir/restore.sh" <<'EOF'
#!/bin/bash
# Restore VPN Configuration
if [[ $EUID -ne 0 ]]; then
   echo "Script harus dijalankan sebagai root!" 
   exit 1
fi

echo "Restoring VPN configuration..."
cp -r xray/* /etc/xray/
cp -r ssh/* /etc/ssh/
cp default /etc/nginx/sites-available/ 2>/dev/null
cp dropbear.conf /etc/dropbear/ 2>/dev/null
cp squid.conf /etc/squid/ 2>/dev/null

systemctl restart xray nginx dropbear squid
echo "Restore completed!"
EOF
    chmod +x "$backup_dir/restore.sh"
    
    # Create archive
    tar -czf "$backup_dir.tar.gz" -C /root "$(basename $backup_dir)"
    rm -rf "$backup_dir"
    
    echo "Backup saved to: $backup_dir.tar.gz"
    echo "To restore: tar -xzf $backup_dir.tar.gz && cd $(basename $backup_dir) && ./restore.sh"
    read -n1 -r -p "Press any key..."; main_menu
}

# Fungsi Auto Reboot
auto_reboot() {
    clear
    echo "==== Auto Reboot ===="
    echo "1. Reboot Now"
    echo "2. Schedule Reboot (in minutes)"
    echo "3. Cancel Scheduled Reboot"
    echo "0. Back"
    read -rp "Pilih menu: " rebootmenu
    case $rebootmenu in
        1) echo "Rebooting in 5 seconds..."; sleep 5; reboot ;;
        2) 
            read -rp "Reboot in minutes: " minutes
            if [[ $minutes =~ ^[0-9]+$ ]]; then
                echo "System will reboot in $minutes minutes"
                shutdown -r +$minutes
            else
                echo "Invalid input!"; sleep 1
            fi
            auto_reboot
            ;;
        3) shutdown -c; echo "Scheduled reboot cancelled"; sleep 1; auto_reboot ;;
        0) main_menu ;;
        *) echo "Invalid!"; sleep 1; auto_reboot ;;
    esac
}

# Fungsi Install SSL Certificate
install_ssl() {
    clear
    echo "==== Install SSL Certificate ===="
    read -rp "Domain: " domain
    if [ -z "$domain" ]; then
        echo "Domain tidak boleh kosong!"; sleep 1; main_menu; return
    fi
    
    # Install certbot
    if ! command -v certbot &>/dev/null; then
        apt install -y certbot python3-certbot-nginx
    fi
    
    # Get SSL certificate
    certbot --nginx -d $domain --non-interactive --agree-tos --email admin@$domain
    
    # Update Xray config to use SSL
    if [ -f "/etc/letsencrypt/live/$domain/fullchain.pem" ]; then
        # Update config to use SSL certificates
        echo "SSL certificate installed successfully!"
        echo "Please update Xray config manually to use SSL certificates"
    else
        echo "Failed to install SSL certificate"
    fi
    
    read -n1 -r -p "Press any key..."; main_menu
}

# Fungsi Monitoring Bandwidth
monitor_bandwidth() {
    clear
    echo "==== Bandwidth Monitoring ===="
    echo "Network interfaces:"
    ip -br addr show
    echo ""
    echo "Current bandwidth usage:"
    if command -v iftop &>/dev/null; then
        iftop -t -s 10
    else
        echo "iftop not installed. Installing..."
        apt install -y iftop
        iftop -t -s 10
    fi
    read -n1 -r -p "Press any key..."; main_menu
}

# Jalankan instalasi jika belum pernah
if [ ! -f /etc/vpn_installed ]; then
    echo "[INFO] Instalasi layanan VPN..."
    input_domain # Call input_domain here
    install_services
    touch /etc/vpn_installed
    echo "[INFO] Instalasi selesai!"
    sleep 2
fi

# Buat file dummy akun jika belum ada
mkdir -p /etc/ssh /etc/xray
for f in ssh_account vmess_account vless_account trojan_account; do
    [ ! -f /etc/ssh/$f ] && touch /etc/ssh/$f
    [ ! -f /etc/xray/$f ] && touch /etc/xray/$f
done

# Pastikan Xray config ada
if [ ! -f /etc/xray/config.json ]; then
    cat > /etc/xray/config.json <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vmess"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF
fi

# Tampilkan menu utama
main_menu