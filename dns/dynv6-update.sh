#!/bin/bash
TOKEN="ke5gDKehuikdjDEnekSWO2Di23Kid9"
HOSTNAMES=("MYSERVER.dynv6.net" "SECONDDOMAIN.dynv6.net")
SLEEP=30s

OLD=""

while true; do
    ADDRESS=$(ip -6 addr list scope global $device | grep "$mac_id" | sed -n 's/.*inet6 \([0-9a-f:]\+\).*/\1/p' | head -n 1)
    
    if [ -z "$ADDRESS" ]; then
        echo "no IPv6 address found"
        exit 1
    fi
    
    # address with netmask
    CURRENT=$ADDRESS/128
    
    if [ "$OLD" != "$CURRENT" ]; then
        echo "IPv6 address changed: $CURRENT"
        for HOST in "${HOSTNAMES[@]}"; do
            wget -O- -q "https://dynv6.com/api/update?hostname=$HOST&ipv6=$CURRENT&token=$TOKEN" 2>/dev/null
            #curl -fsS "http://dynv6.com/api/update?hostname=$HOST&ipv6=$CURRENT&token=$TOKEN"
        done
        
        echo ""
        
        OLD=$CURRENT
    fi
    
    sleep $SLEEP
done
