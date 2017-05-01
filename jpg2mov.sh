#!/bin/sh

#NOTE: This script MUST be run from the directory with all the *.jpg images in it

# create an mov from jpegs
#
# ffmpeg options culled from the following sources:
# http://mewiki.project357.com/wiki/X264_Encoding_Suggestions#QuickTime-compatible_Encoding
# https://trac.ffmpeg.org/wiki/Encode/H.264
# http://en.wikipedia.org/wiki/High-definition_television
# http://en.wikibooks.org/wiki/FFMPEG_An_Intermediate_Guide/image_sequence
mov_name=$(basename "$PWD")
echo "Creating $mov_name"

# Quicktime output 15 seconds for 86 images
#time ffmpeg -f image2 -pattern_type glob -i "*.jpg" -r 30 -s 1920x1080 -pix_fmt yuv420p "${mov_name}.mov"

# Prores output 41 seconds for 86 images
# https://olitee.com/2014/02/ffmpeg-convert-dcp-quicktime/
time ffmpeg -f image2 -pattern_type glob -i "*.jpg" -r 30 -s 1920x1080 -c:v prores_ks -pix_fmt yuv444p10le "${mov_name}.mov"

