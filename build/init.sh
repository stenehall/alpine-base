#!/bin/bash

PUID=${PUID:-911}
PGID=${PGID:-911}
TZ=${TZ:-Europe/Stockholm}

if [ ! "$(id -u alpine)" -eq "$PUID" ]; then usermod -o -u "$PUID" alpine ; fi
if [ ! "$(id -g alpine)" -eq "$PGID" ]; then groupmod -o -g "$PGID" alpine ; fi

chown alpine:alpine -R /home/alpine

cp /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ >  /etc/timezone

echo "
-------------------------------------
User uid:    $(id -u alpine)
User gid:    $(id -g alpine)
Timezone:    $TZ
-------------------------------------
"
/usr/sbin/sshd -D
