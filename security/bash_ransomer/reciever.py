import http.server
import socketserver
import base64

PORT = 8080
class Handler(http.server.SimpleHTTPRequestHandler):
  def do_POST(self):
    print("----HEADERS----")
    for header, value in self.headers.items():
      print(f"{header}: {value}")
    print("--------------")
    print(base64.b64decode(self.headers["Special-Delivery"]).decode('ascii'))
    print("--------------")

with socketserver.TCPServer(("",PORT), Handler) as httpd:
  print(f"Listening evilly at port {PORT}")
  httpd.serve_forever()
