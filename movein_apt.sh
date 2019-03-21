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
package_list=( adduser samba openssh-server vim vim-gtk3 inkscape) #smbfs 
package_list+=(synaptic aptitude)
package_list+=(kdiff3 ascii cups-pdf minicom screen)
package_list+=(xclip xdotool pv)
package_list+=(ffmpeg gthumb) # darkroom graphviz 
package_list+=(htop) # darkroom 
#package_list+=(xdemineur xfonts-mathml wmctrl)

# Some development utilities
package_list+=(automake autoconf build-essential expect cscope git)
package_list+=(ddd nemiver repo)   # dconf-editor remake 
#package_list+=(cmake expect cscope rabbitvcs-nautilus xxgdb ddd)
#package_list+=(julia)
package_list+=(g++ gcc ) #gccxml
package_list+=(git gitk)
#   grive mkusb 

# PYTHON!
package_list+=(python ipython winpdb pylint python-notebook)
package_list+=(python-numpy python-pandas python-matplotlib python-pip python-virtualenv)
#package_list+=(python-aafigure python-bs4 python-colorama)
#package_list+=(python-dev python-distlib)
#package_list+=(python-docutils python-gtksourceview2 python-imaging-tk python-mako python-opengl)
#package_list+=(python-pygame python-pygraphviz python-pymc python-pyproj python-pytest)
#package_list+=(python-qt4-dev python-qwt5-qt4 python-requests python-support python-termcolor python-tk)
#package_list+=(python-uniconvertor  python-wxgtk2.8 python-xlrd python-zeitgeist)

# Some engineering utilities
package_list+=(octave linsmith gerbv)
package_list+=(octave-control octave-doc octave-image octave-io octave-nan)
package_list+=(octave-signal octave-sockets octave-specfun octave-statistics octave-tsa)


# Install Latex and utilities
package_list+=(texlive texlive-science-doc texlive-pictures-doc texlive-fonts-recommended lyx)
package_list+=(pandoc pdfsam rst2pdf) # markdown 

# some some Networking utilities
package_list+=(iperf curl wget ethtool mtr-tiny filezilla fping net-tools wireshark)
package_list+=(sshfs rdesktop)
package_list+=(chromium-browser firefox)
# nmap 


#   roxterm-gtk3 seahorse setserial siril \
#   stopwatch synaptic texlive-fonts-extra texlive-fonts-recommended ttf-dejavu-core \
#   ttf-mscorefonts-installer tweak ufraw-batch unetbootin units unrar-free \
#   usb-creator-gtk usb-pack-efi verilator \
#   vim-pathogen vlc wdiff \




#---------------------------------------------------
# OK, now install that massive package list
#---------------------------------------------------
echo "Installing packages: ${package_list[@]}"
sudo apt install ${package_list[@]}      

if [ ! -e "/etc/apt/sources.list.d/alessandro-strada-ubuntu-ppa-bionic.list" ]; then
   sudo add-apt-repository ppa:alessandro-strada/ppa
fi
if ! command -v google-drive-ocamlfuse &>/dev/null; then 
   sudo apt install google-drive-ocamlfuse
fi
