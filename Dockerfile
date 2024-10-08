# Используйте официальный образ Ubuntu в качестве базового
FROM ubuntu:latest

# Установите необходимые пакеты
RUN apt-get update && apt-get install -y wireguard-tools curl jq

# Скопируйте ваш скрипт в контейнер
COPY warp-generator.sh /usr/local/bin/warp-generator.sh

# Сделайте скрипт исполняемым
RUN chmod +x /usr/local/bin/warp-generator.sh

# Укажите команду, которая будет выполняться при запуске контейнера
CMD ["bash", "/usr/local/bin/warp-generator.sh"]
