#!/usr/bin/env bash
DB_PATH="/etc/xray/database/ssh"
LIMIT_PATH="/etc/xray/limit/ip/ssh"
RECOVERY_PATH="/etc/xray/recovery/ssh"

mkdir -p "$RECOVERY_PATH"

clear
echo "============================================================"
echo "                         SSH ACCOUNT LIST"
echo "============================================================"
printf "%-20s %-20s %-15s\n" "USERNAME" "EXPIRED" "STATUS"
echo "------------------------------------------------------------"

COUNT=0
for file in "$DB_PATH"/*.txt; do
    [[ ! -f "$file" ]] && continue
    USERNAME=$(basename "$file" .txt)

    # Ambil expired dari file database user
    EXPIRED=$(grep -i "expired" "$file" | awk -F': ' '{print $2}')
    [[ -z "$EXPIRED" ]] && EXPIRED="Unknown"

    # Ambil status dari passwd -S (cek apakah user masih ada di sistem)
    if getent passwd "$USERNAME" > /dev/null 2>&1; then
        STATUS=$(passwd -S "$USERNAME" | awk '{print $2}')
        if [[ "$STATUS" == "L" ]]; then
            STATUS="LOCKED"
            printf "%-20s %-20s \033[31m%-15s\033[0m\n" "$USERNAME" "$EXPIRED" "$STATUS"
        else
            STATUS="ACTIVE"
            printf "%-20s %-20s \033[32m%-15s\033[0m\n" "$USERNAME" "$EXPIRED" "$STATUS"
        fi
    else
        STATUS="REMOVED"
        printf "%-20s %-20s \033[31m%-15s\033[0m\n" "$USERNAME" "$EXPIRED" "$STATUS"
    fi

    ((COUNT++))
done

echo "------------------------------------------------------------"
echo "Total Accounts : $COUNT user(s)"
echo "============================================================"
echo ""

read -p "Username SSH to Delete : " Pengguna

if [[ -n "$Pengguna" ]]; then
    if [[ -f "$DB_PATH/$Pengguna.txt" ]]; then
        # Pindahkan file username.txt ke recovery
        mv "$DB_PATH/$Pengguna.txt" "$RECOVERY_PATH/$Pengguna.txt"

        # Hapus file limit jika ada
        rm -rf "$LIMIT_PATH/$Pengguna" 2>/dev/null
        rm -rf /etc/xray/limit/ip/ssh/$Pengguna 2>/dev/null

        # Hapus user dari sistem jika masih ada
        if getent passwd "$Pengguna" > /dev/null 2>&1; then
            userdel --force "$Pengguna" > /dev/null 2>&1
        fi

        echo "------------------------------------------------------------"
        echo "User $Pengguna has been removed and moved to recovery."
        echo "------------------------------------------------------------"

        systemctl restart dropbear ssh-ws >/dev/null 2>&1
    else
        echo "------------------------------------------------------------"
        echo "Failure: User $Pengguna does not exist in database."
        echo "------------------------------------------------------------"
    fi
else
    echo "No username entered, exiting."
fi
