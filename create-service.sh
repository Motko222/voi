#!/bin/bash

sudo tee /etc/systemd/system/farcasterd.service > /dev/null <<EOF
[Unit]
Description=Farcaster Hubble Client
After=network.target
StartLimitIntervalSec=0
[Service]
User=root
ExecStart=/root/scripts/farcaster/start-hubble.sh
Restart=always
RestartSec=30
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable farcasterd

echo "Service created, start with start-service.sh"
