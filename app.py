from http.server import SimpleHTTPRequestHandler
import socketserver

class CustomHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/download":
            self.send_response(200)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            # Отправляем HTML-код с ссылкой на скачивание
            self.wfile.write('<html><body><a href="/WARP.conf">Скачать WARP.conf</a></body></html>'.encode('utf-8'))
        else:
            super().do_GET()

PORT = 8080
with socketserver.TCPServer(("", PORT), CustomHandler) as httpd:
    print(f"Serving at port {PORT}")
    httpd.serve_forever()
