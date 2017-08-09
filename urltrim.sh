#!/bin/bash

# Script to grab a URL from the clipboard (currently only with xclip), clean it 
# up and then paste back to the clipboard.
#
# Right now it only knows 2 things:
# - google search result style links: cleanup means grab the real URL, 
#   without the surrounding Google meta data
# - NYtimes style links: cleanup means grab the tail end of the link,
#   so it can be pasted into search.
#

function clip_get () {
   if command -v xclip &>/dev/null; then
      gtxt=$(xclip -selection clipboard -o)
      echo "clip_get $txt"

   else
      echo "don't know what command to use for clipboard integration (get)"
   fi
}

function clip_put () {
   if command -v xclip &>/dev/null; then
      echo "clip_put $1"
      echo "$1" | xclip -selection clipboard -i

   else
      echo "don't know what command to use for clipboard integration (put)"
   fi
}

# Some test URLs
#
#url = "https://www.nytimes.com/interactive/2017/08/07/upshot/music-fandom-maps.html?mtrref=www.netvibes.com&gwh=A0DED69FFCEE68B183F61FE07D6156FB&gwt=pay"
#url = "https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwi6mp661crVAhUqqlQKHY0XCJgQFggnMAA&url=https%3A%2F%2Fstackoverflow.com%2Fquestions%2F743806%2Fhow-to-split-a-string-into-a-list&usg=AFQjCNG8k9pY0ZcETuSwWg8DawtaTWnBTw"
clip_get
url="$gtxt"
echo "url = $url"

google_str="https://www.google.com/url"
#echo "google_str = $google_str"
#if [[ $url == *"url=http"* ]]; then
if [[ $url == *"$google_str"* ]]; then
   #set -x
   prevIFS="$IFS"
   IFS="&"
   arr=($url)
   for el in "${arr[@]}"; do
      echo "el = $el"
      if [[ $el == *"url=http"* ]]; then
         tmpurl=$(echo "$el"|cut -d '=' -f 2)
         break
      fi
   done
   tmpurl="${tmpurl//"%3A"/":"}"
   tmpurl="${tmpurl//"%3a"/":"}"
   tmpurl="${tmpurl//"%2F"/"/"}"
   tmpurl="${tmpurl//"%2f"/"/"}"
   IFS="$prevIFS"
else
   echo "no url=http"
   # split off any RESTful/CGI stuff
   noncgi=$(echo "$url"|cut -d '?' -f 1)
   #echo "noncgi = $noncgi"

   # Grab everything after the last /
   tmpurl=$(echo "$noncgi"|rev|cut -d '/' -f 1|rev)
   tmpurl=$(echo $tmpurl|tr -d '\n')
   tmpurl=$(echo $tmpurl|tr -d '\r')
fi

echo "tmpurl = '$tmpurl'"
clip_put "$tmpurl"
