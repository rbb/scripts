#!/bin/bash

# This is a script to assist with setting up a new Linux computer, at FCI. It 
# attempts to install a bunch of packages, setup networking, setup ssh, and
# copy some config files from a base user's home directory on a remote 
# host/server.

# !!!!!!!!!!!!!!!!! THIS SCRIPT IS NOT TESTED !!!!!!!!!!!!!!!!!!
# This is just a starter, for next time. - RBB 2013-10-11



if [ -d "/home/data_ext/home_russell_backup" ]; then
   if [ ! -f "$HOME/fslinks.txt" ]; then
      cp -ap /home/data_ext/home_russell_backup/fslinks.txt "$HOME" 
   fi
   if [ ! -f "$HOME/installed.txt" ]; then
      cp -ap /home/data_ext/home_russell_backup/installed.txt "$HOME" 
   fi
fi


mv_home_target () {
   name=$1
   rp_name=$(realpath -s "$HOME/$name")
   echo "mv_home_target rp_name = $rp_name"
   #if [ "$dst" == "$rp_name" ]; then
      #echo "Found $name line"
      if [ -e "$rp_name" ]; then
         if ! [ -L "$rp_name" ]; then
            echo "$rp_name exists and is NOT a link"
            mv "$rp_name" "$HOME/$name.orig"
         fi
      fi
   #fi
}
mvl_home_target () {
   name=$1
   rp_name=$(realpath -s "$HOME/$name")
   #if [ "$dst" == "$rp_name" ]; then
      #echo "Found $name line"
      if [ -d "$rp_name" ]; then
         if [ -L "$rp_name" ]; then
            echo "$rp_name exists and is a link"
            mv "$rp_name" "$HOME/$name.orig"
         fi
      fi
   #fi
}

#mv_home_target Documents
#mv_home_target Music
#mv_home_target Downloads
#mv_home_target bin

#Created by backext.sh. This is a list of symbolic links in the src directory
#lrwxrwxrwx 1 russell russell 15 Sep 18  2017 ./.bashrc -> Dropbox/.bashrc*
while read line; do
   #echo $line
   src=$(echo $line | grep -v "Created by backext.sh" | cut -d ' ' -f 11)
   dst=$(echo $line | grep -v "Created by backext.sh" | cut -d ' ' -f 9)

   if [ ! -z $src ]; then
      base=$(basename $dst)
      src=$(realpath -s $src)
      dst=$(realpath -s $dst)
      #echo "src = $src"
      #echo "dst = $dst"
      #echo "base = $base"

      mv_home_target "$base"

      #echo "src and dst not empty"
      if [ ! -e "$dst" ]; then
         echo "Creating link $src -> $dst"
         ln -s "$src" "$dst"
      else
         echo "$dst exists"
      fi
   fi
   echo "------"
done < "$HOME/fslinks.txt"
