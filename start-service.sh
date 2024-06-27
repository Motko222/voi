#!/bin/bash
 
sudo systemctl restart farcasterd

echo "Service started (CTRL-C to close logs)"
sudo journalctl -u farcasterd -f --no-hostname -o cat
