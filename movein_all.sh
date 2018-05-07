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
movein_ext.sh

