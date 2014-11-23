#!/bin/bash
#
## Convert contents of clipboard to plain text.

pbpaste | textutil -convert txt -stdin -stdout -encoding 30 | pbcopy
