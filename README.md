scripts
=======
These are some scripts that I use at home. Mostly related to processing images.

- gp2mov.sh: When using a GoPro to take timelapses, the GoPro organizes all 
             the JPGs into directories, with ~1000 files per folder. In my 
             workflow I put all of these nnnnGOPRO folders (nnnn = some number)
             into a single directory. This script pushes all of the JPEGs
             through ffmpeg, creating one .mov per nnnnGOPRO folder, and then
             merging them into one larger .mov. The ffmpeg settings used in
             the script should make it compatible with iMovie (on os X 10.9)
- tmov.sh: Takes a bunch of files with dates in their names, an then updates
             their modification times with the `touch` command.
- ptcb.sh: OS X bash script to convert the contents of the clipboard to plain text.
- pingplot.sh: Use gnuplot to plot ping results. uses pingplot.plt
- pingplot.plt: gnuplot file for use with pingplot.sh
