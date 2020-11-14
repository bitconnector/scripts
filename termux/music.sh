#!/bin/bash
termux-wake-lock

readarray -t MUSIC < ~/storage/shared/Documents/musik.txt

readarray -t AUDIOBOOKS < ~/storage/shared/Documents/audiobooks.txt

RHOST="home"

for i in "${MUSIC[@]}"; do
    rsync -av --delete -e ssh $RHOST:"/home/Medien/A2\ \ \ Musik/$i" ~/storage/music/
    if [ 0 -ne ${PIPESTATUS[0]} ]; then
        echo interrupted
        termux-wake-unlock
        termux-media-scan -r ~/storage/music/
        termux-notification --content "Error: Music" --title "rsyncMusic"
        exit
    fi
done
termux-media-scan -r ~/storage/music/

for i in "${AUDIOBOOKS[@]}"; do
    rsync -av --delete -e ssh $RHOST:"/home/Medien/A3\ \ \ Hörbücher\ und\ Geschichten/$i" ~/storage/shared/Audiobooks/
    if [ 0 -ne ${PIPESTATUS[0]} ]; then
        echo interrupted
        termux-wake-unlock
        termux-media-scan -r ~/storage/shared/Audiobooks/
        termux-notification --content "Error: Audiobooks" --title "rsyncMusic"
        exit
    fi
done
termux-media-scan -r ~/storage/shared/Audiobooks/

termux-notification --content "Finished without errors" --title "rsyncMusic"
termux-wake-unlock
#read -n 1 -p done
exit 1
