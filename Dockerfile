# Указываем базовый образ Python
FROM python:3.9-slim

# Устанавливаем необходимые зависимости (если есть requirements.txt)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем исходный код приложения в контейнер
COPY . /app
WORKDIR /app

# Копируем скрипт генерации WARP.conf в рабочую директорию
COPY warp_generator.sh /app/warp_generator.sh

# Устанавливаем права на выполнение скрипта
RUN chmod +x /app/warp-generator.sh

# Генерируем WARP.conf
RUN /bin/bash /app/warp-generator.sh

# Указываем переменную среды PORT (необязательно, Render автоматически задаст её)
ENV PORT 8080

# Запускаем приложение
CMD ["python", "app.py"]

# Указываем, что контейнер должен слушать на порту $PORT
EXPOSE 8080
