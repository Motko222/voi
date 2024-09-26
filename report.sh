#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=~/logs/report-$folder
source ~/.bash_profile

cd ~/voi/bin

container=$(docker ps | grep -E "voinetwork/docker-participation-node|voinetwork/voi-node" | awk '{print $NF}')
docker_status=$(docker inspect $container | jq -r .[].State.Status)
status_file=~/logs/voi-status
./get-node-status >$status_file

version=$(cat $status_file | grep Build | awk '{print $2}')
chain=$(cat $status_file | grep GenesisID | awk '{print $2}')
network=$(echo $chain | cut -d- -f 1 | sed 's/voi//g')net

case $docker_status in
  running) status=ok ;;
  *) status="error"; message="docker not running" ;;
esac

cat >$json << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": {
         "id":"$VOI_ID",
         "machine":"$MACHINE",
         "grp":"node",
         "owner":"$OWNER"
  },
  "fields": {
        "version":"$version",
        "chain":"$chain",
        "network":"$network",
        "status":"$status",
        "message":"$message"
  }
}
EOF

cat $json
