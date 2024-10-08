#!/bin/bash

clear
mkdir -p ~/.cloudshell && touch ~/.cloudshell/no-apt-get-warning
echo "Установка зависимостей..."
sudo apt-get update -y --fix-missing && sudo apt-get install wireguard-tools -y --fix-missing

priv="${1:-$(wg genkey)}"
pub="${2:-$(echo "${priv}" | wg pubkey)}"
api="https://api.cloudflareclient.com/v0i1909051800"
ins() { curl -s -H 'user-agent:' -H 'content-type: application/json' -X "$1" "${api}/$2" "${@:3}"; }
sec() { ins "$1" "$2" -H "authorization: Bearer $3" "${@:4}"; }
response=$(ins POST "reg" -d "{\"install_id\":\"\",\"tos\":\"$(date -u +%FT%T.000Z)\",\"key\":\"${pub}\",\"fcm_token\":\"\",\"type\":\"ios\",\"locale\":\"en_US\"}")

id=$(echo "$response" | jq -r '.result.id')
token=$(echo "$response" | jq -r '.result.token')
response=$(sec PATCH "reg/${id}" "$token" -d '{"warp_enabled":true}')
peer_pub=$(echo "$response" | jq -r '.result.config.peers[0].public_key')
peer_endpoint=$(echo "$response" | jq -r '.result.config.peers[0].endpoint.host')
client_ipv4=$(echo "$response" | jq -r '.result.config.interface.addresses.v4')
client_ipv6=$(echo "$response" | jq -r '.result.config.interface.addresses.v6')
port=$(echo "$peer_endpoint" | sed 's/.*:\([0-9]*\)$/\1/')
peer_endpoint=$(echo "$peer_endpoint" | sed 's/\(.*\):[0-9]*/162.159.193.5/')

cat <<EOL > WARP.conf
[Interface]
PrivateKey = kIlQqJ6WcZ9vkhdnhhRf8GyZOjmBuYbODkmtBpwJhnY=
Address = 172.16.0.2/32, 2606:4700:110:816b:13c6:b486:4761:1122
DNS = 1.1.1.1, 2606:4700:4700::1111, 1.0.0.1, 2606:4700:4700::1001

[Peer]
PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = 162.159.193.5:2408
EOL

clear
echo -e "\n\n\n"
[ -t 1 ] && echo "########## НАЧАЛО КОНФИГА ##########"
echo "${conf}"
[ -t 1 ] && echo "########### КОНЕЦ КОНФИГА ###########"

conf_base64=$(echo -n "${conf}" | base64 -w 0)
echo "Скачать конфиг файлом: https://immalware.github.io/downloader.html?filename=WARP.conf&content=${conf_base64}"
