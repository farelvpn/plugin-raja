#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'

IP=$(wget -qO- ifconfig.me/ip);
domain=$(cat /etc/xray/domain)

read -p "Username : " Login
read -p "Password : " Pass

#generate expired account 30 day
masa=30

# Format expired
exp_system=$(date -d "$masa days" +%Y-%m-%d)            # untuk useradd
exp_display=$(date -d "$masa days" +"%d-%m-%Y %H:%M:%S") # untuk database & notif

# Tambah user
username="$Login"
password="$Pass"
useradd -e "$exp_system" -M -N -s /bin/false "$username" && echo "$username:$password" | chpasswd

# Simpan limit ip
limit_ip="5"
echo "$limit_ip" > /etc/xray/limit/ip/ssh/$username

# Simpan database akun
cat > /etc/xray/database/ssh/$username.txt <<EOF
username: $username
password: $password
limit_ip: $limit_ip
expired: $exp_display
EOF

expi=`date -d "$masa days" +"%Y-%m-%d"`
clear
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "         SSH Account Account      " | tee -a /etc/log-create-user.log
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "Username       : $Login "
echo -e "Password       : $Pass"
echo -e "Remarks : $Login" | tee -a /etc/log-create-user.log
echo -e "Domain : $domain" | tee -a /etc/log-create-user.log
echo -e "==============================="
echo -e "Domain         : $domain"
echo -e "Host           : $IP"
echo -e "OpenSSH        : 22"
echo -e "Dropbear       : 109, 143, 69"
echo -e "SSL/TLS        : 222, 444, 777, 443"
echo -e "Port Suid      : 3128, 8080"
echo -e "Websocket HTTP: 80, 2082, 8880"
echo -e "Websocket HTTPS: 443"
echo -e "badvpn         : 7300"
echo -e "Masa Aktif     : $masaaktif Hari"
echo -e "==============================="
echo -e "PAYLOAD"                                                          
echo -e "GET / HTTP/1.1[crlf]Host: $domain[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf]Upgrade: websocket[crlf][crlf]"
echo -e "==============================="
echo -e "SETING HOST SSH"               
echo -e "bugisisendiri:80@$Login:$Pass"
echo -e "==============================="
