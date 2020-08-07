#!/bin/bash

## seperate arguments with quotes
#"$@"

if [ $# -eq 0 ]
  then
    echo "usage: youtube-music VIDEO-ID [TITEL KÜNSTLER]"
    exit
fi

id=$1

tmpdir="/tmp/music"
mkdir -p $tmpdir

#echo "$id"

fileName=$(youtube-dl --get-filename $id --restrict-filenames)
fileName=${fileName%.*}

file_count=$(find ./ -name "$fileName.mp3")
file_count_n=${#file_count[0]}
if [[ $file_count_n -gt 0 ]]; then
    echo "$file_count"
    echo "already downloaded."
    exit 1
fi;


year=$(date +"%Y")
if [[ ! -d "$year" ]]
then
    echo "creating $year"
    mkdir $year
fi

if [ $# -eq 3 ]
  then
    echo "Tags supplied"
    title=$2
    artist=$3
    echo "Titel: $title"
    echo "Künstler: $artist"

  else
## get infos
    echo "Tags have to be supplied manually"
    videoTitle=$(youtube-dl --get-title $id)
    uploader=$(youtube-dl --get-filename -o '%(uploader)s' $id --restrict-filenames)

    echo "$videoTitle"
    echo "$uploader"
    read -p "Title: " title
    read -p "Artist: " artist

fi


echo "DOWNLOAD"
youtube-dl -w --extract-audio --write-thumbnail --restrict-filenames -o "$tmpdir/$fileName.opus" $id

echo "NORMALIZE"

ffmpeg-normalize $tmpdir/$fileName.opus -nt rms --target-level -14 -c:a libmp3lame -o "$year/$fileName.mp3"


echo "TAGS"

eyeD3 --quiet --no-color --artist="$artist" --title="$title" "$year/$fileName.mp3"

image=$(find $tmpdir -name "$fileName.*" -type f -exec file --mime-type {} \+ | awk -F: '{if ($2 ~/image\//) print $1}')
if [ ! -f $tmpdir/$fileName.png ]; then
    ffmpeg -y -hide_banner -loglevel warning -i $image $tmpdir/$fileName.png
fi

eyeD3 --quiet --no-color --add-image "$tmpdir/$fileName.png:FRONT_COVER:$fileName.png" "$year/$fileName.mp3"

rm $tmpdir/$fileName.*

