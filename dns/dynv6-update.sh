#!/bin/bash
TOKEN="ke5gDKehuikdjDEnekSWO2Di23Kid9"
HOSTNAME="MYSERVER.dynv6.net"
SLEEP=30

OLD=""

while true
do
    ADDRESS=$(ip -6 addr list scope global $device | grep -v " fd" | sed -n 's/.*inet6 \([0-9a-f:]\+\).*/\1/p' | head -n 1)
    
    if [ -z "$ADDRESS" ]; then
        echo "no IPv6 address found"
        exit 1
    fi
    
    # address with netmask
    CURRENT=$ADDRESS/128
    
    if [ "$OLD" != "$CURRENT" ]; then
        echo "IPv6 address changed: $CURRENT"
        wget -O- -q "https://dynv6.com/api/update?hostname=$HOSTNAME&ipv6=$CURRENT&token=$TOKEN" 2> /dev/null
        #curl -fsS "http://dynv6.com/api/update?hostname=$HOSTNAME&ipv6=$CURRENT&token=$TOKEN"
        
        echo ""
        
        OLD=$CURRENT
    fi
    
    sleep $SLEEP
done
