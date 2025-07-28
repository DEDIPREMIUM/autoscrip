#!/bin/bash
# ===================================
#  Fix VPN Services Script
# ===================================

echo "==================================="
echo "  Fixing VPN Services"
echo "==================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "Script harus dijalankan sebagai root!" 
   exit 1
fi

# Fix WebSocket (websocat)
echo "Fixing WebSocket..."
if ! command -v websocat &>/dev/null; then
    echo "Installing websocat..."
    wget -O /usr/local/bin/websocat https://github.com/vi/websocat/releases/download/v1.11.0/websocat_amd64-linux
    chmod +x /usr/local/bin/websocat
    echo "WebSocket installed!"
else
    echo "WebSocket already installed!"
fi

# Fix Stunnel5
echo "Fixing Stunnel5..."
if ! systemctl is-active --quiet stunnel5 2>/dev/null && ! systemctl is-active --quiet stunnel4 2>/dev/null; then
    echo "Installing Stunnel5..."
    apt update
    apt install -y build-essential libssl-dev
    
    # Try to install stunnel4 first
    if apt install -y stunnel4; then
        systemctl enable stunnel4
        systemctl start stunnel4
        echo "Stunnel4 installed and started!"
    else
        # Build from source
        wget https://www.stunnel.org/downloads/stunnel-5.69.tar.gz
        tar xzf stunnel-5.69.tar.gz
        cd stunnel-5.69 && ./configure && make && make install
        cd .. && rm -rf stunnel-5.69*
        
        # Setup Stunnel5 service
        cat > /etc/systemd/system/stunnel5.service <<EOF
[Unit]
Description=Stunnel5 SSL Wrapper
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/bin/stunnel5 /etc/stunnel5/stunnel5.conf
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
        
        # Setup Stunnel5 config
        mkdir -p /etc/stunnel5
        cat > /etc/stunnel5/stunnel5.conf <<EOF
pid = /var/run/stunnel5.pid
cert = /etc/ssl/certs/ssl-cert-snakeoil.pem
key = /etc/ssl/private/ssl-cert-snakeoil.key

[sslvpn]
accept = 443
connect = 127.0.0.1:22
EOF
        
        systemctl daemon-reload
        systemctl enable stunnel5
        systemctl start stunnel5
        echo "Stunnel5 installed and started!"
    fi
else
    echo "Stunnel already running!"
fi

# Fix OpenVPN
echo "Fixing OpenVPN..."
if ! systemctl is-active --quiet openvpn@server 2>/dev/null && ! systemctl is-active --quiet openvpn 2>/dev/null; then
    echo "Setting up OpenVPN..."
    apt install -y openvpn
    
    mkdir -p /etc/openvpn/server
    
    # Generate OpenVPN config
    cat > /etc/openvpn/server/server.conf <<EOF
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
tls-auth ta.key 0
cipher AES-256-CBC
auth SHA256
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
verb 3
explicit-exit-notify 1
EOF
    
    # Generate OpenVPN certificates if not exists
    if [ ! -f /etc/openvpn/server/ca.crt ]; then
        echo "Generating OpenVPN certificates..."
        cd /etc/openvpn/server
        
        # Generate CA
        openssl genrsa -out ca.key 2048
        openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -subj "/C=US/ST=CA/L=City/O=Organization/CN=VPN-CA"
        
        # Generate server certificate
        openssl genrsa -out server.key 2048
        openssl req -new -key server.key -out server.csr -subj "/C=US/ST=CA/L=City/O=Organization/CN=server"
        openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt
        
        # Generate DH parameters
        openssl dhparam -out dh2048.pem 2048
        
        # Generate TLS auth key
        openvpn --genkey --secret ta.key
        
        chmod 600 *.key
        chmod 644 *.crt *.pem
    fi
    
    systemctl enable openvpn@server
    systemctl start openvpn@server
    echo "OpenVPN installed and started!"
else
    echo "OpenVPN already running!"
fi

# Enable IP forwarding
echo "Enabling IP forwarding..."
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p

# Restart all services
echo "Restarting all services..."
systemctl restart nginx dropbear xray squid

if systemctl list-unit-files | grep -q stunnel5; then
    systemctl restart stunnel5
elif systemctl list-unit-files | grep -q stunnel4; then
    systemctl restart stunnel4
fi

if systemctl list-unit-files | grep -q openvpn@server; then
    systemctl restart openvpn@server
elif systemctl list-unit-files | grep -q openvpn; then
    systemctl restart openvpn
fi

echo ""
echo "==================================="
echo "  Service Status Check"
echo "==================================="
echo "Nginx: $(systemctl is-active nginx)"
echo "Dropbear: $(systemctl is-active dropbear)"
echo "Xray: $(systemctl is-active xray)"
echo "WebSocket: $(command -v websocat &>/dev/null && echo "active" || echo "inactive")"
echo "Stunnel: $(systemctl is-active stunnel5 2>/dev/null || systemctl is-active stunnel4 2>/dev/null || echo "inactive")"
echo "Squid: $(systemctl is-active squid)"
echo "OpenVPN: $(systemctl is-active openvpn@server 2>/dev/null || systemctl is-active openvpn 2>/dev/null || echo "inactive")"

echo ""
echo "==================================="
echo "  Fix Services Complete!"
echo "==================================="