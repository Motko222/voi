#!/bin/bash

source ~/.bash_profile

id=$VOI_ID
chain=testnet
network=testnet
type=node
group=node
owner=$VOI_OWNER

cd ~/voi/bin

container=$(docker ps | grep voinetwork/docker-participation-node | awk '{print $NF}')
docker_status=$(docker inspect $container | jq -r .[].State.Status)
status_file=~/logs/voi-status
./get-node-status >$status_file

version=$(cat $status_file | grep Build | awk '{print $2}')

case $docker_status in
  running) status=ok ;;
  *) status="error"; message="docker not running" ;;
esac

cat << EOF
{
  "id":"$id",
  "machine":"$MACHINE",
  "version":"$version",
  "chain":"$chain",
  "network":"$network",
  "status":"$status",
  "message":"$message",
  "updated":"$(date --utc +%FT%TZ)"
}
EOF

# send data to influxdb
if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "
    report,id=$id,machine=$MACHINE,grp=$group,owner=$owner status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",chain=\"$chain\",network=\"$network\" $(date +%s%N) 
    "
fi
