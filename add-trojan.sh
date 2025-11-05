#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################

MYIP=$(curl -sS ipv4.icanhazip.com)
domain=$(cat /etc/xray/domain)
pathtrojan="/vmess"
pathtrojangprc="vmess-grpc"
none=80
tls=443
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
read -rp "User: " -e user
user_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)
if [[ ${user_EXISTS} == '1' ]]; then
clear
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "                  ${WB}Add Trojan Account${NC}                "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "${YB}A client with the specified name was already created, please choose another name.${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
exit 0;
fi
done

read -p "Password (UUID): " uuid

if [[ "$uuid" == "" ]]; then
 echo "Password is required!"
 exit 1
fi
#masa aktif akun 30 hari
duration="1460d"
quota="300"
iplimit="15"

exp=$(date -d "+$seconds seconds" +"%Y-%m-%d-%H-%M-%S")
exp_full=$exp

# Set quota and IP limit
if [[ $quota -gt 0 ]]; then
    bytes=$((quota * 1024 * 1024 * 1024))
    echo "$bytes" > "/etc/xray/limit/quota/trojan/$user"
    quota_display="${quota} GB"
else
    quota_display="Unlimited"
    bytes=0
fi

if [[ $iplimit -gt 0 ]]; then
    echo "$iplimit" > "/etc/xray/limit/ip/trojan/$user"
    iplimit_display="$iplimit"
else
    iplimit_display="Unlimited"
fi

# Add user to config
sed -i '/#trojan$/a\#@ '"$user $exp_full"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json

# Save account database
cat > /etc/xray/database/trojan/$user.txt <<EOF
username: $user
uuid: $uuid
limit_ip: $iplimit
quota: $quota
expired: $exp_full
EOF

trojanlink="trojan://$uuid@$domain:$tls?path=$pathtrojan&security=tls&host=$domain&type=ws&sni=$domain#$user"
# trojanlink1="trojan://${uuid}@$domain:$none?path=$pathtrojan&security=none&host=$domain&type=ws#$user"
trojanlink2="trojan://${uuid}@$domain:$tls?security=tls&encryption=none&type=grpc&serviceName=$pathtrojangrpc&sni=$domain#$user"
sleep 1 && systemctl restart xray > /dev/null 2>&1
clear
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "        TROJAN ACCOUNT         " | tee -a /etc/log-create-user.log
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "Remarks : ${user}" | tee -a /etc/log-create-user.log
4echo -e "Host/IP : ${domain}" | tee -a /etc/log-create-user.log
echo -e "port : ${tls}" | tee -a /etc/log-create-user.log
echo -e "Key : ${uuid}" | tee -a /etc/log-create-user.log
echo -e "Path : ${pathtrojan}" | tee -a /etc/log-create-user.log
echo -e "ServiceName : ${pathtrojangprc}" | tee -a /etc/log-create-user.log
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "Link WS : ${trojanlink}" | tee -a /etc/log-create-user.log
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "Link Non TLS : ${trojanlink2}" | tee -a /etc/log-create-user.log
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "Link GRPC : trojan://-" | tee -a /etc/log-create-user.log
echo "" | tee -a /etc/log-create-user.log
