#!/bin/bash
# ===================================
#  All-in-One Auto Installer VPN
# ===================================
# Support: SSH, VMess, VLESS, Trojan, Nginx, Dropbear, Xray, WebSocket, Stunnel5, Squid, OpenVPN
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
NC="\e[0m"

# Fungsi Cek Status Layanan
check_service() {
    systemctl is-active --quiet "$1" && echo -e "[✔]" || echo -e "[✘]"
}

# Fungsi Cek Jumlah Akun (dummy, bisa dikembangkan)
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

# Fungsi Instalasi Layanan
install_services() {
    apt update && apt install -y nginx dropbear stunnel4 squid openvpn curl socat xz-utils wget gnupg2 lsb-release
    # Xray Core
    if ! command -v xray &>/dev/null; then
        wget -O /usr/local/bin/xray https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
        unzip Xray-linux-64.zip -d /usr/local/bin/
        chmod +x /usr/local/bin/xray
        rm -f Xray-linux-64.zip
    fi
    # Stunnel5 (build from source)
    if ! command -v stunnel5 &>/dev/null; then
        apt install -y build-essential libssl-dev
        wget https://www.stunnel.org/downloads/stunnel-5.69.tar.gz
        tar xzf stunnel-5.69.tar.gz
        cd stunnel-5.69 && ./configure && make && make install
        cd .. && rm -rf stunnel-5.69*
    fi
    # WebSocket (simple python)
    if ! command -v websocat &>/dev/null; then
        wget -O /usr/local/bin/websocat https://github.com/vi/websocat/releases/download/v1.11.0/websocat_amd64-linux
        chmod +x /usr/local/bin/websocat
    fi
}

# Fungsi Menu
main_menu() {
    clear
    echo -e "==================================="
    echo -e " ${GREEN}✅ ACTIVE VPN ACCOUNTS${NC}"
    echo -e "==================================="
    echo -e " 🔐 SSH       : $(count_ssh) user aktif"
    echo -e " 💠 VMess  : $(count_vmess) user aktif"
    echo -e " 💠 VLESS   : $(count_vless) user aktif"
    echo -e " 🔐 Trojan   : $(count_trojan) user aktif"
    echo -e "==================================="
    echo -e " 📋 SERVICE STATUS"
    echo -e "==================================="
    echo -e " 🔵 Nginx       : $(check_service nginx)"
    echo -e " 🔵 Dropbear    : $(check_service dropbear)"
    echo -e " 🔵 Xray Core   : $(check_service xray)"
    echo -e " 🔵WebSocket : $(check_service websocat)"
    echo -e " 🔵 Stunnel5    : $(check_service stunnel5)"
    echo -e " 🔵 Squid       : $(check_service squid)"
    echo -e " 🔵 OpenVPN     : $(check_service openvpn)"
    echo -e "==================================="
    echo -e " 📌 MAIN MENU"
    echo -e "==================================="
    echo -e " [1]  SSH Account "
    echo -e " [2]  VLESS Account "
    echo -e " [3]  VMess Account "
    echo -e " [4]  Trojan Account "
    echo -e " [5]  Change Domain"
    echo -e " [6]  Change Banner"
    echo -e " [7]  Check Port Status"
    echo -e " [8]  Restart All Services"
    echo -e " [9]  Show All Active Accounts"
    echo -e "==================================="
    echo -e " [0]  Exit"
    echo -e "==================================="
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
    # Pastikan inbound VLESS ada
    if ! grep -q '"protocol": "vless"' $config; then
        jq '.inbounds += [{"port": 8443, "protocol": "vless", "settings": {"clients": []}, "streamSettings": {"network": "ws", "wsSettings": {"path": "/vless"}, "security": "tls"}}]' $config > /tmp/config.json && mv /tmp/config.json $config
    fi
    # Tambah user ke clients VLESS
    idx=$(jq '.inbounds | map(.protocol == "vless") | index(true)' $config)
    jq ".inbounds[$idx].settings.clients += [{\"id\": \"$uuid\", \"email\": \"$user\"}]" --arg idx "$idx" $config > /tmp/config.json && mv /tmp/config.json $config
    echo "### $user $expdate $uuid" >> /etc/xray/vless_account
    systemctl restart xray
    # Output link
    domain=$(curl -s ifconfig.me)
    port=8443
    vless_link="vless://$uuid@$domain:$port?encryption=none&security=tls&type=ws&host=$domain&path=%2Fvless#${user}"
    echo "Akun VLESS berhasil dibuat!"
    echo "Link: $vless_link"
    echo "Expired: $expdate"
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
    # Tambah ke config Xray
    config="/etc/xray/config.json"
    if ! grep -q '"clients"' $config; then
        # Buat config minimal jika belum ada
        cat > $config <<EOF
{
  "inbounds": [
    {
      "port": 443,
      "protocol": "vmess",
      "settings": {"clients": []},
      "streamSettings": {"network": "ws", "wsSettings": {"path": "/vmess"}}
    }
  ],
  "outbounds": [{"protocol": "freedom"}]
}
EOF
    fi
    # Tambah user ke clients
    jq ".inbounds[0].settings.clients += [{\"id\": \"$uuid\", \"alterId\": 0, \"email\": \"$user\"}]" $config > /tmp/config.json && mv /tmp/config.json $config
    echo "### $user $expdate $uuid" >> /etc/xray/vmess_account
    systemctl restart xray
    # Output link
    domain=$(curl -s ifconfig.me)
    port=443
    vmess_json="{\"v\":\"2\",\"ps\":\"$user\",\"add\":\"$domain\",\"port\":\"$port\",\"id\":\"$uuid\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"$domain\",\"path\":\"/vmess\",\"tls\":\"tls\"}"
    vmess_link="vmess://$(echo -n $vmess_json | base64 -w 0)"
    echo "Akun VMess berhasil dibuat!"
    echo "Link: $vmess_link"
    echo "Expired: $expdate"
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
    # Pastikan inbound Trojan ada
    if ! grep -q '"protocol": "trojan"' $config; then
        jq '.inbounds += [{"port": 9443, "protocol": "trojan", "settings": {"clients": []}, "streamSettings": {"network": "ws", "wsSettings": {"path": "/trojan"}, "security": "tls"}}]' $config > /tmp/config.json && mv /tmp/config.json $config
    fi
    # Tambah user ke clients Trojan
    idx=$(jq '.inbounds | map(.protocol == "trojan") | index(true)' $config)
    jq ".inbounds[$idx].settings.clients += [{\"password\": \"$pass\", \"email\": \"$user\"}]" --arg idx "$idx" $config > /tmp/config.json && mv /tmp/config.json $config
    echo "### $user $expdate $pass" >> /etc/xray/trojan_account
    systemctl restart xray
    # Output link
    domain=$(curl -s ifconfig.me)
    port=9443
    trojan_link="trojan://$pass@$domain:$port?type=ws&security=tls&host=$domain&path=%2Ftrojan#${user}"
    echo "Akun Trojan berhasil dibuat!"
    echo "Link: $trojan_link"
    echo "Expired: $expdate"
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

change_domain() { echo "Fitur Change Domain belum diimplementasi."; read -n1 -r -p "Press any key..."; main_menu; }
change_banner() { echo "Fitur Change Banner belum diimplementasi."; read -n1 -r -p "Press any key..."; main_menu; }
check_ports() { ss -tuln; read -n1 -r -p "Press any key..."; main_menu; }
restart_services() {
    systemctl restart nginx dropbear xray stunnel5 squid openvpn 2>/dev/null
    echo "Semua layanan direstart!"; sleep 1; main_menu;
}
show_all_accounts() {
    echo "== SSH =="; cat /etc/ssh/ssh_account 2>/dev/null || echo "-";
    echo "== VMess =="; cat /etc/xray/vmess_account 2>/dev/null || echo "-";
    echo "== VLESS =="; cat /etc/xray/vless_account 2>/dev/null || echo "-";
    echo "== Trojan =="; cat /etc/xray/trojan_account 2>/dev/null || echo "-";
    read -n1 -r -p "Press any key..."; main_menu;
}

# Jalankan instalasi jika belum pernah
if [ ! -f /etc/vpn_installed ]; then
    echo "[INFO] Instalasi layanan VPN..."
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

# Tampilkan menu utama
main_menu