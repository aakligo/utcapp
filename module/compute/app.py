#!/usr/bin/env python3
import re
from botocore.exceptions import ClientError
import uuid
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
    def do_POST(self):

        if self.path != "/documents":
            self.send_error(404, "Not Found")
            return

        # Internal testing only until authentication is implemented
        if self.client_address[0] not in ("127.0.0.1", "::1"):
            self.send_error(404, "Not Found")
            return

        try:
            length = int(self.headers.get("Content-Length", "0"))

            if length < 1 or length > 65536:
                self.send_json(413, {"error": "Invalid document size"})
                return

            data = json.loads(self.rfile.read(length))
            content = data.get("content")

            if not isinstance(content, str) or not content:
                self.send_json(400, {"error": "Invalid document content"})
                return

            bucket = os.environ["UTC_S3_BUCKET"]
            key = "documents/" + uuid.uuid4().hex + ".txt"

            s3 = boto3.client("s3", region_name="us-east-1")

            s3.put_object(
                Bucket=bucket,
                Key=key,
                Body=content.encode("utf-8"),
                ContentType="text/plain"
            )

            self.send_json(201, {
                "status": "uploaded",
                "document_key": key
            })

        except ValueError:
            self.send_json(400, {"error": "Invalid JSON request"})

        except Exception as error:
            print("S3 upload failed:", type(error).__name__, flush=True)
            self.send_json(503, {"error": "Storage unavailable"})

    def do_GET(self):

        # Application health check
        if self.path in ("/", "/health"):
            self.send_json(200, {
                "status": "healthy",
                "application": "UTC Student Services Portal",
                "environment": "dev"
            })
            return

        # PostgreSQL health check - localhost only
        if self.path == "/db-health":

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

        # S3 document download - localhost only
        if self.path.startswith("/documents/"):

            if self.client_address[0] not in ("127.0.0.1", "::1"):
                self.send_error(404, "Not Found")
                return

            filename = self.path[len("/documents/"):]

            if not re.fullmatch(r"[0-9a-f]{32}\.txt", filename):
                self.send_json(400, {
                    "error": "Invalid document ID"
                })
                return

            key = "documents/" + filename

            try:
                bucket = os.environ["UTC_S3_BUCKET"]
                s3 = boto3.client("s3", region_name="us-east-1")

                response = s3.get_object(
                    Bucket=bucket,
                    Key=key
                )

                content = response["Body"].read().decode("utf-8")

                self.send_json(200, {
                    "status": "downloaded",
                    "document_key": key,
                    "content": content
                })

            except ClientError as error:
                code = error.response.get("Error", {}).get("Code")

                if code in ("NoSuchKey", "404", "NotFound"):
                    self.send_json(404, {
                        "error": "Document not found"
                    })
                else:
                    print("S3 download failed:", code, flush=True)
                    self.send_json(503, {
                        "error": "Storage unavailable"
                    })

            except Exception as error:
                print(
                    "S3 download failed:",
                    type(error).__name__,
                    flush=True
                )
                self.send_json(503, {
                    "error": "Storage unavailable"
                })

            return

        self.send_error(404, "Not Found")


if __name__ == "__main__":
    server = ThreadingHTTPServer(("0.0.0.0", 3000), AppHandler)
    print("UTC application listening on port 3000")
    server.serve_forever()
