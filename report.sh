#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=/root/logs/report-$folder
source /root/.bash_profile
source $path/config


cd /root/voi/bin

container=$(docker ps | grep -E "voinetwork/docker-participation-node|voinetwork/voi-node|voinetwork_algod" | awk '{print $NF}' | head -1)
docker_status=$(docker inspect $container 2>/dev/null | jq -r '.[].State.Status')
status_file=/root/logs/voi-status
sudo ./get-node-status >$status_file

version=$(cat $status_file | grep Build | awk '{print $2}')

CONTAINER_ID=$(docker ps -q -f name=voinetwork_algod)
node_status=$(docker exec $CONTAINER_ID /node/bin/goal node status 2>/dev/null)
chain=$(echo "$node_status" | grep "Genesis ID" | awk '{print $3}')
current_round=$(echo "$node_status" | grep "Last committed block" | awk '{print $4}')

acct_dump=$(docker exec $CONTAINER_ID /node/bin/goal account dump -a $WALLET 2>/dev/null)
part_online=$(echo "$acct_dump" | jq -r 'if .onl == 1 then "online" else "offline" end')
vote_lst=$(echo "$acct_dump" | jq -r '.voteLst // 0')
rounds_left=$(( vote_lst - current_round ))

case $docker_status in
  running) status=ok ;;
  *) status="error"; message="docker not running" ;;
esac
[ "$part_online" = "offline" ] && status="error" && message="participation offline"

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
        "message":"$message",
        "m1":"participation=$part_online",
        "m2":"rounds_left=$rounds_left"
  }
}
EOF

cat $json
