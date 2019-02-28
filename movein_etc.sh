#!/bin/bash


# This is a script to assist with setting up a new Linux computer, at FCI. It 
# attempts to copy some files from a backup to the /etc directory

# !!!!!!!!!!!!!!!!! This Script only has minimal testing!!!!!!!!!!!!!!!!!!
# This is a starter, for next time. - RBB 2019-02-28
source movein_conf.sh

cp_etc_target () {
   name=$1
   rp_name=$(realpath -s "/etc/$name")
   echo "cp_etc_target rp_name = $rp_name"
   echo "cp_etc_target src dir = $movein_etc_src"
   if [ -f "$rp_name" ]; then
         echo "$rp_name exists backing upto /etc/$name.movein_etc.orig"
         sudo mv "$rp_name" "/etc/$name.movein_etc.orig"
   fi
   echo "Copying $movein_etc_src/$name to $rp_name"
   sudo cp -aprv "$movein_etc_src/$name" "$rp_name"
}

if [ -d "$movein_etc_src" ]; then
   cp_etc_target "fstab"
   cp_etc_target "hosts"
   cp_etc_target "netplan/01-network-manager-all.yaml"
   #cp_etc_target "network/interfaces"
fi

