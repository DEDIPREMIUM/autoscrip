# 🚀 All-in-One Auto Installer VPN - Panduan Lengkap

## 📋 Daftar Isi
1. [Instalasi](#-instalasi)
2. [Cara Penggunaan](#-cara-penggunaan)
3. [Fitur Utama](#-fitur-utama)
4. [Troubleshooting](#-troubleshooting)
5. [FAQ](#-faq)

## 🛠️ Instalasi

### Metode 1: Quick Install (Recommended)
```bash
# Download installer
wget -O install.sh https://raw.githubusercontent.com/your-repo/vpn-installer/main/install.sh

# Beri izin eksekusi
chmod +x install.sh

# Jalankan sebagai root
sudo bash install.sh
```

### Metode 2: Manual Install
```bash
# Download script utama
wget -O vpn-installer.sh https://raw.githubusercontent.com/your-repo/vpn-installer/main/vpn-installer.sh

# Beri izin eksekusi
chmod +x vpn-installer.sh

# Jalankan sebagai root
sudo ./vpn-installer.sh
```

## 🎯 Cara Penggunaan

### 1. Menu Utama
Setelah instalasi selesai, script akan menampilkan menu utama:

```
===================================
 ✅ ACTIVE VPN ACCOUNTS
===================================
 🔐 SSH       : 0 user aktif
 💠 VMess  : 0 user aktif
 💠 VLESS   : 0 user aktif
 🔐 Trojan   : 0 user aktif
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

### 2. Membuat Akun VPN

#### SSH Account (Menu 1)
```bash
# Pilih menu 1, lalu:
1. Add SSH Account
   - Username: testuser
   - Password: testpass123
   - Masa aktif: 30 hari

# Output:
Akun SSH berhasil dibuat!
Host/IP: 123.456.789.012
Username: testuser
Password: testpass123
Port: 22, 443 (Dropbear/OpenSSH)
Expired: 2024-02-15
```

#### VMess Account (Menu 3)
```bash
# Pilih menu 3, lalu:
1. Add VMess Account
   - Username: vmessuser
   - Masa aktif: 30 hari

# Output:
Akun VMess berhasil dibuat!
Link: vmess://eyJ2IjoiMiIsInBzIjoidm1lc3N1c2VyIiwiYWRkIjoiMTIzLjQ1Ni43ODkuMDEyIi...
Expired: 2024-02-15
```

#### VLESS Account (Menu 2)
```bash
# Pilih menu 2, lalu:
1. Add VLESS Account
   - Username: vlessuser
   - Masa aktif: 30 hari

# Output:
Akun VLESS berhasil dibuat!
Link: vless://uuid@123.456.789.012:8443?encryption=none&security=tls&type=ws&host=123.456.789.012&path=%2Fvless#vlessuser
Expired: 2024-02-15
```

#### Trojan Account (Menu 4)
```bash
# Pilih menu 4, lalu:
1. Add Trojan Account
   - Username: trojanuser
   - Masa aktif: 30 hari

# Output:
Akun Trojan berhasil dibuat!
Link: trojan://password@123.456.789.012:9443?type=ws&security=tls&host=123.456.789.012&path=%2Ftrojan#trojanuser
Expired: 2024-02-15
```

### 3. Menggunakan Akun di Aplikasi

#### HTTP Injector
1. Buka HTTP Injector
2. Pilih "SSH" untuk akun SSH
3. Masukkan:
   - Host: IP server
   - Username: username
   - Password: password
   - Port: 22 atau 443

#### HTTP Custom
1. Buka HTTP Custom
2. Import link VMess/VLESS/Trojan
3. Atau scan QR code

#### V2RayBox
1. Buka V2RayBox
2. Import link VMess/VLESS/Trojan
3. Atau scan QR code

## ⭐ Fitur Utama

### ✅ Auto Expired (Menu 10)
- Hapus akun otomatis saat expired
- Berjalan setiap hari jam 2 pagi
- Bisa dijalankan manual

### ✅ Auto Renew (Menu 11)
- Perpanjang masa aktif akun
- Mendukung semua protokol
- Perpanjangan fleksibel

### ✅ Change Domain (Menu 5)
- Ganti domain server
- Update banner otomatis
- Restart service otomatis

### ✅ Change Banner (Menu 6)
- Custom banner SSH
- Tampil saat login SSH
- Update real-time

### ✅ System Info (Menu 12)
- Informasi sistem lengkap
- CPU, RAM, Disk usage
- Uptime dan load average

### ✅ Speedtest (Menu 13)
- Test kecepatan internet
- Download/Upload speed
- Auto install speedtest-cli

### ✅ Backup Config (Menu 14)
- Backup semua konfigurasi
- Script restore otomatis
- Archive format .tar.gz

### ✅ Auto Reboot (Menu 15)
- Reboot sekarang
- Schedule reboot
- Cancel scheduled reboot

## 🔧 Troubleshooting

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

# Buka port jika perlu
ufw allow 443/tcp
ufw allow 8443/tcp
ufw allow 9443/tcp
ufw allow 3128/tcp
```

### Akun Tidak Bisa Konek
1. **Cek service status** - Pastikan semua service berjalan
2. **Cek port** - Pastikan port tidak diblokir firewall
3. **Cek config** - Pastikan config Xray benar
4. **Cek log** - Lihat log untuk error detail

### Testing Script
```bash
# Jalankan script testing
chmod +x test-vpn.sh
sudo ./test-vpn.sh
```

## ❓ FAQ

### Q: Apakah script ini aman?
A: Ya, script ini dibuat dengan standar keamanan tinggi dan hanya menginstal layanan yang diperlukan.

### Q: Apakah kompatibel dengan semua aplikasi?
A: Ya, script ini kompatibel dengan HTTP Injector, HTTP Custom, V2RayBox, V2Ray, dan aplikasi VPN lainnya.

### Q: Bagaimana cara backup?
A: Gunakan menu 14 (Backup Config) untuk backup otomatis dengan script restore.

### Q: Apakah ada auto expired?
A: Ya, akun akan otomatis dihapus saat expired. Bisa diatur manual di menu 10.

### Q: Bagaimana cara ganti domain?
A: Gunakan menu 5 (Change Domain) untuk ganti domain server.

### Q: Apakah bisa renew akun?
A: Ya, gunakan menu 11 (Auto Renew) untuk perpanjang masa aktif akun.

## 📞 Support

Jika mengalami masalah:
1. Jalankan script testing: `sudo ./test-vpn.sh`
2. Cek log service: `journalctl -u xray -f`
3. Restart semua service: Menu 8
4. Backup dan restore jika perlu: Menu 14

## 🔄 Update

Untuk update script:
```bash
wget -O vpn-installer.sh https://raw.githubusercontent.com/your-repo/vpn-installer/main/vpn-installer.sh
chmod +x vpn-installer.sh
./vpn-installer.sh
```

---

**Note**: Script ini siap digunakan untuk server production dan sudah diuji dengan berbagai aplikasi VPN.