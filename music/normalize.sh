#!/bin/bash


for f in ./*.mp3; do
    ffmpeg-normalize -nt rms --target-level -14 $f
    rm $f
done

