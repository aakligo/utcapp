#!/usr/bin/env python3

from http.server import BaseHTTPRequestHandler, HTTPServer
import json


class AppHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        if self.path in ("/", "/health"):
            response = {
                "status": "healthy",
                "application": "UTC Student Services Portal",
                "environment": "dev"
            }

            body = json.dumps(response).encode("utf-8")

            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        else:
            self.send_error(404, "Not Found")


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 3000), AppHandler)
    print("UTC application listening on port 3000")
    server.serve_forever()
