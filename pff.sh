#!/bin/sh -e

# Brute force a private firefox session
#
# From https://nullprogram.com/blog/2018/09/06/
#
DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
mkdir -p -- "$DIR"
TEMP="$(mktemp -d -- "$DIR/firefox-XXXXXX")"
trap "rm -rf -- '$TEMP'" INT TERM EXIT

if command -v xclip &>/dev/null; then
   firefox -profile "$TEMP" -no-remote "$@" `xclip -selection clipboard -o`
else
   firefox -profile "$TEMP" -no-remote "$@"
fi
