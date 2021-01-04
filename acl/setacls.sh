#!/bin/bash


user="$1"
group="$2"
path="$3"

acloptions="g:$group:rwx,g:backup:rx,u::rwx,g::rwx,o::-"


chown -f $user:$group $path
chown -Rf $user:$group $path/[^.snapshots]*

setfacl    -b $path
setfacl -R -b $path/[^.snapshots]*

setfacl    -m $acloptions $path
setfacl -R -m $acloptions $path/[^.snapshots]*

setfacl    -d -m $acloptions $path
setfacl -R -d -m $acloptions $path/[^.snapshots]*

