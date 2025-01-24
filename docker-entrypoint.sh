#!/bin/bash

service munin-node start

trap 'killall tail' SIGTERM

tail -F /var/log/munin/munin-node.log &
wait $!

