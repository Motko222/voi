#~/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')

read -p "Sure? " sure
case $sure in  y|Y|yes|YES|Yes) ;; *) exit ;; esac

docker swarm leave --force
rm -rf ~/voi/
rm -rf /var/lib/voi
rm -rf ~/scripts/$folder
bash ~/scripts/system/delete-id.sh $folder
