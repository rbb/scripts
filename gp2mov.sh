#!/bin/sh
d=$1

# create an mov for each subdirectory
#
# ffmpeg options culled from the following sources:
# http://mewiki.project357.com/wiki/X264_Encoding_Suggestions#QuickTime-compatible_Encoding
# https://trac.ffmpeg.org/wiki/Encode/H.264
# http://en.wikipedia.org/wiki/High-definition_television
# http://en.wikibooks.org/wiki/FFMPEG_An_Intermediate_Guide/image_sequence
for f in $d/*GOPRO
do 
   echo "Working on directory $f"
   ffmpeg -f image2 -pattern_type glob -i "$f/*.JPG" -r 30 -s 1920x1080 -pix_fmt yuv420p ${f}_ffmpeg.mov
done

cd $d
# from: https://trac.ffmpeg.org/wiki/How%20to%20concatenate%20(join%2C%20merge)%20media%20files#samecodec
# Create a file list for use with ffmpeg in concate mode
for f in ./*.mov
do 
   echo "file '$f'" >> flist.txt
done
#printf "file '%s'\n" ./*.wav > mylist.txt


# Use ffmpeg to concatenate all the subdirectory mov files into one big one
curr_dir=${PWD##*/} 
echo "combined output file name: ${curr_dir}.mov"
ffmpeg -f concat -i flist.txt -c copy "../${curr_dir}.mov"

# Cleanup
rm flist.txt
for f in ./*.mov
do 
   echo "removing file '$f'"
   rm $f
done
cd ..
