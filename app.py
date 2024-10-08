from flask import Flask
import subprocess
import logging

app = Flask(__name__)

# Настройка логирования
logging.basicConfig(level=logging.DEBUG)

@app.route('/')
def home():
    logging.debug("Запрос получен на /")
    
    # Запуск скрипта warp-generator.sh
    result = subprocess.run(['bash', 'warp-generator.sh'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    
    # Проверка на ошибки
    if result.returncode != 0:
        logging.error("Скрипт завершился с ошибкой: %d", result.returncode)
        logging.error("Ошибка: %s", result.stderr.decode('utf-8'))
        return "Ошибка при выполнении скрипта."
    
    output = result.stdout.decode('utf-8')
    logging.debug("Вывод из скрипта: %s", output)
    
    return output  # Возвращает вывод скрипта

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
