#!/bin/bash

sudo tee /etc/systemd/system/nubit-lightd.service > /dev/null <<EOF
[Unit]
Description=Nubit Light Client
After=network.target
StartLimitIntervalSec=0
[Service]
User=root
ExecStart=/root/scripts/nubit-light/start-light.sh
Restart=always
RestartSec=30
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable nubit-lightd

echo "Service created, start with start-service.sh"
