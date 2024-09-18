#!/bin/bash

container=$(docker ps | grep -E "voinetwork/docker-participation-node|voinetwork/voi-node" | awk '{print $NF}')
docker logs --tail 100 -f $container
