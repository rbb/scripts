#!/bin/sh

#NOTE: This script MUST be run from the directory with all the *.CR2 images in it

exposure=${1:-'0'}
nprocs=${2:-'3'}

# Convert all the CR2 files to jpg
if command -v parallel &>/dev/null; then 
   #time nice parallel -j $nprocs ufraw-batch --out-type=jpg --exposure=$exposure -- *.CR2
   time nice parallel --citation -j $nprocs ufraw-batch --out-type=jpg --exposure=$exposure ::: *.CR2
else
   time nice ufraw-batch --out-type=jpg --exposure=$exposure *.CR2
fi


# create an mov
#
# ffmpeg options culled from the following sources:
# http://mewiki.project357.com/wiki/X264_Encoding_Suggestions#QuickTime-compatible_Encoding
# https://trac.ffmpeg.org/wiki/Encode/H.264
# http://en.wikipedia.org/wiki/High-definition_television
# http://en.wikibooks.org/wiki/FFMPEG_An_Intermediate_Guide/image_sequence
#up_dir=`ls -d ..`
#mov_name=`basename $up_dir`
#time ffmpeg -f image2 -pattern_type glob -i "*.jpg" -r 30 -s 1920x1080 -pix_fmt yuv420p "${mov_name}.mov"
jpg2mov.sh

