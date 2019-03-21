#!/bin/bash


# This is a script to assist with setting up a new Linux computer, at FCI. It 
# attempts to copy some files from a backup to the /etc directory

# !!!!!!!!!!!!!!!!! This Script only has minimal testing!!!!!!!!!!!!!!!!!!
# This is a starter, for next time. - RBB 2019-02-28
source movein_conf.sh

src="$movein_etc_src"
dst="/etc"

usage() {
   echo "Usage: $0 [-s src [-d dest] [-n] [-h]"
   echo "   default src: $src"
   echo "   default dest: $dst"
   exit 1
}

dryrun=""
verbose=""
while getopts ":s:d:hnv" o; do
    case "${o}" in
        s)
            src=${OPTARG}
            ;;
        d)
            dst=${OPTARG}
            ;;
        n)
            dryrun="-n"
            ;;
        v)
            verbose="-v"
            ;;
        *)  # Note: this covers -h as well
            usage
            ;;
    esac
done
shift $((OPTIND-1))

cp_etc_target () {
   name=$1
   rp_name=$(realpath -s "$dst/$name")
   echo "cp_etc_target rp_name = $rp_name"
   echo "cp_etc_target src dir = $src"
   if [ -f "$rp_name" ]; then
         echo "$rp_name exists backing upto /etc/$name.movein_etc.orig"
         if [ -z $dryrun ]; then
            sudo mv "$rp_name" "/etc/$name.movein_etc.orig"
         fi
   fi
   if [ -e "$src/$name" ]; then
      echo "Copying $src/$name to $rp_name"
      if [ -z $dryrun ]; then
         sudo cp -aprv "$src/$name" "$rp_name"
      fi
   fi
}

cp_etc_target "fstab"
cp_etc_target "hosts"
cp_etc_target "netplan/01-network-manager-all.yaml"
#cp_etc_target "network/interfaces"

