#!/bin/bash

source movein_conf.sh
usage() {
   echo "Usage: $0 [-s src [-d dest] [-n] [-v] [-h]"
   echo "   -s src   default = $src"
   echo "   -d dest  default = $dst"
   echo "   -n       dry run"
   echo "   -v       verbose"
   echo "   -h       print this help message"
   exit 1
}

src="/etc"
dst="$movein_etc_src"

dryrun=""
verbose=""
while getopts ":s:d:hnv" o; do
    case "${o}" in
        s)
            src=${OPTARG}
            ;;
        d)
            dst=${OPTARG}
            ;;
        n)
            dryrun="-n"
            ;;
        v)
            verbose="-v"
            ;;
        *)  # Note: this covers -h as well
            usage
            ;;
    esac
done
shift $((OPTIND-1))

cmd="sudo rsync -a $verbose $src/ $dst/ --filter=\"-/ *\.swp\""
if [ ! -z $verbose ]; then
   echo "$cmd"
fi

if [ -z $dryrun ]; then
   eval "$cmd"
else
   echo "DRYRUN: not running rsync command"
fi

