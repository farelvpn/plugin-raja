#!/bin/bash

# Logic Delete user
read -p "User: " -e user
delete_user="$user"

mkdir -p /etc/xray/recovery/trojan
if [[ -f "/etc/xray/database/trojan/${delete_user}.txt" ]]; then
    mv "/etc/xray/database/trojan/${delete_user}.txt" "/etc/xray/recovery/trojan/${delete_user}.txt"
    echo "Database file moved to recovery directory."
fi
if [[ -f "/etc/xray/limit/quota/trojan/${delete_user}" ]]; then
    rm -f "/etc/xray/limit/quota/trojan/${delete_user}"
    echo "Quota limit file removed."
fi
if [[ -f "/etc/xray/limit/ip/trojan/${delete_user}" ]]; then
    rm -f "/etc/xray/limit/ip/trojan/${delete_user}"
    echo "IP limit file removed."
fi
if [[ -f "/etc/xray/usage/quota/trojan/${delete_user}" ]]; then
    rm -f "/etc/xray/usage/quota/trojan/${delete_user}"
    echo "Usage quota file removed."
fi

sed -i "/#@ $delete_user /,/^}/d" /etc/xray/config.json
sed -i '/},/ { :a;N;$!ba;s/},\n\s*}/}\n}/g; }' /etc/xray/config.json
systemctl restart xray > /dev/null 2>&1
