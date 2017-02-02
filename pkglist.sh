#!/bin/bash

# This script tries to find a list of MANUALLY installed packages. In other 
# words, the ones that were requested by the user, and none of the dependancies.
#
# Ideas for the implementation are stolen from:
# http://askubuntu.com/questions/2389/generating-list-of-manually-installed-packages-and-querying-individual-packages/492343#492343
# http://unix.stackexchange.com/questions/3595/list-explicitly-installed-packages
#


# First create a place to store all the intermediate and final results
pre="/tmp/pkglist"
if [ ! -d $pre ]; then
   mkdir $pre
fi

# Next find out what we know about this machine
echo 'Gathering lists of installed packages'
# First, get a list of things we thing were installed manually
apt-mark showmanual | sort -u                      > $pre/apt-manual.txt

# Now create several lists of things that we think are dependencies
gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u > $pre/initial-status.txt
dpkg-query -W -f='${Package}\n' | sed 1d | sort -u > $pre/dkpg-query.txt
apt-mark showauto | sort -u                        > $pre/apt-auto.txt
apt-cache depends ubuntu-desktop ubuntu-minimal ubuntu-standard linux-* | awk '/Depends:/ {print $2}' | sort -u > $pre/cache-depends.txt


if [ ! -e $pre/default-installed.txt ]; then
   echo 'Getting defaults from the web'
   #wget -qO - http://mirror.pnl.gov/releases/precise/ubuntu-12.04.3-desktop-amd64.manifest | cut -f1 | sort -u > $pre/default-installed.txt
   wget -qO - http://cdimage.ubuntu.com/xubuntu/releases/16.04/release/xubuntu-16.04-desktop-i386.manifest | cut -f1 | sort -u > $pre/default-installed.txt
fi



echo 'Comparing the results'
comm -23 $pre/apt-manual.txt $pre/initial-status.txt > $pre/stage1.txt
comm -23 $pre/stage1.txt $pre/apt-auto.txt > $pre/stage2.txt
comm -23 $pre/stage2.txt $pre/initial-status.txt  > $pre/stage3.txt
#comm -23 $pre/stage2.txt $pre/cache-depends.txt > $pre/stage3.txt
comm -23 $pre/stage3.txt $pre/default-installed.txt | tee $pre/stage4.txt
grep -v "^linux-*" $pre/stage4.txt | grep -v "^libboost*" | grep -v "^libmono*" | grep -v "^samba*" | grep -v "^nvidia*" | \
   grep -v "shared-desktop-ontologies" > $pre/final.txt

echo ""
echo "Results in $pre/final.txt"
