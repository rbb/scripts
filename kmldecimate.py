import argparse
import datetime

parser = argparse.ArgumentParser(description='retime a path from a kml file')
parser.add_argument('-i', '--ifile', metavar='F', type=str, action='store', default = "First day.kml",
                    help='input file')
parser.add_argument('-o', '--ofile', metavar='F', type=str, action='store', default = None,
                    help='output file')
parser.add_argument('-d', '--interval', metavar='F', type=int, action='store', default = 5,
                    help='output file')

opts = parser.parse_args()
print opts

if opts.ofile:
    ofile = opts.ofile
else:
    ofile = opts.ifile.split('.')[0] +'_dec.' +opts.ifile.split('.')[1]
    print "ofile: " +str(ofile)
fout = open(ofile, 'w')

start = False
inside_track = False
n = 0
last_line = ""
with open(opts.ifile) as f:
    for line in f:
        if "<gx:Track>" in line:
            inside_track = True
        elif "</gx:Track>" in line:
            inside_track = False
            n = 0
        elif "<when>" in last_line and "<gx:coord>" in line:
            n = 0
		
        if ("<when>" in line or "<gx:coord>" in line) and inside_track:
            n = n + 1;
            if n == opts.interval:
               fout.write(line) 
               n = 0
        else:
           fout.write(line) 
        last_line = line



# TODO: handle paths formatted as triplets, like the one below
"""
	<Placemark>
		<name>Path</name>
		<styleUrl>#lineStyle</styleUrl>
		<LineString>
			<tessellate>1</tessellate>
			<coordinates>
				6.960669,45.947431,3242.8 6.960675,45.947429,3242.8 ...
			</coordinates>
		</LineString>
	</Placemark>
"""





