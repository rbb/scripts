import argparse
import datetime

parser = argparse.ArgumentParser(description='retime a path from a kml file')
#parser.add_argument('-i', '--ifile', metavar='F', type=str, action='store', default = "First day.kml",
parser.add_argument('-i', '--ifile', metavar='F', type=str, action='store', default = "20170527 Corral couloir.kml",
                    help='input file')
parser.add_argument('-o', '--ofile', metavar='F', type=str, action='store', default = None,
                    help='output file')
parser.add_argument('-d', '--interval', metavar='F', type=int, action='store', default = 50,
                    help='output file')
#parser.add_argument('--folder', metavar='F', type=str, action='store', default = "Points",
parser.add_argument('--folder', metavar='F', type=str, action='store', default = None,
                    help='Folder name')
#parser.add_argument('--tracks', metavar='F', type=str, action='store', default = Points,
parser.add_argument('--tracks', metavar='F', type=str, action='store', default = None,
                    help='Folder name')

opts = parser.parse_args()
print opts

if opts.ofile:
    ofile = opts.ofile
else:
    ofile = opts.ifile.split('.')[0] +'_dec.' +opts.ifile.split('.')[1]
    print "ofile: " +str(ofile)
fout = open(ofile, 'w')


#--------------------------------------------------------------
def folder2track(s, track_name, dlm="   ", eol="\n"):
#--------------------------------------------------------------
    print "folder2track()"
    track = dlm +"<Placemark>" +eol
    track += dlm +dlm +"<name>" +track_name +"</name>" +eol
    track += dlm +dlm +"<visibility>0</visibility>\n"
    track += dlm +dlm +"<open>1</open>" +eol

    track += """		<StyleMap>
			<Pair>
				<key>normal</key>
				<Style>
					<IconStyle>
						<scale>1</scale>
						<Icon>
							<href>http://maps.google.com/mapfiles/kml/shapes/track.png</href>
						</Icon>
					</IconStyle>
					<LineStyle>
						<color>ff40c4ff</color>
						<width>3</width>
					</LineStyle>
				</Style>
			</Pair>
			<Pair>
				<key>highlight</key>
				<Style>
					<IconStyle>
						<scale>1.33</scale>
						<Icon>
							<href>http://maps.google.com/mapfiles/kml/shapes/track.png</href>
						</Icon>
					</IconStyle>
					<LineStyle>
						<color>ff40c4ff</color>
						<width>4</width>
					</LineStyle>
				</Style>
			</Pair>
		</StyleMap>"""
    track += eol


    track += dlm +dlm +"<gx:Track>" +eol
    coordinates = ""
    times = ""
    for line in s.split("\n"):
        #print "folder2track: line = " +line
        if "<TimeStamp><when>" in line:
            t = line.split('>')[2].split('<')[0]
            #print "folder2track: t = " +t
            times += dlm +dlm +dlm +"<when>"
            times += t
            times += "</when>" +eol
        if "<coordinates>" in line:
            coord = line.split('>')[1].split('<')[0]
            #print "folder2track: coord = " +coord
            coordinates += dlm +dlm +dlm +"<gx:coord>"
            coordinates += coord
            coordinates += "</gx:coord>" +eol

    track += times
    track += coordinates
    track += dlm +dlm +dlm +"<ExtendedData>" +eol
    track += dlm +dlm +dlm +dlm +'<Data name="name">' +eol
    track += dlm +dlm +dlm +dlm +dlm +"<value>" +track_name +"</value>" +eol
    track += dlm +dlm +dlm +dlm +"</Data>" +eol
    track += dlm +dlm +dlm +"</ExtendedData>" +eol
    track += dlm +dlm +"</gx:Track>" +eol
    track += dlm +"</Placemark>" +eol

    return track


if opts.tracks:
    # Handle the case of tracks
    have_track_name = False
    start = False
    inside_track = False
    n = 0
    last_line = ""
    with open(opts.ifile) as f:
        for line in f:
            if "<Placemark>" in last_line and "<name>" in line:
                name = line.split('>')[1].split('<')[0]
                if name == opts.tracks:
                    have_track_name = True
            if "<gx:Track>" in line and have_track_name:
                inside_track = True
            elif "</gx:Track>" in line:
                inside_track = False
                have_track_name = False
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

elif opts.folder:
    # Handle the case of a folder of placemarks
    dec_tracks = ""
    folder_out_str = ""
    store_folder = False
    have_folder_name = False
    name = False
    placemark = False
    n = opts.interval
    last_line = ""
    with open(opts.ifile) as f:
        for line in f:
            if "</Folder>" in line:
                name = False
                if have_folder_name:
                    store_folder = True
                    dec_tracks = folder2track(folder_out_str, "dec_tracks")
                have_folder_name = False
            if "</Folder>" in last_line:
                store_folder = False

            if "<Folder>" in last_line and "<name>" in line:
                name = line.split('>')[1].split('<')[0]
                print "folder name = " +str(name)
                if name == opts.folder:
                    have_folder_name = True
                    folder_out_str += last_line
                    store_folder = True

            if have_folder_name:
                if "</Placemark>" in last_line:
                   placemark = False
                   store_folder = False
                if "<Placemark>" in line:
                    placemark = True
                    n = n + 1;
                    if n >= opts.interval:
                       store_folder = True
                       n = 0
                    else:
                       store_folder = False
                    #print str(n) +"    " +str(placemark) +"    " +str(store_folder)

                #print "hfn " +str(n) +"    " +str(placemark) +"    " +str(store_folder)

            if store_folder:
                if "<Folder>" in last_line and "<name>" in line:
                    folder_out_str += line.replace(name, name+"_dec")
                    leading_space = line[:len(line)-len(line.lstrip())]
                    folder_out_str += leading_space +"<visibility>0</visibility>\n"
                elif "<Placemark>" in last_line and "<name>" in line:
                    folder_out_str += line
                    leading_space = line[:len(line)-len(line.lstrip())]
                    folder_out_str += leading_space +"<visibility>0</visibility>\n"
                else:
                    folder_out_str += line
            if "</Document>" in line:
                fout.write(folder_out_str)
                fout.write(dec_tracks)
                #print dec_tracks
            fout.write(line) 

            last_line = line


else:
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





