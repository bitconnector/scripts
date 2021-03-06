#!/bin/bash

tmpdir="/tmp/music"

for id in $*; do

  if [ ! -d "$tmpdir" ]; then
    tmpdir="."
  fi

  if [ ! $(find ./ "$tmpdir" -name \*"$id"\* | wc -l) -eq 0 ]; then
    if [ ! "$(find "$tmpdir" -name \*"$id"\* | wc -l)" -eq 0 ]; then
      echo "still in progress ... $id"
    else
      echo "already downloaded: $(find ./ -name \*"$id"\*)"
    fi

  else
    fileName=$(youtube-dl --get-filename $id --restrict-filenames)
    fileName=${fileName%.*}

    file_count=$(find ./ -name "$fileName.mp3")
    file_count_n=${#file_count[0]}
    if [[ $file_count_n -gt 0 ]]; then
      echo "$file_count"
      echo "already downloaded."

    else
      videoTitle=$(youtube-dl --get-title $id)
      uploader=$(youtube-dl --get-filename -o '%(uploader)s' $id --restrict-filenames)

      echo "Tags have to be supplied manually"
      echo "$videoTitle"
      echo "$uploader"
      read -p "Title: " title
      read -p "Artist: " artist

      ./youtube-music.sh $id "$title" "$artist" </dev/null &>/dev/null &

    fi
  fi

done

echo "-----------------------------FERTIG-----------------------------"
