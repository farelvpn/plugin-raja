#!/bin/bash

DB_PATH="/etc/xray/database/ssh"
LIMIT_PATH="/etc/xray/limit/ip/ssh"
RECOVERY_PATH="/etc/xray/recovery/ssh"

read -p "User: " -e user

Pengguna=$user

         killall -9 -u $user > /dev/null 2>&1
         userdel -f -r $user > /dev/null 2>&1
         deluser=$(ps aux | grep "${user} \[priv\]" | sort -k 72 | awk '{print $2}')
         kill "$deluser"
         userdel --force "$user"
         rm -rf "$LIMIT_PATH/$Pengguna" 2>/dev/null
         rm -rf /etc/xray/limit/ip/ssh/$Pengguna 2>/dev/null
         mv "$DB_PATH/$Pengguna.txt" "$RECOVERY_PATH/$Pengguna.txt"

clear
systemctl daemon-reload > /dev/null 2>&1
systemctl restart ssh sshd > /dev/null 2>&1
systemctl restart ssh-ws cron > /dev/null 2>&1
