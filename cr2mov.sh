#!/bin/sh

#NOTE: This script has NOT been tested

exposure=${1:-'0'}

# Convert all the CR2 files to jpg
time ufraw-batch --out-type=jpg --exposure=$exposure *.CR2


# create an mov
#
# ffmpeg options culled from the following sources:
# http://mewiki.project357.com/wiki/X264_Encoding_Suggestions#QuickTime-compatible_Encoding
# https://trac.ffmpeg.org/wiki/Encode/H.264
# http://en.wikipedia.org/wiki/High-definition_television
# http://en.wikibooks.org/wiki/FFMPEG_An_Intermediate_Guide/image_sequence
up_dir=`ls ..`
mov_name=`basename $up_dir`
time ffmpeg -f image2 -pattern_type glob -i "*.jpg" -r 30 -s 1920x1080 -pix_fmt yuv420p "${mov_name}.mov"

