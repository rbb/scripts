#!/bin/bash

usage() { echo "Usage: $0 [-s src] [-d dest] [-n] [-h]" 1>&2; exit 1; }

src="$HOME"
dst=$(realpath "/home/data_ext/$HOME")
#dryrun=-n

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


   echo "Created by backext.sh. This is a list of symbolic links in the src directory" > $src/fslinks.txt
   find . -maxdepth 1  -type l  -exec ls -alFh {} + 2>&1 | grep -v "Permission denied" >> $src/fslinks.txt
   if [ ! -z $verbose ]; then
      echo "fslinks.txt created"
   fi

   echo "Created by backext.sh. This is a list of installed apps." > $src/installed.txt
   echo "Created by 'apt list --installed'" >> $src/installed.txt
   apt list --installed 2>&1 |grep -v "stable CLI interface" >> $src/installed.txt
   if [ ! -z $verbose ]; then
      echo "installed.txt created"
   fi

   #function filterstr() {
   #   #local s=("--filter=\"H/ $1\" --filter=\"P/ $1\"")
   #   local s=("--filter=\"H $1\"")
   #   #local s=("--filter='- $1'")
   #   echo "$s"
   #}
   excl='H/'
   filters=()
   filters+=("--filter=\"$excl .dbus\"")
   filters+=("--filter=\"$excl .gvfs\"")
   #filters+=("--filter=\"$excl $src/\.dbus\"")
   #filters+=("--filter=\"$excl $src/\.dbus/*\"")
   #filters+=("--filter=\"$excl $src/\.gvfs\"")
   #filters+=("--filter=\"$excl $src/\.gvfs/*\"")
   filters+=("--filter=\"$excl .cache/\"")
   filters+=("--filter=\"$excl .dropbox/\"")
   filters+=("--filter=\"$excl snap/\"")
   filters+=("--filter=\"$excl *\.swp\"")


   gdfuse_list=$(mount | grep google-drive-ocamlfuse|cut -d ' ' -f 3)
   for d in ${gdfuse_list[@]}
   do
      if [ ! -z $verbose ]; then
         echo "found gdfuse mount at $d"
      fi
      filters+=("--filter='$excl $d'")
   done

   cmd="rsync -a $verbose $dryrun $src/ $dst/ ${filters[@]}"
   if [ ! -z $verbose ]; then
      #echo "filters = ${filters[@]}"
      #echo "filters len = ${#filters[@]}"
      #echo "cmd len = ${#cmd[@]}"
      echo $cmd
   fi
   eval "$cmd"

