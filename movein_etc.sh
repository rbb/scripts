#!/bin/bash

# This is a script to assist with setting up a new Linux computer, at FCI. It 
# attempts to install a bunch of packages, setup networking, setup ssh, and
# copy some config files from a base user's home directory on a remote 
# host/server.

# !!!!!!!!!!!!!!!!! THIS SCRIPT IS NOT TESTED !!!!!!!!!!!!!!!!!!
# This is just a starter, for next time. - RBB 2013-10-11

cp_etc_target () {
   name=$1
   rp_name=$(realpath -s "/etc/$name")
   echo "cp_etc_target rp_name = $rp_name"
   if [ -f "$rp_name" ]; then
         echo "$rp_name exists backing upto /etc/$name.orig"
         sudo mv "$rp_name" "/etc/$name.orig"
   fi
   sudo cp -apr "/home/data_ext/etc_backup/$name" "/etc/"
   echo ""
}

if [ -d "/home/data_ext/etc_backup" ]; then
   #cp_etc_target "fstab"
   cp_etc_target "hosts"
   #cp_etc_target "network/interfaces"
fi

