#!/bin/bash

# This is a script to shrink proxies for final cut pro. According to the
# follwing links, you can do this.
# http://www.fcp.co/final-cut-pro/tutorials/2004-final-cut-pro-x-and-the-cloud
# https://www.bascombproductions.com/blog/2014/11/8/cloud-editing-a-final-cut-pro-x-and-dropbox-collaborative-workflow
#

dir=${1:-'.'}
nprocs=${2:-'3'}
tmpfile=${3:-'/tmp/proxymov_flist.txt'}

#flist=($(find "$dir" -type f -name "*.mov"))
#echo $flist

flist=()
find "$dir" -type f -name "*.mov" -print0 > "$tmpfile"
while IFS=  read -r -d $'\0'; do
    flist+=("$REPLY")
done <"$tmpfile"
rm "$tmpfile"

# Convert all the CR2 files to jpg
#if command -v parallel &>/dev/null; then 
#   time nice parallel --citation -j $nprocs ufraw-batch --out-type=jpg --exposure=$exposure ::: *.CR2
#else
#   time nice ufraw-batch --out-type=jpg --exposure=$exposure *.CR2
#fi
##
# Scaling: ffmpeg -i input.jpg -vf scale=320:240 output_320x240.png

for f in "${flist[@]}"
do

   #ffmpeg -f image2 -pattern_type glob -i "*.jpg" -r 30 -s 1920x1080 -c:v prores_ks -pix_fmt yuv444p10le "${mov_name}.mov"
   w=$(ffprobe -v error -show_streams "$f"|grep width|head -n 1|cut -f 2 -d "=")
   h=$(ffprobe -v error -show_streams "$f"|grep height|head -n 1|cut -f 2 -d "=")
   cs=$(ffprobe -v error -show_streams "$f"|grep color_space|head -n 1|cut -f 2 -d "=")
   echo "$f: $w x $h"

   if [ $w = "2160" ]; then
      nw=$(($w/4))
      nh=$(($h/4))
   elif [ $h = 1080 ]; then
      nw=$(($w/2))
      nh=$(($h/2))
   else
      nw=$(($w))
      nh=$(($h))
   fi

   #if (( "$h" != "$nh" )) ; then
   if [ "$h" != 540 ] ; then
      echo "$f: $w x $h --> -2 x 540"
      ffmpeg -y -i "$f" -vf scale=-2:540 -color_primaries 1 -color_trc 1 -colorspace 1 -c:v prores -profile:v 0 -c:a pcm_s16le -movflags +write_colr "$f.tmp.mov"
      mv "$f.tmp.mov" "$f"
   fi

done

