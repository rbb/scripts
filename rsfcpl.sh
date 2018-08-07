#!/bin/bash

# Command to sync final cut pro libraries

#rsync -av --exclude="Render Files" --exclude="Transcoded Media" "$1" "$2"
rsync -rlptgov --exclude="Render Files" --exclude="Transcoded Media" "$1" "$2"


# TODO force '\' at end of names ($1 and $2)
