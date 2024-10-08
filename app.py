import os
from http.server import SimpleHTTPRequestHandler
import socketserver

PORT = int(os.getenv("PORT", 8080))  # Использует переменную среды PORT или 8080 по умолчанию

Handler = SimpleHTTPRequestHandler

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving at port {PORT}")
    httpd.serve_forever()
