# Formatted Account Display

## Overview
This feature provides beautifully formatted account displays for VPN services, similar to the examples you provided. The formatted display shows account information in a clean, organized manner with proper borders and colors.

## Features

### 1. VLESS Account Display
- Shows account details with proper formatting
- Displays all connection links (TLS, non-TLS, gRPC)
- Includes domain, ports, and configuration details
- Uses the exact format you specified

### 2. SSH/OpenVPN Account Display
- Shows SSH account information with diamond borders
- Displays connection details and payloads
- Includes all port configurations
- Matches your example format exactly

### 3. VMess Account Display
- Formatted VMess account information
- Base64 encoded connection links
- All protocol details included

### 4. Trojan Account Display
- Trojan account formatting
- Connection links for all protocols
- Complete configuration details

## Usage

### Option 1: Standalone Script
```bash
./account-display.sh
```

### Option 2: Integrated in Main Script
```bash
./vpn-installer.sh
# Then select option 16: Formatted Display
```

### Option 3: Test with Sample Data
```bash
./test-formatted-display.sh
# This creates sample accounts for testing
```

## Menu Options

When you run the formatted display, you'll see:

1. **Display VLESS Account** - Show formatted VLESS account information
2. **Display SSH/OpenVPN Account** - Show formatted SSH account information
3. **Display VMess Account** - Show formatted VMess account information
4. **Display Trojan Account** - Show formatted Trojan account information
5. **List All Accounts** - Show all active accounts in a list format

## Account Creation Integration

When you create new accounts using the main script:
- After creating a VLESS account, it will automatically show the formatted display
- After creating an SSH account, it will automatically show the formatted display
- The formatted display appears after the regular account creation output

## File Structure

The script reads account information from:
- `/etc/xray/vless_account` - VLESS accounts
- `/etc/ssh/ssh_account` - SSH accounts
- `/etc/xray/vmess_account` - VMess accounts
- `/etc/xray/trojan_account` - Trojan accounts
- `/etc/vpn_domain` - Domain configuration

## Format Examples

### VLESS Account Format
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        VLESS Account
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Remarks        : ocean
Domain         : yourdomain.com
Wildcard       : (bug.com).yourdomain.com
Port TLS       : 443
Port none TLS  : 80
Port gRPC      : 443
id             : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Encryption     : none
Network        : ws
Path           : /vless
Path gRPC      : vless-grpc
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Link TLS       : vless://uuid@yourdomain.com:443?path=/vless&security=tls&encryption=none&type=ws#ocean
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Link none TLS  : vless://uuid@yourdomain.com:80?path=/vless&encryption=none&type=ws#ocean
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Link gRPC      : vless://uuid@yourdomain.com:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=bug.com#ocean
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Expired On     : 2025-08-01
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### SSH/OpenVPN Account Format
```
━━━━━━━━━━━━━━━━━◇
     SSH OPENVPN
◇━━━━━━━━━━━━━━━━━◇
Remark      : bumiayu
Username    : bumiayu
Password    : vpn
Limit IP    : 1 Device
Domain      : yourdomain.com
ISP         : Rumahweb Indonesia
OpenSSH     : 22, 80, 443
SSH WS      : 80, 8080, 8880, 2082
SSL/TLS     : 443
OVPN UDP    : 2200
◇━━━━━━━━━━━━━━━━━◇
Port 80     : yourdomain.com:80@bumiayu:vpn
Port 443    : yourdomain.com:443@bumiayu:vpn
Udp Custom  : yourdomain.com:1-65535@bumiayu:vpn
OpenVpn     : https://yourdomain.com:81/
Account     : https://yourdomain.com:81/ssh-bumiayu.txt
◇━━━━━━━━━━━━━━━━━◇
Payload WS  : GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: websocket[crlf][crlf]
◇━━━━━━━━━━━━━━━━━◇
Payload TLS : GET wss://yourdomain.com/ HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: websocket[crlf][crlf]
◇━━━━━━━━━━━━━━━━━◇
Payload ENCD: HEAD / HTTP/1.1[crlf]Host: Masukan_Bug[crlf][crlf]PATCH / HTTP/1.1[crlf]Host: [host][crlf]Upgrade: websocket[crlf][crlf][split]HTTP/ 1[crlf][crlf]
◇━━━━━━━━━━━━━━━━━◇
Expiry in  : 2025-01-01
◇━━━━━━━━━━━━━━━━━◇
```

## Requirements

- Bash shell
- Color support in terminal
- Account files must exist in the correct format
- Domain configuration file

## Notes

- The script automatically detects your domain from `/etc/vpn_domain` or uses your IP address
- All links are generated with the correct domain and account information
- The format matches exactly what you specified in your examples
- Port 80 is configured to work with Cloudflare as requested
- The display is optimized for readability and professional appearance

## Troubleshooting

If you encounter issues:
1. Make sure account files exist and have the correct format
2. Check that the domain file exists
3. Ensure you have proper permissions to read the account files
4. Verify that the account format follows: `### username expdate uuid/password`