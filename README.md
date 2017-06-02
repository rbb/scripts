scripts
=======
These are some scripts that I use at home or work. Mostly related to processing images or dealing with files.

- `gp2mov.sh`: When using a GoPro to take timelapses, the GoPro organizes all 
             the JPGs into directories, with ~1000 files per folder. In my 
             workflow I put all of these nnnnGOPRO folders (nnnn = some number)
             into a single directory. This script pushes all of the JPEGs
             through ffmpeg, creating one .mov per nnnnGOPRO folder, and then
             merging them into one larger .mov. The ffmpeg settings used in
             the script should make it compatible with iMovie (on os X 10.9)
- `tmov.sh`: Takes a bunch of files with dates in their names, an then updates
             their modification times with the `touch` command.
- `ptcb.sh`: OS X bash script to convert the contents of the clipboard to plain text.
- `pingplot.sh`: Use gnuplot to plot ping results. uses pingplot.plt
- `pingplot.plt`: gnuplot file for use with pingplot.sh
- `iwlist_csv.sh`: convert the output of a `iwlist scan` command into CSV format
- `iwlist_scan.txt`: an example output of `iwlist scan` output
- `pkglist`: Attempt to list all the (debian/apt) packages that are installed, as
           a request by the user - ie. no depenencies, just the stuff that was
           part of an `apt-get install` or `aptitude install` line.
- `tardir`   Create a compressed archive of a directory, with a timestamp in the name
- `git-reauthor.sh`: Change the authors on git commits.
- `touchpad`: A script to disable the touchpad (on Linux systems) when a mouse is 
           connected. When the mouse is disconnected, the touchpad gets enabled.
           The script does NOT constantly monitor. You have to run it manually.
- `rotmov.sh`: Rotate movies left, right, or 180.
- `do_flac2mp3.sh`: convert all the .flac files in the current directory into
           mp3 files, *and* copy the meta data. This relies on flac2mp3.sh to
           do each individual conversion.
