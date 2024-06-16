#!/bin/bash

sudo journalctl -u nubit-lightd -f --no-hostname -o cat
