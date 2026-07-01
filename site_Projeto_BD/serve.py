import http.server
import os
import socketserver

PORTA = 5501

os.chdir(os.path.dirname(os.path.abspath(__file__)))

with socketserver.TCPServer(("", PORTA), http.server.SimpleHTTPRequestHandler) as httpd:
    print(f"Frontend disponível em http://localhost:{PORTA}/html/index.html")
    httpd.serve_forever()
