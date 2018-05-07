#!/bin/bash

# This is a script to assist with setting up a new Linux computer, at FCI. It 
# attempts to install a bunch of packages, setup networking, setup ssh, and
# copy some config files from a base user's home directory on a remote 
# host/server.

# !!!!!!!!!!!!!!!!! THIS SCRIPT IS NOT TESTED !!!!!!!!!!!!!!!!!!
# This is just a starter, for next time. - RBB 2013-10-11

cp_home_target () {
   name=$1
   if [ ! -e "$home/$name" ]; then
         cp -apr "/home/data_ext/home_russell_backup/$name" "$HOME/"
   fi
}


if [ -d "/home/data_ext/home_russell_backup" ]; then
   cp_home_target ".ssh"
   cp_home_target ".gitconfig"
   cp_home_target ".bash_history"
   cp_home_target ".pylintrc"
   cp_home_target ".python_history"
   #cp_home_target ".viminfo"
   cp_home_target ".minirc.dfl"
fi

