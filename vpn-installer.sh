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
manage_ssh() { echo "Fitur SSH Account (add/del/renew) belum diimplementasi."; read -n1 -r -p "Press any key..."; main_menu; }
manage_vless() { echo "Fitur VLESS Account (add/del/renew) belum diimplementasi."; read -n1 -r -p "Press any key..."; main_menu; }
manage_vmess() { echo "Fitur VMess Account (add/del/renew) belum diimplementasi."; read -n1 -r -p "Press any key..."; main_menu; }
manage_trojan() { echo "Fitur Trojan Account (add/del/renew) belum diimplementasi."; read -n1 -r -p "Press any key..."; main_menu; }
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