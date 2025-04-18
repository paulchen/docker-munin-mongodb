#!/bin/bash

SCRIPT_DIR=`dirname "$0"`

cd "$SCRIPT_DIR"

git pull || exit 1

docker pull ubuntu:plucky || exit 1

docker build . -t docker-munin-mongodb --no-cache || exit 1

if [ "$1" != "--no-systemd" ]; then
	sudo systemctl restart docker-munin-mongodb
fi

