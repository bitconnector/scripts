#!/bin/bash
termux-wake-lock

readarray -t BACKUP < ~/storage/shared/Documents/backup.txt

RHOST="home"

for i in "${BACKUP[@]}"; do
    rsync -av -e ssh ~/storage/shared/$i $RHOST:"/home/lukas/rsyncHandy"
    if [ 0 -ne ${PIPESTATUS[0]} ]; then
        echo interrupted
        termux-wake-unlock
        termux-notification --content "Error: Music" --title "rsyncPictures"
        exit
    fi
done

termux-notification --content "Finished without errors" --title "rsyncictures"
termux-wake-unlock

#read -n 1 -p done
#exit 0

exit 1
