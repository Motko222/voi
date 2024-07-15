#!/bin/bash
 
/bin/bash -c "$(curl -fsSL https://get.voi.network/swarm)"
export PATH="$PATH:/root/voi/bin" >> ~/.bashrc && source ~/.bashrc

