#!/bin/bash

for f in ./*.mp3; do
    ffmpeg-normalize -nt rms --target-level -14 $f
    rm $f
done

# using only ffmpeg to normalize
#for i in *.opus; do ffmpeg -i "$i" -filter:a loudnorm "2_$i"; done
