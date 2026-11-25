#!/usr/bin/env python3
import base64
import re
import time
from botocore.exceptions import ClientError
import uuid
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from contextlib import closing
import json
import os

import boto3
import psycopg2


def decode_jwt_part(part):
    padding = "=" * (-len(part) % 4)
    return json.loads(
        base64.urlsafe_b64decode(part + padding).decode("utf-8")
    )


def get_authenticated_identity(headers):
    token = headers.get("x-amzn-oidc-data")
    forwarded_sub = headers.get("x-amzn-oidc-identity")

    if not token or not forwarded_sub:
        raise ValueError("Authentication identity missing")

    parts = token.split(".")

    if len(parts) != 3:
        raise ValueError("Invalid authentication token")

    jwt_header = decode_jwt_part(parts[0])
    claims = decode_jwt_part(parts[1])

    expected_alb = os.environ.get("UTC_AUTH_ALB_ARN", "")
    expected_client = os.environ.get("UTC_AUTH_CLIENT_ID", "")

    if not expected_alb or not expected_client:
        raise ValueError("Authentication configuration missing")

    if jwt_header.get("alg") != "ES256":
        raise ValueError("Unexpected token algorithm")

    if jwt_header.get("signer") != expected_alb:
        raise ValueError("Unexpected token signer")

    if jwt_header.get("client") != expected_client:
        raise ValueError("Unexpected authentication client")

    try:
        expires_at = int(jwt_header.get("exp", 0))
    except (TypeError, ValueError):
        raise ValueError("Invalid token expiration")

    if expires_at <= int(time.time()):
        raise ValueError("Authentication token expired")

    subject = claims.get("sub")

    if not isinstance(subject, str) or not subject:
        raise ValueError("Authentication subject missing")

    if subject != forwarded_sub:
        raise ValueError("Authentication subject mismatch")

    email = claims.get("email")

    return {
        "sub": subject,
        "email": email if isinstance(email, str) else None
    }


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

        # AUTH-005: Authenticated student registration.
        if self.path == "/students":
            try:
                identity = get_authenticated_identity(self.headers)

                if not identity["email"]:
                    self.send_json(400, {
                        "error": "Authenticated email is required"
                    })
                    return

                length = int(self.headers.get("Content-Length", "0"))

                if length < 1 or length > 16384:
                    self.send_json(413, {
                        "error": "Invalid request size"
                    })
                    return

                data = json.loads(self.rfile.read(length))

                if not isinstance(data, dict):
                    self.send_json(400, {
                        "error": "JSON request must be an object"
                    })
                    return

                required_fields = (
                    "student_number",
                    "first_name",
                    "last_name",
                    "program"
                )

                values = {}

                for field in required_fields:
                    value = data.get(field)

                    if not isinstance(value, str) or not value.strip():
                        self.send_json(400, {
                            "error": f"Invalid {field}"
                        })
                        return

                    values[field] = value.strip()

                if not re.fullmatch(
                    r"[A-Za-z0-9-]{4,20}",
                    values["student_number"]
                ):
                    self.send_json(400, {
                        "error": "Invalid student_number"
                    })
                    return

                if len(values["first_name"]) > 100:
                    self.send_json(400, {
                        "error": "Invalid first_name"
                    })
                    return

                if len(values["last_name"]) > 100:
                    self.send_json(400, {
                        "error": "Invalid last_name"
                    })
                    return

                allowed_programs = (
                    "Cloud Engineering",
                    "Data Analytics",
                    "Cybersecurity",
                    "Mathematics"
                )

                if values["program"] not in allowed_programs:
                    self.send_json(400, {
                        "error": "Invalid program"
                    })
                    return

                secret_arn = os.environ["UTC_DB_SECRET_ARN"]

                client = boto3.client(
                    "secretsmanager",
                    region_name="us-east-1"
                )

                response = client.get_secret_value(
                    SecretId=secret_arn
                )

                secret = json.loads(response["SecretString"])
                student_id = str(uuid.uuid4())

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
                        cursor.execute("""
                            INSERT INTO students (
                                id,
                                student_number,
                                first_name,
                                last_name,
                                email,
                                program,
                                cognito_sub
                            )
                            VALUES (%s, %s, %s, %s, %s, %s, %s)
                            RETURNING
                                id,
                                enrollment_status,
                                created_at
                        """, (
                            student_id,
                            values["student_number"],
                            values["first_name"],
                            values["last_name"],
                            identity["email"].lower(),
                            values["program"],
                            identity["sub"]
                        ))

                        result = cursor.fetchone()
                        connection.commit()

                self.send_json(201, {
                    "status": "registered",
                    "student_id": str(result[0]),
                    "email": identity["email"],
                    "enrollment_status": result[1],
                    "created_at": result[2].isoformat()
                })

            except ValueError:
                self.send_json(401, {
                    "error": "Authentication required"
                })

            except psycopg2.IntegrityError:
                self.send_json(409, {
                    "error": "Student account already exists"
                })

            except Exception as error:
                print(
                    "Student registration failed:",
                    type(error).__name__,
                    flush=True
                )
                self.send_json(503, {
                    "error": "Registration unavailable"
                })

            return

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

        # Student Services homepage
        if self.path == "/":
            try:
                with open("/opt/utc-app/index.html", "rb") as homepage:
                    body = homepage.read()

                self.send_response(200)
                self.send_header("Content-Type", "text/html; charset=utf-8")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)

            except OSError:
                self.send_json(503, {
                    "error": "Homepage unavailable"
                })

            return

        # AUTH-004: Validate identity metadata forwarded by authenticated ALB.
        if self.path == "/auth/me":
            try:
                identity = get_authenticated_identity(self.headers)

                self.send_json(200, {
                    "authenticated": True,
                    "subject": identity["sub"],
                    "email": identity["email"]
                })

            except ValueError as error:
                print(
                    "Authentication validation failed:",
                    str(error),
                    flush=True
                )

                self.send_json(401, {
                    "authenticated": False,
                    "error": "Invalid authentication identity"
                })

            return
        # AUTH-005: Return only the authenticated student's profile.
        if self.path == "/students/me":
            try:
                identity = get_authenticated_identity(self.headers)

                secret_arn = os.environ["UTC_DB_SECRET_ARN"]

                client = boto3.client(
                    "secretsmanager",
                    region_name="us-east-1"
                )

                response = client.get_secret_value(
                    SecretId=secret_arn
                )

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
                        cursor.execute("""
                            SELECT
                                id,
                                student_number,
                                first_name,
                                last_name,
                                email,
                                program,
                                enrollment_status,
                                created_at
                            FROM students
                            WHERE cognito_sub = %s
                        """, (
                            identity["sub"],
                        ))

                        student = cursor.fetchone()

                if not student:
                    self.send_json(404, {
                        "error": "Student profile not found"
                    })
                    return

                self.send_json(200, {
                    "student_id": str(student[0]),
                    "student_number": student[1],
                    "first_name": student[2],
                    "last_name": student[3],
                    "email": student[4],
                    "program": student[5],
                    "enrollment_status": student[6],
                    "created_at": student[7].isoformat()
                })

            except ValueError:
                self.send_json(401, {
                    "error": "Authentication required"
                })

            except Exception as error:
                print(
                    "Student profile lookup failed:",
                    type(error).__name__,
                    flush=True
                )

                self.send_json(503, {
                    "error": "Student profile unavailable"
                })

            return

        # Application health check
        if self.path == "/health":
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

