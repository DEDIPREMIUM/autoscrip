#!/bin/bash
# ===================================
#  Cloudflare WebSocket Setup
# ===================================

echo "==================================="
echo "  Cloudflare WebSocket Setup"
echo "==================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "Script harus dijalankan sebagai root!" 
   exit 1
fi

# Get domain
domain=$(cat /etc/vpn_domain 2>/dev/null || curl -s ifconfig.me)
echo "Domain: $domain"

# Setup firewall for Cloudflare ports
echo "Setting up firewall for Cloudflare ports..."
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8080/tcp
ufw allow 8443/tcp
ufw allow 2053/tcp
ufw allow 2083/tcp
ufw allow 2087/tcp
ufw allow 2096/tcp
ufw allow 3128/tcp
ufw allow 1194/udp

# Update Xray config for Cloudflare
echo "Updating Xray config for Cloudflare..."
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

# Update Nginx config for Cloudflare
echo "Updating Nginx config for Cloudflare..."
cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80;
    server_name $domain;
    
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
    server_name $domain;
    
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

# Restart services
echo "Restarting services..."
systemctl restart xray nginx

# Test ports
echo "Testing Cloudflare ports..."
echo "Port 80: $(ss -tuln | grep :80 | wc -l) connections"
echo "Port 443: $(ss -tuln | grep :443 | wc -l) connections"
echo "Port 8080: $(ss -tuln | grep :8080 | wc -l) connections"
echo "Port 8443: $(ss -tuln | grep :8443 | wc -l) connections"
echo "Port 2053: $(ss -tuln | grep :2053 | wc -l) connections"
echo "Port 2083: $(ss -tuln | grep :2083 | wc -l) connections"
echo "Port 2087: $(ss -tuln | grep :2087 | wc -l) connections"
echo "Port 2096: $(ss -tuln | grep :2096 | wc -l) connections"

echo ""
echo "==================================="
echo "  Cloudflare Setup Complete!"
echo "==================================="
echo "Domain: $domain"
echo "Cloudflare Ports: 80, 443 (Proxy)"
echo "Direct Ports: 8080, 8443, 2053, 2083, 2087, 2096"
echo ""
echo "Next steps:"
echo "1. Add your domain to Cloudflare"
echo "2. Set DNS A record pointing to your server IP"
echo "3. Enable Cloudflare proxy (orange cloud)"
echo "4. Create VPN accounts using the main script"
echo "==================================="