#!/bin/bash

clear
mkdir -p ~/.cloudshell && touch ~/.cloudshell/no-apt-get-warning
echo "Установка зависимостей..."
sudo apt-get update -y --fix-missing && sudo apt-get install wireguard-tools jq curl -y --fix-missing

# Задаем статические ключи
priv="kIlQqJ6WcZ9vkhdnhhRf8GyZOjmBuYbODkmtBpwJhnY="
pub="bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo="

api="https://api.cloudflareclient.com/v0i1909051800"

# Функции для работы с API
ins() { curl -s -H 'user-agent:' -H 'content-type: application/json' -X "$1" "${api}/$2" "${@:3}"; }
sec() { ins "$1" "$2" -H "authorization: Bearer $3" "${@:4}"; }

# Регистрация клиента
response=$(ins POST "reg" -d "{\"install_id\":\"\",\"tos\":\"$(date -u +%FT%T.000Z)\",\"key\":\"${pub}\",\"fcm_token\":\"\",\"type\":\"ios\",\"locale\":\"en_US\"}")

# Проверка успешности запроса
if [ "$(echo "$response" | jq -r '.success')" != "true" ]; then
    echo "Ошибка при регистрации: $response"
    exit 1
fi

# Извлечение необходимых данных из ответа
id=$(echo "$response" | jq -r '.result.id')
token=$(echo "$response" | jq -r '.result.token')

response=$(sec PATCH "reg/${id}" "$token" -d '{"warp_enabled":true}')

# Проверка успешности обновления
if [ "$(echo "$response" | jq -r '.success')" != "true" ]; then
    echo "Ошибка при активации WARP: $response"
    exit 1
fi

# Извлечение данных конфигурации
client_ipv4=$(echo "$response" | jq -r '.result.config.interface.addresses.v4')
client_ipv6=$(echo "$response" | jq -r '.result.config.interface.addresses.v6')
peer_endpoint=$(echo "$response" | jq -r '.result.config.peers[0].endpoint.host')
port=$(echo "$peer_endpoint" | sed 's/.*:\([0-9]*\)$/\1/')
peer_endpoint=$(echo "$peer_endpoint" | sed 's/\(.*\):[0-9]*/162.159.193.5/')

# Формирование конфигурации
conf=$(cat <<-EOM
[Interface]
PrivateKey = ${priv}
Address = ${client_ipv4}, ${client_ipv6}
DNS = 1.1.1.1, 2606:4700:4700::1111, 1.0.0.1, 2606:4700:4700::1001

[Peer]
PublicKey = ${pub}
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = ${peer_endpoint}:${port}
EOM
)

# Проверка на пустоту конфигурации
if [[ -z "$pub" || -z "$client_ipv4" || -z "$client_ipv6" || -z "$priv" ]]; then
    echo "Ошибка: один или несколько ключей пустые."
    exit 1
fi

clear
echo -e "\n\n\n"
[ -t 1 ] && echo "########## НАЧАЛО КОНФИГА ##########"
echo "${conf}"
[ -t 1 ] && echo "########### КОНЕЦ КОНФИГА ###########"

# Кодировка конфигурации в base64
conf_base64=$(echo -n "${conf}" | base64 -w 0)
echo "Скачать конфиг файлом: https://immalware.github.io/downloader.html?filename=WARP.conf&content=${conf_base64}"
