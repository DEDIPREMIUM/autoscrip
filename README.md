# All-in-One Auto Installer VPN

Script lengkap untuk menginstal dan mengelola server VPN dengan berbagai protokol.

## 🌟 Fitur Utama

### ✅ Protokol VPN
- **SSH** - Port 22, 443 (Dropbear/OpenSSH)
- **VMess** - Port 443 (WebSocket + TLS)
- **VLESS** - Port 8443 (WebSocket + TLS)
- **Trojan** - Port 9443 (WebSocket + TLS)

### ✅ Layanan Pendukung
- **Nginx** - Reverse proxy dan web server
- **Dropbear** - SSH server alternatif
- **Xray Core** - Multi-protocol proxy
- **WebSocket** - Transport layer
- **Stunnel5** - SSL/TLS wrapper
- **Squid** - HTTP proxy (port 3128)
- **OpenVPN** - VPN server (port 1194)

### ✅ Fitur Manajemen
- **Auto Expired** - Hapus akun otomatis saat expired
- **Auto Renew** - Perpanjang masa aktif akun
- **Custom Domain** - Ganti domain server
- **Custom Banner** - Banner SSH kustom
- **Auto Reboot** - Reboot otomatis
- **Backup Config** - Backup dan restore konfigurasi
- **System Info** - Informasi sistem
- **Speedtest** - Test kecepatan internet
- **Monitoring** - Monitoring bandwidth

## 🚀 Cara Instalasi

### Metode 1: Quick Install
```bash
wget -O install.sh https://raw.githubusercontent.com/your-repo/vpn-installer/main/install.sh
chmod +x install.sh
./install.sh
```

### Metode 2: Manual Install
```bash
# Download script
wget -O vpn-installer.sh https://raw.githubusercontent.com/your-repo/vpn-installer/main/vpn-installer.sh

# Beri izin eksekusi
chmod +x vpn-installer.sh

# Jalankan sebagai root
sudo ./vpn-installer.sh
```

## 📋 Persyaratan Sistem

- **OS**: Ubuntu 18.04+ / Debian 9+
- **RAM**: Minimal 1GB
- **Storage**: Minimal 10GB
- **Root Access**: Wajib
- **Domain**: Opsional (untuk SSL)

## 🔧 Konfigurasi Default

### Port yang Digunakan
- SSH: 22, 443
- VMess: 443 (ws+tls, path: /vmess)
- VLESS: 8443 (ws+tls, path: /vless)
- Trojan: 9443 (ws+tls, path: /trojan)
- Squid: 3128
- OpenVPN: 1194

### Path WebSocket
- VMess: `/vmess`
- VLESS: `/vless`
- Trojan: `/trojan`

## 📱 Kompatibilitas Aplikasi

Script ini kompatibel dengan aplikasi berikut:
- **HTTP Injector**
- **HTTP Custom**
- **V2RayBox**
- **V2Ray**
- **Shadowsocks**
- **Trojan**
- **OpenVPN**

## 🎯 Cara Penggunaan

### 1. Menu Utama
```
===================================
 ✅ ACTIVE VPN ACCOUNTS
===================================
 🔐 SSH       : X user aktif
 💠 VMess  : X user aktif
 💠 VLESS   : X user aktif
 🔐 Trojan   : X user aktif
===================================
 📋 SERVICE STATUS
===================================
 🔵 Nginx       : [✔]
 🔵 Dropbear    : [✔]
 🔵 Xray Core   : [✔]
 🔵WebSocket :[✔]
 🔵 Stunnel5    : [✔]
 🔵 Squid       : [✔]
 🔵 OpenVPN     : [✔]
===================================
 📌 MAIN MENU
===================================
 [1]  SSH Account 
 [2]  VLESS Account 
 [3]  VMess Account 
 [4]  Trojan Account 
 [5]  Change Domain
 [6]  Change Banner
 [7]  Check Port Status
 [8]  Restart All Services
 [9]  Show All Active Accounts
 [10] Auto Expired Accounts
 [11] Auto Renew Account
 [12] System Information
 [13] Speedtest
 [14] Backup Config
 [15] Auto Reboot
===================================
 [0]  Exit
===================================
```

### 2. Manajemen Akun
Setiap protokol memiliki menu:
- **Add Account** - Tambah akun baru
- **Delete Account** - Hapus akun
- **List Accounts** - Tampilkan semua akun

### 3. Auto Expired
- Akun expired otomatis dihapus setiap hari jam 2 pagi
- Bisa dijalankan manual dari menu

### 4. Auto Renew
- Perpanjang masa aktif akun
- Mendukung semua protokol

## 🔒 Keamanan

### Tips Keamanan
1. **Ganti Port Default** - Ubah port SSH dari 22
2. **Gunakan Firewall** - Aktifkan UFW atau iptables
3. **Update Regular** - Update sistem secara berkala
4. **Backup Config** - Backup konfigurasi secara rutin
5. **Monitor Logs** - Pantau log untuk aktivitas mencurigakan

### Firewall Setup
```bash
# Install UFW
apt install ufw

# Allow SSH
ufw allow ssh

# Allow VPN ports
ufw allow 443/tcp
ufw allow 8443/tcp
ufw allow 9443/tcp
ufw allow 3128/tcp
ufw allow 1194/udp

# Enable firewall
ufw enable
```

## 🛠️ Troubleshooting

### Service Tidak Berjalan
```bash
# Cek status service
systemctl status xray
systemctl status nginx
systemctl status dropbear

# Restart service
systemctl restart xray
systemctl restart nginx
systemctl restart dropbear

# Cek log
journalctl -u xray -f
journalctl -u nginx -f
```

### Port Tidak Terbuka
```bash
# Cek port yang terbuka
ss -tuln

# Cek firewall
ufw status
iptables -L
```

### Akun Tidak Bisa Konek
1. Cek apakah service berjalan
2. Cek port dan path WebSocket
3. Cek config Xray: `/etc/xray/config.json`
4. Cek log Xray: `journalctl -u xray -f`

## 📞 Support

Jika mengalami masalah:
1. Cek log service
2. Pastikan semua port terbuka
3. Cek firewall settings
4. Restart semua service

## 📄 License

Script ini dibuat untuk tujuan edukasi dan penggunaan pribadi. Gunakan dengan bijak dan sesuai hukum yang berlaku.

## 🔄 Update

Untuk update script:
```bash
wget -O vpn-installer.sh https://raw.githubusercontent.com/your-repo/vpn-installer/main/vpn-installer.sh
chmod +x vpn-installer.sh
./vpn-installer.sh
```

---

**Note**: Script ini kompatibel dengan berbagai aplikasi VPN dan siap digunakan untuk server production.