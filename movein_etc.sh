#!/bin/bash

# This is a script to assist with setting up a new Linux computer, at FCI. It 
# attempts to copy some files from a backup to the /etc directory

# !!!!!!!!!!!!!!!!! This Script only has minimal testing!!!!!!!!!!!!!!!!!!
# This is a starter, for next time. - RBB 2019-02-28
src_dir="/home/data_ext/etc_backup"

cp_etc_target () {
   name=$1
   rp_name=$(realpath -s "/etc/$name")
   echo "cp_etc_target rp_name = $rp_name"
   if [ -f "$rp_name" ]; then
         echo "$rp_name exists backing upto /etc/$name.orig"
         sudo mv "$rp_name" "/etc/$name.orig"
   fi
   npath=$(echo "${name%/*}")
   echo "Copying /home/data_ext/etc_backup/$name to /etc/$npath"
   sudo cp -aprv "/home/data_ext/etc_backup/$name" "/etc/$npath"
}

if [ -d "/home/data_ext/etc_backup" ]; then
   cp_etc_target "fstab"
   cp_etc_target "hosts"
   cp_etc_target "network/interfaces"
fi

