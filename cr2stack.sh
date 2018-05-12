#!/bin/sh

#NOTE: This script has NOT been tested

exposure=${1:-'0'}

# Convert all the CR2 files to jpg
time ufraw-batch --out-type=jpg --exposure=$exposure


up_dir=`ls ..`
mov_name=`basename $up_dir`



align_image_stack -a out IMG*jpg

enfuse \
   --exposure-weight=0 \
   --saturation-weight=0 \
   --contrast-weight=1 \
   --hard-mask \
   ... \
   --output=output.tif \
   input-<0000-9999>.tif

