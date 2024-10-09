import os
from http.server import SimpleHTTPRequestHandler
import socketserver

PORT = int(os.getenv("PORT", 8080))  # Использует переменную среды PORT или 8080 по умолчанию

class CustomHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            # Отправляем HTML с ссылкой на скачивание файла WARP.conf
            self.send_response(200)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write(b'<html><body><a href="/WARP.conf">Скачать WARP.conf</a></body></html>')
        else:
            # Обрабатываем остальные запросы как обычные файлы
            super().do_GET()

# Создание TCP-сервера
Handler = CustomHandler

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving at port {PORT}")
    httpd.serve_forever()
