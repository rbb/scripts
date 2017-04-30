#!/bin/bash

# convert all .flac files in the current directory to .mp3 files

for f in *.flac
do
   #bn=$(basename "$f")
   bn=${f%.flac}
   echo $bn

   flac2mp3.sh 6 "$f" "$bn.mp3"
done
