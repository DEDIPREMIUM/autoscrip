# 🌐 Cloudflare WebSocket Setup Guide

## 📋 Overview

Script VPN kita sekarang **100% support Cloudflare WebSocket** dengan port yang lengkap:

### ✅ **Port yang Didukung:**

#### **Cloudflare Proxy Ports:**
- **Port 80** - HTTP (Cloudflare Proxy)
- **Port 443** - HTTPS (Cloudflare Proxy)

#### **Direct Connection Ports:**
- **Port 8080** - VMess Direct
- **Port 8443** - VLESS Direct  
- **Port 2053** - Trojan Direct
- **Port 2083** - VMess Direct
- **Port 2087** - VLESS Direct
- **Port 2096** - Trojan Direct

## 🚀 Cara Setup Cloudflare

### **Step 1: Install Script**
```bash
# Download dan install script
wget -O install-new.sh https://raw.githubusercontent.com/your-repo/vpn-installer/main/install-new.sh
chmod +x install-new.sh
sudo bash install-new.sh
```

### **Step 2: Setup Cloudflare**
```bash
# Jalankan setup Cloudflare
wget -O cloudflare-setup.sh https://raw.githubusercontent.com/your-repo/vpn-installer/main/cloudflare-setup.sh
chmod +x cloudflare-setup.sh
sudo ./cloudflare-setup.sh
```

### **Step 3: Konfigurasi Cloudflare Dashboard**

1. **Login ke Cloudflare Dashboard**
2. **Add Site** - Tambahkan domain Anda
3. **DNS Settings** - Tambahkan A record:
   ```
   Type: A
   Name: @ (atau subdomain)
   Content: IP_SERVER_ANDA
   Proxy: ON (Orange Cloud)
   ```
4. **SSL/TLS Settings**:
   - Mode: Full (strict)
   - Edge Certificates: Always Use HTTPS
   - WebSocket: ON

### **Step 4: Buat Akun VPN**

Jalankan script utama dan buat akun:
```bash
sudo ./vpn-installer.sh
```

## 📱 Cara Penggunaan

### **VMess Account:**
Setelah buat akun VMess, Anda akan dapat:

#### **Cloudflare Links:**
- **Port 80 (HTTP)**: `vmess://...` - Untuk Cloudflare HTTP
- **Port 443 (HTTPS)**: `vmess://...` - Untuk Cloudflare HTTPS

#### **Direct Links:**
- **Port 8080**: `vmess://...` - Koneksi langsung
- **Port 2083**: `vmess://...` - Koneksi langsung

### **VLESS Account:**
#### **Cloudflare Links:**
- **Port 8443**: `vless://...` - Untuk Cloudflare

#### **Direct Links:**
- **Port 2087**: `vless://...` - Koneksi langsung

### **Trojan Account:**
#### **Cloudflare Links:**
- **Port 2053**: `trojan://...` - Untuk Cloudflare

#### **Direct Links:**
- **Port 2096**: `trojan://...` - Koneksi langsung

## 🔧 Konfigurasi Aplikasi

### **HTTP Injector:**
1. Import link Cloudflare (Port 80/443)
2. Atau gunakan link Direct (Port 8080, 2083, dll)

### **HTTP Custom:**
1. Import link VMess/VLESS/Trojan
2. Pilih link sesuai kebutuhan (Cloudflare/Direct)

### **V2RayBox:**
1. Import link yang diinginkan
2. Cloudflare untuk bypass, Direct untuk kecepatan

## ⚡ Keuntungan Cloudflare

### **Cloudflare Proxy (Port 80/443):**
✅ **Bypass Firewall** - Sulit diblokir  
✅ **SSL Otomatis** - HTTPS gratis  
✅ **CDN** - Kecepatan global  
✅ **DDoS Protection** - Keamanan tinggi  

### **Direct Connection (Port 8080+):**
✅ **Kecepatan Maksimal** - Tidak ada proxy  
✅ **Latency Rendah** - Koneksi langsung  
✅ **Stabil** - Tidak bergantung Cloudflare  

## 🛠️ Troubleshooting

### **Cloudflare Tidak Bisa Konek:**
1. **Cek DNS**: Pastikan A record benar
2. **Cek Proxy**: Orange cloud harus ON
3. **Cek SSL**: Mode Full (strict)
4. **Cek WebSocket**: Harus ON di Cloudflare

### **Direct Connection Tidak Bisa:**
1. **Cek Firewall**: Port 8080+ harus terbuka
2. **Cek ISP**: Beberapa ISP blokir port tertentu
3. **Cek Server**: Pastikan service berjalan

### **Testing Connection:**
```bash
# Test port Cloudflare
curl -I http://your-domain.com/vmess
curl -I https://your-domain.com/vmess

# Test port Direct
telnet your-domain.com 8080
telnet your-domain.com 8443
```

## 📊 Perbandingan Kecepatan

| Connection Type | Speed | Stability | Bypass |
|----------------|-------|-----------|---------|
| Cloudflare 80  | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Cloudflare 443 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Direct 8080    | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| Direct 8443    | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |

## 🔒 Keamanan

### **Cloudflare Security:**
- **DDoS Protection** - Otomatis
- **SSL/TLS** - Enkripsi end-to-end
- **Web Application Firewall** - Tambahan keamanan
- **Rate Limiting** - Mencegah abuse

### **Server Security:**
- **Firewall** - UFW aktif
- **Port Management** - Hanya port yang diperlukan
- **Service Monitoring** - Auto restart jika down

## 📞 Support

Jika mengalami masalah:
1. Jalankan `cloudflare-setup.sh` ulang
2. Cek status service: `systemctl status xray nginx`
3. Cek log: `journalctl -u xray -f`
4. Test port: `ss -tuln | grep :80`

---

**Script sudah 100% support Cloudflare WebSocket!** 🎯

Dengan fitur ini, VPN Anda akan lebih stabil, aman, dan sulit diblokir! 🚀