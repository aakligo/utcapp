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
# Install UTC Python application
cat > /opt/utc-app/app.py <<'UTC_APP_PYTHON'
${app_code}
UTC_APP_PYTHON

chown utcapp:utcapp /opt/utc-app/app.py
chmod 640 /opt/utc-app/app.py

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
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
UTC_SYSTEMD

systemctl daemon-reload
systemctl enable --now utc-app.service
echo "UTC application server initialization completed."
