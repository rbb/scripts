#!/bin/bash

# This is a script to assist with setting up a new Linux computer. It
# attempts to copy backed up files.

# !!!!!!!!!!!!!!!!! THIS SCRIPT IS NOT TESTED !!!!!!!!!!!!!!!!!!
# This is just a starter, for next time. - RBB 2013-10-11
source movein_conf.sh

src="$movein_home_src"
dst="$HOME"

usage() {
   echo "Usage: $0 [-s src [-d dest] [-n] [-h]"
   echo "   default src: $src"
   echo "   default dest: $dst"
   exit 1
}

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


cp_home_target () {
   name=$1
   if [ ! -e "$dst/$name" ]; then
      if [ ! -z $verbose ]; then
         echo "Copying $src/$name to $dst"
      fi
      if [ -z $dryrun ]; then
         cp -apr "$src/$name" "$dst/"
      fi
   fi
}


if [ -d "$src" ]; then
   cp_home_target ".ssh"
   cp_home_target ".gitconfig"
   cp_home_target ".bash_history"
   cp_home_target ".pylintrc"
   cp_home_target ".python_history"
   #cp_home_target ".viminfo"
   cp_home_target ".minirc.dfl"
fi

