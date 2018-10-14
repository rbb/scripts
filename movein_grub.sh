#!/bin/bash

# This is a script to assist with setting up a new Linux computer, at FCI.

# !!!!!!!!!!!!!!!!! THIS SCRIPT IS NOT TESTED !!!!!!!!!!!!!!!!!!
# This is just a starter, for next time. - RBB 2013-10-11

config_file="grub"
echo "config_file = $config_file"

grep -q "net.ifnames=0 biosdevname=0" "$config_file"
if [[ $? == 1 ]]; then
   echo "Did not find ifnames, biosdevname"
   sed -i 'GRUB_CMDLINE_LINUX=/ c\GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"' "$config_file"
fi
grep GRUB_CMDLINE_LINUX "$config_file"
#sudo grub-mkconfig -o /boot/grub/grub.cfg
