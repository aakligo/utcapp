#!/bin/bash
set -euo pipefail

# ============================================================
# UTC STUDENT SERVICES PORTAL
# EC2 USER DATA - AMAZON LINUX 2023
# ============================================================

# Log startup activities for troubleshooting
exec > >(tee /var/log/utc-userdata.log | logger -t utc-userdata -s 2>/dev/console) 2>&1

echo "Starting UTC application server initialization..."

# Set server hostname
hostnamectl set-hostname utc-app-server

# Create application directory
mkdir -p /opt/utc-app

# Create a dedicated application user
if ! id utcapp &>/dev/null; then
    useradd --system --home-dir /opt/utc-app --shell /sbin/nologin utcapp
fi

# Set directory ownership
chown -R utcapp:utcapp /opt/utc-app
# DB-001: Install Python database dependencies
echo "Installing PostgreSQL Python dependencies..."

dnf install -y python3-boto3 python3-psycopg2

echo "Python database dependencies installed."

# Application artifact checksum: ${app_etag}
# Download UTC backend and homepage from private S3
python3 - <<'UTC_APPLICATION_FILES'
import boto3

s3 = boto3.client("s3", region_name="us-east-1")

artifacts = (
    ("application/app.py", "/opt/utc-app/app.py"),
    ("application/index.html", "/opt/utc-app/index.html"),
)

for key, destination in artifacts:
    s3.download_file(
        "${s3_bucket_name}",
        key,
        destination
    )

print("UTC application files downloaded from S3")
UTC_APPLICATION_FILES

chown utcapp:utcapp /opt/utc-app/app.py /opt/utc-app/index.html
chmod 640 /opt/utc-app/app.py /opt/utc-app/index.html

# Create systemd service
cat > /etc/systemd/system/utc-app.service <<'UTC_SYSTEMD'
[Unit]
Description=UTC Student Services Portal
After=network.target

[Service]
Type=simple
User=utcapp
Group=utcapp
WorkingDirectory=/opt/utc-app
ExecStart=/usr/bin/python3 /opt/utc-app/app.py
Environment=PYTHONUNBUFFERED=1
Environment="UTC_DB_SECRET_ARN=${db_secret_arn}"
Environment="UTC_DB_HOST=${db_host}"
Environment="UTC_S3_BUCKET=${s3_bucket_name}"
Environment="UTC_AUTH_ALB_ARN=${auth_alb_arn}"
Environment="UTC_AUTH_CLIENT_ID=${auth_client_id}"
StandardOutput=append:/var/log/utc-app.log
StandardError=append:/var/log/utc-app.log
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
UTC_SYSTEMD

systemctl daemon-reload
systemctl enable --now utc-app.service
# Install and configure Amazon CloudWatch Agent
dnf install -y amazon-cloudwatch-agent

mkdir -p /opt/aws/amazon-cloudwatch-agent/etc

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'UTC_CW_AGENT'
${cloudwatch_agent_config}
UTC_CW_AGENT

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

echo "CloudWatch Agent configured and started."

echo "UTC application server initialization completed."

