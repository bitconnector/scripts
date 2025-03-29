#!/bin/bash

# sudo pacman -S python-eyed3
# yay -S ffmpeg-normalize

## seperate arguments with quotes
#"$@"

if [ $# -eq 0 ]; then
  echo "usage: youtube-music VIDEO-ID [TITEL KÜNSTLER]"
  exit
fi

id="$1"

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
  ide="youtube.com/watch?v=$id"
else
  echo "No ID supplied fallback"
  fileName=$(yt-dlp --get-filename $id --restrict-filenames)
  fileName=${fileName%.*}
  if [ ! $(find ./ -name "$fileName.mp3" | wc -l) -eq 0 ]; then
    echo "already downloaded. Found file $fileName.mp3"
    exit 1
  fi
fi

# fileName=$(yt-dlp --get-filename $id --restrict-filenames)
# fileName=${fileName%.*}
# printf -v fileNameE "%q" "$fileName"

year=$(date +"%Y")
#year="test"
if [[ ! -d "$year" ]]; then
  echo "creating $year"
  mkdir $year
fi

echo "DOWNLOAD"
ide="${id/-/\\-}"
echo "escaped id: $ide"
fileName="$tmpdir/$id"
#yt-dlp -w --extract-audio --write-thumbnail --restrict-filenames --write-info-json -P $tmpdir $id
yt-dlp -w --extract-audio --write-thumbnail --restrict-filenames --write-info-json -o "$fileName" "$id"

if [ $# -eq 3 ]; then
  echo "Tags supplied"
  title=$2
  artist=$3
  echo "Titel: $title"
  echo "Künstler: $artist"

else
  ## get infos
  echo "Tags have to be supplied manually"
  cat "$tmpdir/$id.info.json" | jq -r '.title'
  cat "$tmpdir/$id.info.json" | jq -r '.uploader'

  read -p "Title: " title
  read -p "Artist: " artist

fi

echo "fileName $fileName"
echo "NORMALIZE"

audio=$(find $tmpdir -name "*$id*" -type f -exec file --mime-type {} \+ | awk -F: '{if ($2 ~ /video|audio/) print $1}')

echo "Audio $audio"
#ffmpeg-normalize $audio -nt rms --target-level -14 -c:a libmp3lame -o "$year/$fileName.mp3"
#ffmpeg-normalize $audio -nt rms --target-level -14 -c:a libmp3lame -o "$fileName.mp3"
ffmpeg -i $audio -filter:a loudnorm -vn -b:a 192k "$fileName.mp3"

echo "TAGS"

eyeD3 --quiet --no-color --artist="$artist" --title="$title" "$fileName.mp3"

image=$(find $tmpdir -name "$id.*" -type f -exec file --mime-type {} \+ | awk -F: '{if ($2 ~/image\//) print $1}')
magick $image -fuzz 5% -trim +repage $image
ffmpeg -y -hide_banner -loglevel warning -i $image $fileName.jpg
mogrify -background White -alpha remove -define jpeg:extent=100KB $fileName.jpg

eyeD3 --quiet --no-color --add-image "$fileName.jpg:FRONT_COVER:$title.jpg" "$fileName.mp3"

finalName="$(echo $title | tr -s ' ' | tr ' ' '_' | tr '|' '-')-$id.mp3"
cp $fileName.mp3 $year/$finalName

tmp=$(find $tmpdir -name "*$id*" -type f)

rm $(echo $tmp | xargs)
