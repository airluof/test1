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

# Генерация конфигурационного файла
conf=$(cat <<-EOM
[Interface]
PrivateKey = ${priv}
Address = ${client_ipv4}, ${client_ipv6}
DNS = 1.1.1.1, 2606:4700:4700::1111, 1.0.0.1, 2606:4700:4700::1001
...
[Peer]
PublicKey = ${peer_pub}
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = ${peer_endpoint}:${port}
EOM
)

# ВЫВОД КОНФИГА НА ЭКРАН
echo "${conf}"

# Кодирование и создание ссылки для скачивания
conf_base64=$(echo -n "${conf}" | base64 -w 0)
download_link="https://immalware.github.io/downloader.html?filename=WARP.conf&content=${conf_base64}"

# Сообщение о том, что сервис запущен
echo "Ваш сервис работает 🎉"
echo "Скачать конфиг файлом: ${download_link}"
