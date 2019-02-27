#!/bin/bash

# This is a script to assist with setting up a new Linux computer by setting up
# some symbolic links

# !!!!!!!!!!!!!!!!! THIS SCRIPT IS NOT TESTED !!!!!!!!!!!!!!!!!!
# This is just a starter, for next time. - RBB 2013-10-11



if [ -d "/home/data_ext/home/russell" ]; then
   if [ ! -f "$HOME/fslinks.txt" ]; then
      echo "Copying fslinks.txt"
      cp -ap /home/data_ext/home/russell/fslinks.txt "$HOME" 
   fi
   if [ ! -f "$HOME/installed.txt" ]; then
      echo "Copying installed.txt"
      cp -ap /home/data_ext/home/russell/installed.txt "$HOME" 
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
if [ ! -e "$HOME/fslinks.txt" ]; then
   if [ -d "$HOME/Dropbox" ]; then
      # Create a minimal set of links
      echo "lrwxrwxrwx 1 russell russell 29 May  7  2018 ./.bashrc -> $HOME/Dropbox/.bashrc" >> fslinks.txt
      echo "lrwxrwxrwx 1 russell russell 18 May  7  2018 ./bin -> $HOME/Dropbox/home-bin/" >> fslinks.txt
      echo "lrwxrwxrwx 1 russell russell 15 May  7  2018 ./.gvimrc -> $HOME/Dropbox/_gvimrc" >> fslinks.txt
      echo "lrwxrwxrwx 1 russell russell 18 May  7  2018 ./.vim -> $HOME/Dropbox/vimfiles/" >> fslinks.txt
      echo "lrwxrwxrwx 1 russell russell 14 May  7  2018 ./.vimrc -> $HOME/Dropbox/_vimrc" >> fslinks.txt
   fi
fi

while read line; do
   #echo $line
   src=$(echo $line | grep -v "Created by backext.sh" | awk '{ print $11 }')
   dst=$(echo $line | grep -v "Created by backext.sh" | awk '{ print $9 }')
   

   if [ ! -z $src ]; then
      #echo "src = $src"
      src=${src/\/\/\///}
      src=${src/\*/}
      dst=${src/\/\/\///}
      dst=${src/\*/}
      #echo "src = $src"
      base=$(basename $dst)
      src=$(realpath -s $src)
      dst=$(realpath -s $dst)
      echo "src = $src"
      echo "dst = $dst"
      echo "base = $base"

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
