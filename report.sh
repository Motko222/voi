#!/bin/bash

source ~/.bash_profile
id=$FARCASTER_ID
chain=?
network=mainnet
type="hubble"
group=node

#version=$(/root/nubit-node/bin/nubit version | grep "Semantic version" | awk '{print $3}')

#health=$(curl -sS -I "http://localhost:7000/health" | head -1 | awk '{print $2}')
#if [ -z $health ]; then health=null; fi
#case $health in
# 200) status=ok ;;
# *)   status=warning;message="health - $health" ;;
#esac

service=$(sudo systemctl status farcasterd --no-pager | grep "active (running)" | wc -l)
if [ $service -ne 1 ]
then status="error"; message="service not running";
else status="ok";
fi

cat << EOF
{
  "id":"$id",
  "machine":"$MACHINE",
  "version":"$version",
  "chain":"$chain",
  "network":"$network",
  "type":"node",
  "status":"$status",
  "message":"$message",
  "service":$service,
  "health":$health,
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
    report,id=$id,machine=$MACHINE,grp=$group status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",chain=\"$chain\",network=\"$network\" $(date +%s%N) 
    "
fi
