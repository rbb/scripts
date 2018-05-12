#!/bin/bash

sudo rsync -a $1 /etc/ /home/data_ext/etc_backup/ \
   --filter="-/ *\.swp" 
