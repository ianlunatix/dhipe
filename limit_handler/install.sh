#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
set -e

# Download monitor-quota.py
echo "✅ Downloading monitor_quota.py..."
wget -O /usr/bin/monitor_quota.py https://raw.githubusercontent.com/ianlunatix/dhipe/main/limit_handler/monitor_quota.py

# Download autokill.py
echo "✅ Downloading monitor_autokill.py..."
wget -O /usr/bin/monitor_autokill.py https://raw.githubusercontent.com/ianlunatix/dhipe/main/limit_handler/monitor_autokill.py

# Set permission monitor_quota.py
chmod +x /usr/bin/monitor_quota.py

# set permission autokill.py
chmod +x /usr/bin/monitor_autokill.py

# Buat log file jika belum ada
touch /var/log/lunatic_quota_monitor.log
chmod 644 /var/log/lunatic_quota_monitor.log

# Buat systemd service
echo "⚙️ Membuat service systemd..."
cat > /etc/systemd/system/monitor-quota.service <<-EOF
[Unit]
Description=Auto Monitor Xray Quota & Device
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/env python3 /usr/bin/monitor_quota.py
Restart=always
RestartSec=10
StandardOutput=append:/var/log/lunatic_quota_monitor.log
StandardError=append:/var/log/lunatic_quota_monitor.log

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/monitor-autokill.service <<-EOF 
[Unit]
Description=AutoKill IP Limit for XRAY/SSH Users
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/bin/monitor_autokill.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Reload dan aktifkan service
echo "🚀 Mengaktifkan service..."
systemctl daemon-reexec
systemctl daemon-reload

# QUOTA MONITOR
systemctl enable monitor-quota
systemctl start monitor-quota

# AUTOKILL
systemctl enable monitor-autokill
systemctl start monitor-autokill


echo "✅ Instalasi selesai!"
