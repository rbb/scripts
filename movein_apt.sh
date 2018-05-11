#!/bin/bash

# This is a script to assist with setting up a new Linux computer, at FCI. It 
# attempts to install a bunch of packages, setup networking, setup ssh, and
# copy some config files from a base user's home directory on a remote 
# host/server.

# !!!!!!!!!!!!!!!!! THIS SCRIPT IS NOT TESTED !!!!!!!!!!!!!!!!!!
# This is just a starter, for next time. - RBB 2013-10-11

#------------------------------------
# Install a bunch of packages
#------------------------------------
# some some basic utilities
package_list=( adduser samba openssh-server sshfs vim-gtk3 curl inkscape) #smbfs 
package_list+=(synaptic aptitude)
package_list+=(kdiff3)

# Some development utilities
package_list+=(automake expect cscope git)
#package_list+=(automake expect cscope rabbitvcs-nautilus xxgdb ddd)
package_list+=(python ipython winpdb pylint)

# Some engineering utilities
package_list+=(octave linsmith)
package_list+=(octave-control octave-doc octave-image octave-io octave-nan)
package_list+=(octave-signal octave-sockets octave-specfun octave-statistics octave-tsa)


# Install Latex and utilities
package_list+=(texlive texlive-science-doc texlive-pictures-doc texlive-fonts-recommended lyx)

# some some Networking utilities
package_list+=( ethtool mtr-tiny filezilla fping net-tools)

# OK, now install that massive package list
echo "Installing packages: ${package_list[@]}"
sudo apt install ${package_list[@]}      

sudo add-apt-repository ppa:alessandro-strada/ppa
sudo apt install google-drive-ocamlfuse
