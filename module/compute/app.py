#!/usr/bin/env python3

from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from contextlib import closing
import json
import os

import boto3
import psycopg2


def check_database():
    secret_arn = os.environ["UTC_DB_SECRET_ARN"]

    client = boto3.client(
        "secretsmanager",
        region_name="us-east-1"
    )

    response = client.get_secret_value(SecretId=secret_arn)
    secret = json.loads(response["SecretString"])

    with closing(psycopg2.connect(
        host=os.environ["UTC_DB_HOST"],
        port=secret.get("port", 5432),
        dbname="utcapp",
        user=secret["username"],
        password=secret["password"],
        sslmode="require",
        connect_timeout=5
    )) as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            return cursor.fetchone()[0] == 1


class AppHandler(BaseHTTPRequestHandler):

    def send_json(self, status, data):
        body = json.dumps(data).encode("utf-8")

        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):

        if self.path in ("/", "/health"):
            self.send_json(200, {
                "status": "healthy",
                "application": "UTC Student Services Portal",
                "environment": "dev"
            })
            return

        if self.path == "/db-health":

            # Restrict database diagnostics to local requests
            if self.client_address[0] not in ("127.0.0.1", "::1"):
                self.send_error(404, "Not Found")
                return

            try:
                if check_database():
                    self.send_json(200, {
                        "database": "connected",
                        "status": "healthy"
                    })
                else:
                    self.send_json(503, {
                        "database": "unavailable"
                    })

            except Exception as error:
                print(
                    "Database health check failed:",
                    type(error).__name__,
                    flush=True
                )
                self.send_json(503, {
                    "database": "unavailable"
                })

            return

        self.send_error(404, "Not Found")


if __name__ == "__main__":
    server = ThreadingHTTPServer(("0.0.0.0", 3000), AppHandler)
    print("UTC application listening on port 3000")
    server.serve_forever()
