#!/bin/sh


function show_help {
   echo "rotmov [-h] [-r|l|u] [-o out_fname] in_fname"
   echo ""
   echo "Rotates a movie left(-l) or right(-r) or upside-down(-u)"
   echo "Default out_fname is in_fname_rot.mov"
   echo "-h prints this help message"
   #echo "Note: in_fname MUST be the last argument"
   echo ""
}

#LEFT=1
#RIGHT=2
LEFT="cclock"
RIGHT="clock"
out=""
rotdir=$LEFT

# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to -gt 0 the /etc/hosts part is not recognized ( may be a bug )
while [[ $# -gt 0 ]]
do
   key="$1"

   case $key in
       -r|--clock)
       rotdir=$RIGHT
       rotcmd='transpose=clock'
       ;;
       -l|--cclock)
       rotdir=$LEFT
       rotcmd='transpose=cclock'
       ;;
       -u)
       rotdir=$LFLIP
       rotcmd='"transpose=clock,transpose=clock"'
       ;;
       -o|--outfile)
       out="$2"
       shift # past argument
       ;;
       -h|--help)
       show_help
       exit
       ;;
       *)
       echo "leftovers"
       f=$1
       ;;
   esac
   shift # past argument or value
done



echo "rotdir=$rotdir, out='$out', f='$f', Leftovers: $@"
echo "rotcmd=$rotcmd"
#f="$@"
#echo "f=$f"

# Handle empty out filename (default), by appending "_rot" to the basename
if [ "$out" == "" ]; then
   bn="${f%.*}"
   ext=".${f##*.}"
   out="${bn}_rot$ext"
   echo "out=$out"
fi


#time ffmpeg -i "$f" -filter:v transpose=$rotdir \
time ffmpeg -i "$f" -filter:v $rotcmd \
-c:v libx264 -preset veryfast -crf 22 \
-c:a copy \
-map_metadata 0 \
-metadata:s:v rotate="" \
"$out"

#TODO: should the output be in prores format for easier editing? See example below.
#time ffmpeg -f image2 -pattern_type glob -i "*.jpg" -r 30 -s 1920x1080 -c:v prores_ks -pix_fmt yuv444p10le "${mov_name}.mov"
