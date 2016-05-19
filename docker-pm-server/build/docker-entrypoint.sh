#!/bin/bash
set -e

if [ ! -f /srv/conf/canUpgrade ]
then
    echo 1 > /srv/conf/canUpgrade
fi

exec "$@"
