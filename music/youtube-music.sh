#!/bin/bash

## seperate arguments with quotes
#"$@"

if [ $# -eq 0 ]; then
  echo "usage: youtube-music VIDEO-ID [TITEL KÜNSTLER]"
  exit
fi

id=$1

tmpdir="/tmp/music"
mkdir -p $tmpdir

#echo "$id = ${#id}"

if [ ${#id} -eq 11 ]; then
  if [ ! $(find ./ "$tmpdir" -name \*"$id"\* | wc -l) -eq 0 ]; then
    if [ ! "$(find "$tmpdir" -name \*"$id"\* | wc -l)" -eq 0 ]; then
      echo "still in progress ... $id"
    else
      echo "$(find ./ -name \*"$id"\*)"
      echo "already downloaded."
    fi
    exit 0
  fi
else
  echo "No ID supplied fallback"
  fileName=$(yt-dlp --get-filename $id --restrict-filenames)
  fileName=${fileName%.*}
  if [ ! $(find ./ -name "$fileName.mp3" | wc -l) -eq 0 ]; then
    echo "already downloaded. Found file $fileName.mp3"
    exit 1
  fi
fi

fileName=$(yt-dlp --get-filename $id --restrict-filenames)
fileName=${fileName%.*}
printf -v fileNameE "%q" "$fileName"

year=$(date +"%Y")
#year="test"
if [[ ! -d "$year" ]]; then
  echo "creating $year"
  mkdir $year
fi

if [ $# -eq 3 ]; then
  echo "Tags supplied"
  title=$2
  artist=$3
  echo "Titel: $title"
  echo "Künstler: $artist"

else
  ## get infos
  echo "Tags have to be supplied manually"
  videoTitle=$(yt-dlp --get-title $id)
  uploader=$(yt-dlp --get-filename -o '%(uploader)s' $id --restrict-filenames)

  echo "$videoTitle"
  echo "$uploader"
  read -p "Title: " title
  read -p "Artist: " artist

fi

echo "DOWNLOAD"
yt-dlp -w --extract-audio --write-thumbnail --restrict-filenames -o "$tmpdir/$fileName" $id

echo "fileName $fileName"
echo "NORMALIZE"

audio=$(find $tmpdir -name "$fileNameE.*" -type f -exec file --mime-type {} \+ | awk -F: '{if ($2 ~ /video|audio/) print $1}')

echo "Audio $audio"
ffmpeg-normalize $audio -nt rms --target-level -14 -c:a libmp3lame -o "$year/$fileName.mp3"

echo "TAGS"

eyeD3 --quiet --no-color --artist="$artist" --title="$title" "$year/$fileName.mp3"

image=$(find $tmpdir -name "$fileNameE.*" -type f -exec file --mime-type {} \+ | awk -F: '{if ($2 ~/image\//) print $1}')
convert $image -fuzz 5% -trim +repage $image
if [ ! -f $tmpdir/$fileName.png ]; then
  ffmpeg -y -hide_banner -loglevel warning -i $image $tmpdir/$fileNameE.jpg
fi
mogrify -background White -alpha remove -define jpeg:extent=100KB $tmpdir/$fileName.jpg

eyeD3 --quiet --no-color --add-image "$tmpdir/$fileNameE.jpg:FRONT_COVER:$fileName.jpg" "$year/$fileName.mp3"

find $tmpdir -name "*$fileNameE*" -type f

#rm $tmpdir/$fileName.*
