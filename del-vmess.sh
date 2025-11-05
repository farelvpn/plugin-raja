#!/bin/bash

# Logic Delete user
read -p "User: " -e user
delete_user="$user"

mkdir -p /etc/xray/recovery/vmess
if [[ -f "/etc/xray/database/vmess/${delete_user}.txt" ]]; then
    mv "/etc/xray/database/vmess/${delete_user}.txt" "/etc/xray/recovery/vmess/${delete_user}.txt"
fi
if [[ -f "/etc/xray/limit/quota/vmess/${delete_user}" ]]; then
    rm -f "/etc/xray/limit/quota/vmess/${delete_user}"
fi
if [[ -f "/etc/xray/limit/ip/vmess/${delete_user}" ]]; then
    rm -f "/etc/xray/limit/ip/vmess/${delete_user}"
fi
if [[ -f "/etc/xray/usage/quota/vmess/${delete_user}" ]]; then
    rm -f "/etc/xray/usage/quota/vmess/${delete_user}"
fi
clear
sed -i "/### $delete_user /,/^}/d" /etc/xray/config.json
sed -i '/},/ { :a;N;$!ba;s/},\n\s*}/}\n}/g; }' /etc/xray/config.json
systemctl restart xray > /dev/null 2>&1
