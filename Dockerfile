# Указываем базовый образ Python
FROM python:3.9-slim

# Устанавливаем необходимые зависимости (если есть requirements.txt)
# Копируем файл зависимостей и устанавливаем их
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем исходный код приложения в контейнер
COPY . /app
WORKDIR /app

# Указываем переменную среды PORT (необязательно, Render автоматически задаст её)
ENV PORT 8080

# Пример кода, который будет запущен
# CMD команда должна быть настроена на запуск твоего приложения
CMD ["python", "app.py"]

# Указываем, что контейнер должен слушать на порту $PORT
EXPOSE 8080

RUN pip install -r requirements.txt

