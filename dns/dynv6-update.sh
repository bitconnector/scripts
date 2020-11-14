#!/bin/bash
TOKEN="ke5gDKehuikdjDEnekSWO2Di23Kid9"
HOSTNAME="MYSERVER.dynv6.net"

FILE=$HOME/.dynv6.addr6

ADDRESS=$(ip -6 addr list scope global $device | grep -v " fd" | sed -n 's/.*inet6 \([0-9a-f:]\+\).*/\1/p' | head -n 1)

[ -e $FILE ] && old=$(cat $FILE)

if [ -z "$ADDRESS" ]; then
  echo "no IPv6 address found"
  exit 1
fi

# address with netmask
CURRENT=$ADDRESS/128

if [ "$old" = "$current" ]; then
  #echo "IPv6 address unchanged"
  exit
fi

wget -O- "https://dynv6.com/api/update?hostname=$HOSTNAME&ipv6=$CURRENT&token=$TOKEN"
#curl -fsS "http://dynv6.com/api/update?hostname=$HOSTNAME&ipv6=$CURRENT&token=$TOKEN"

echo $current >$FILE
