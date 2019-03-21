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

src="$HOME"
dst="$movein_home_src"

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
# Note that in this call to find, we use an absolute path name, so that creating
# symbolic links will work when parsing the fslinks.txt file
if [ -z $dryrun ]; then
   find "$src" -maxdepth 1  -type l  -exec ls -alFh {} + 2>&1 | grep -v "Permission denied" >> $src/fslinks.txt
   if [ ! -z $verbose ]; then
      echo "fslinks.txt created"
   fi

   echo "Created by backext.sh. This is a list of installed apps." > $src/installed.txt
   echo "Created by 'apt list --installed'" >> $src/installed.txt
   apt list --installed 2>&1 |grep -v "stable CLI interface" >> $src/installed.txt
   if [ ! -z $verbose ]; then
      echo "installed.txt created"
   fi
fi

#function filterstr() {
#   #local s=("--filter=\"H/ $1\" --filter=\"P/ $1\"")
#   local s=("--filter=\"H $1\"")
#   #local s=("--filter='- $1'")
#   echo "$s"
#}
excl='H/'
filters=()
filters+=("--filter=\"$excl .dbus\" ")
filters+=("--filter=\"$excl .gvfs\" ")
#filters+=("--filter=\"$excl $src/\.dbus\" ")
#filters+=("--filter=\"$excl $src/\.dbus/*\" ")
#filters+=("--filter=\"$excl $src/\.gvfs\" ")
#filters+=("--filter=\"$excl $src/\.gvfs/*\" ")
filters+=("--filter=\"$excl .cache/\" ")
filters+=("--filter=\"$excl .dropbox/\" ")
filters+=("--filter=\"$excl snap/\" ")
filters+=("--filter=\"$excl *\.swp\" ")


gdfuse_list=$(mount | grep google-drive-ocamlfuse|cut -d ' ' -f 3)
for d in ${gdfuse_list[@]}
do
   if [ ! -z $verbose ]; then
      echo "found gdfuse mount at $d"
   fi
   filters+=("--filter='$excl $d' ")
done

cd $src

# Note here we call find with a relative path, now that we are in $src, so that the 
# filter arguments to rsync will get parsed correctly (They only seem to work as 
# relative paths).
links=$(find . -maxdepth 1  -type l)
for f in ${links[@]}
do
   name=$(echo "$f"|cut -c 3-)      # Strip off the './' from the begining of the file name
   filters+=("--filter=\"$excl $name\" ")
done
not_readable=$(find . -user root -group root ! -readable 2>&1 | grep -v "Permission denied")
for f in ${not_readable[@]}
do
   name=$(echo "$f"|cut -c 3-)      # Strip off the './' from the begining of the file name
   filters+=("--filter=\"$excl $name\" ")
done
   

cmd="rsync -a $verbose $dryrun $src/ $dst/ ${filters[@]}"
if [ ! -z $verbose ]; then
   echo $cmd
fi

if [ -z $dryrun ]; then
   eval "$cmd"
else
   echo "DRYRUN: not running rsync command"
fi

cd -
