#!/bin/bash

service munin-node start
tail -F /var/log/munin/munin-node.log

