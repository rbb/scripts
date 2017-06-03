import argparse
import datetime
import sys

parser = argparse.ArgumentParser(description='retime a path from a kml file')
parser.add_argument('-i', '--ifile', metavar='F', type=str, action='store', default = "First day.kml",
                    help='input file')
parser.add_argument('-o', '--ofile', metavar='F', type=str, action='store', default = None,
                    help='output file. Leave blank for stdout, use "-" to append "_retime" to input filename')
parser.add_argument('-t', '--timeincr', metavar='F', type=str, action='store', default = "min",
                    help='time increment [sec|min|hour]')

opts = parser.parse_args()
print opts

ofile = None
fout = None
if opts.ofile:
    if opts.ofile[0] == "-":
        ofile = opts.ifile.split('.')[0] +'_retime.' +opts.ifile.split('.')[1]
        print "ofile: " +str(ofile)
    else:
        ofile = opts.ofile
    fout = open(ofile, 'w')
else:
    fout = sys.stdout

start = False
inside_track = False
with open(opts.ifile) as f:
    for line in f:
        if "<gx:Track>" in line:
            inside_track = True
        elif "</gx:Track>" in line:
            inside_track = False
            start = False
		
        if "<when>" in line and inside_track:
            n_leading_spaces = len(line) - len(line.lstrip())
            leading_spaces = ''
            for n in range(n_leading_spaces):
                leading_spaces = leading_spaces + line[0]
            if not start:
                s = line.split('>')[1].split('<')[0]
                print "Start Time: " +str(s)
                s = s.split('T')
                d = s[0].split('-')
                year = int(d[0])
                month = int(d[1])
                day = int(d[2])

                tline = s[1].split(':')
                hour = int(tline[0])
                minute = int(tline[1])
                #second = int(tline[2].split('Z')[0])
                second = int(tline[2][0:-1])

                timezone = tline[2][-1]

                #print ",".join([year, month, day, hour, minute, second])
                start = datetime.datetime(year,month,day,hour,minute,second)
                t = start
            else:
                if opts.timeincr[0] == 's':
                    delta = datetime.timedelta(0,1)
                elif opts.timeincr[0] == 'm':
                    delta = datetime.timedelta(0,60)
                elif opts.timeincr[0] == 'h':
                    delta = datetime.timedelta(0,3600)
                t = t + delta
            #print "time: " +str(timenow)
            lineout = leading_spaces +t.strftime("<when>%Y-%m-%dT%H:%M:%S") +timezone +"</when>\n"
            #print lineout
            fout.write(lineout)
        else:
           fout.write(line) 


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





