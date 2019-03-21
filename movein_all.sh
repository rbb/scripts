#!/bin/bash

# This is a script to assist with setting up a new Linux computer, at FCI. It 
# attempts to install a bunch of packages, setup networking, setup ssh, and
# copy some config files from a base user's home directory on a remote 
# host/server.

# !!!!!!!!!!!!!!!!! THIS SCRIPT IS NOT TESTED !!!!!!!!!!!!!!!!!!
# This is just a starter, for next time. - RBB 2013-10-11

movein_fslinks.sh
movein_hidden.sh
movein_apt.sh
movein_etc.sh
#movein_grub.sh


#------------------------------------
# Remove network-manager
# If you want to manually change IP addresses, etc
#------------------------------------
# This is helpful if you need/want to do a lot of virtual networks with the 
# ifconfig command or via /etc/network/interfaces. However, it sucks for 
# doing WiFi connections, since you really do want to use either 
# network-manager, wicd, or similar to connecto to an AP. Connecting to an
# AP without these tools is a pain.
#echo "Remove network-manager [Y/N]?"
#read resp
#if [ resp != 'n' -a resp != 'N' ]; then
#   echo "Removing network-manager"
#   sudo apt-get remove network-manager
#fi

#------------------------------------
# set (static) ip address
#------------------------------------
#interfaces=/etc/network/interfaces
#echo "Setup static IP address $ip in $interfaces? [Y/N]"
#read resp
#if [ resp != 'n' -a resp != 'N' ]; then
#   echo "Adding lines to $interfaces"
#   sudo apt-get remove network-manager
#
#   #cat "auto lo" >> $interfaces
#   #cat "iface lo inet loopback" >> $interfaces
#
#   cat " " >> $interfaces
#   cat "auto eth0" >> $interfaces
#   cat "iface eth0 inet static" >> $interfaces
#   cat "address $ip" >> $interfaces
#   cat "netmask 255.255.255.0" >> $interfaces
#   cat "gateway 192.168.221.1" >> $interfaces
#   cat "dns-nameservers 208.67.222.222 208.67.220.220" >> $interfaces
#   cat "#network 192.168.0.0" >> $interfaces
#   cat "#metric 1" >> $interfaces
##else
##TODO: use nmcli to setup the IP address via network-manager, if it is not being removed
#fi


#------------------------------------
# setup ssh to and from the base_server
#------------------------------------
#ssh_config_file=.ssh/config
#ssh_key_type=dsa     # Usually dsa or rsa
#if [ ! -d .ssh ]; then
#   mkdir .ssh
#fi
#if [ ! -d .ssh/id_$ssh_key_type.pub ]; then
#   ssh-keygen -t $ssh_key_type                                       # Create a key
#fi
## Copy the key from this new machine to base_server
#ssh-copy-id -i ~/.ssh/id_$ssh_key_type.pub $user@$base_server     
##cat ~/.ssh/id_rsa.pub | ssh $user@$base_server 'cat >> .ssh/authorized_keys2'
#
## Setup default user for base_server, etc
#echo "Host $base_server" >> $ssh_config_file
#echo "User $user" >> $ssh_config_file
#echo "ForwardX11 yes" >> $ssh_config_file
#
## Now copy the public key from  base_server to our list of authorized keys
#ssh $user@$base_server "cat .ssh/id_$ssh_key_type.pub" >> .ssh/authorized_keys2
#
##-------------------------------------------
## Grab some files from the home directory on $base_server
##-------------------------------------------
##TODO: change the scp .bashrc command to a bunch of echo "..." >> .bashrc commands
#mkdir -p ~/bin
#file_list=(.bashrc .profile .vimrc .gvimrc)
#for file in "${file_list[@]}"; do
#   mv "$file" "$file.orig"
#   scp $user@$base_server:$file ~
#done
#
#dir_list=(.vim bin)
#for d in "${dir_list[@]}"; do
#   scp -r "$user@$base_server:$d" ~
#done
#
##-----------------------------------------
## Grab some info from $base_server:/etc/
##-----------------------------------------
#$hosts_ignore="$ip\|127.0.1.1\|127.0.0.1\|::"   # grep -v to exclude $ip (This computer, 127... for localhost, :: for IPV6
#sudo ssh $user@$base_server "cat /etc/hosts" | grep -v $hosts_ignore  >> /etc/hosts  

