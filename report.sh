#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=/root/logs/report-$folder
source /root/.bash_profile
source $path/config


cd /root/voi/bin

container=$(docker ps | grep -E "voinetwork/docker-participation-node|voinetwork/voi-node" | awk '{print $NF}')
docker_status=$(docker inspect $container | jq -r .[].State.Status)
status_file=/root/logs/voi-status
sudo ./get-node-status >$status_file

version=$(cat $status_file | grep Build | awk '{print $2}')
chain=$(cat $status_file | grep GenesisID | awk '{print $2}')

case $docker_status in
  running) status=ok ;;
  *) status="error"; message="docker not running" ;;
esac

cat >$json << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": {
         "id":"$folder",
         "machine":"$MACHINE",
         "grp":"node",
         "owner":"$OWNER"
  },
  "fields": {
        "version":"$version",
        "chain":"$chain",
        "network":"mainnet",
        "status":"$status",
        "message":"$message"
  }
}
EOF

cat $json
