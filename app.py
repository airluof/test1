import http.server
import socketserver
import os

PORT = int(os.environ.get("PORT", 8080))

class MyHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write('<html><body><a href="/WARP.conf">Скачать WARP.conf</a></body></html>'.encode('utf-8'))

# Создаем сервер
with socketserver.TCPServer(("", PORT), MyHandler) as httpd:
    print(f"Сервер запущен на порту {PORT}")
    httpd.serve_forever()
