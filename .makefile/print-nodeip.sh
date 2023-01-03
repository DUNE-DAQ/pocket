#!/bin/bash

NODEPORT_IP=$(ip -4 addr show dev "$(awk '$2 == 00000000 { print $1 }' /proc/net/route|head -1)" | awk '$1 ~ /^inet/ { sub("/.*", "", $2); print $2 }' | head -1)
echo $NODEPORT_IP
exit 0
