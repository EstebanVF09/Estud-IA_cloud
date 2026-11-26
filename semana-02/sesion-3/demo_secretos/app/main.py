from http.server import HTTPServer, BaseHTTPRequestHandler

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Docker Security Demo - Running")

# Laboratorio local, en el puerto 8000. No es un servicio publicado.
server = HTTPServer(("0.0.0.0", 8000), Handler)  # NOSONAR
server.serve_forever()