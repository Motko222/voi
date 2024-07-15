#!/bin/bash

container=$(docker ps | grep voinetwork/docker-participation-node | awk '{print $NF}')
docker logs --tail 100 -f $container
