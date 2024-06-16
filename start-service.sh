#!/bin/bash
 
sudo systemctl restart nubit-lightd

echo "Service started (CTRL-C to close logs)"
sudo journalctl -u nubit-lightd -f --no-hostname -o cat
