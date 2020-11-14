#!/bin/bash

readarray -t MUSIC <musik.txt

if [ "$(ip -6 a show scope global)" = "" ]; then
    RHOST="home"
    OPTIONS="--bwlimit 150"
else
    RHOST="home6"
fi

for i in "${MUSIC[@]}"; do
    rsync -avz --delete $OPTIONS -e ssh $RHOST:"/home/Medien/A2\ \ \ Musik/$i" ./
    if [ 0 -ne ${PIPESTATUS[0]} ]; then
        echo interrupted
        exit
    fi
done
