#!/usr/bin/env python

"""
A script to compare 2 PADS netlists.
"""

import optparse


#--- Set standard variables ---
VERSION = "0.1"
PROG = "netcomp.py"

#----------------------------------------------------------------------
def parse_netlist(fname, delim=" "):
    """parse the netlist into a python dictionary"""
#----------------------------------------------------------------------

    have_net = False
    net_str = "*NET*"
    signals = {}
    sig = None
    vals = None
    with open(fname) as f:
        for line in f:
            line = line.strip()
            if not have_net:
                # Just continue on until we find the indicator that nets have started
                if line == net_str:
                    have_net = True
            else:
                # OK, we are now dealing with nets
                if "*SIGNAL*" in line:
                    if sig and vals:
                        signals[sig] = vals
                        #print "stored " +sig +": " +str(vals)
                        #print "stored " +str(sig)
                    sig = line.split(delim)[1]
                    vals = None
                elif "*END" in line:
                    signals[sig] = vals
                    break
                else:
                    if vals:
                        for field in line.split(delim):
                            vals.append( field )
                    else:
                        vals = line.split(delim)
    return signals

#----------------------------------------------------------------------
def print_per_pin(key, fname, neta, onlyneta):
    """Given the full set, and the unique set, print the differences"""
#----------------------------------------------------------------------
    percent_unique = float(len(onlyneta)) / float(len(neta))
    print str(key) +": pins in " +fname +" (" +str(len(onlyneta)) +"/" +str(len(neta)) +") are " +str(percent_unique*100.0) +"% uninque."
    if (percent_unique > 0.75 or len(onlyneta) > 10):
        pass
    else:
        print list(onlyneta)
    return percent_unique


#=====================================================================
if __name__ == '__main__':
#=====================================================================
    parser = optparse.OptionParser(description="Compares 2 pads2k style netlists",
            version="%prog " + VERSION, prog=PROG, epilog=PROG +" " +VERSION)

    # parser options reference:
    # http://docs.python.org/library/optparse.html#module-optparse
    parser.add_option("-v", "--verbose",
                      action="store_true", dest="verbose", default=False,
                      help="Set verbose bit, which turns on debug messages [default: %default]")
    parser.add_option("-1", action="store", type="string", dest="file1", default="net1.net",
                      help="First file to compare [default: %default]")
    parser.add_option("-2", action="store", type="string", dest="file2", default="net2.net",
                      help="First file to compare [default: %default]")
    parser.add_option("-d", "--delim",
                      action="store", type="string", dest="delim", default=" ",
                      help="delimiter [default: \"%default\"]")


    (options, args) = parser.parse_args()

    nets1 = parse_netlist(options.file1, options.delim)
    nets2 = parse_netlist(options.file2, options.delim)

    snets1 = set( nets1.keys() )
    snets2 = set( nets2.keys() )

    print "Netlist difference created by " +PROG +"version " +VERSION
    print ""

    print "Nets in " +options.file1 +" but not in " +options.file1 +":"
    only1 = snets1 - snets2
    print list(only1)
    print [ x for x in iter(only1) ]

    print ""

    print "Nets in " +options.file2 +" but not in " +options.file1 +":"
    only2 = snets2 - snets1
    print list(only2)
    print [ x for x in iter(only2) ]
    print ""


    print "Differences within nets"
    bothkeys = snets1 & snets2
    print bothkeys
    print ""
    for key in bothkeys:
        a = set( nets1[key] )
        b = set( nets2[key] )
        if a != b:
            print "------------------------------------------------"
            if len(a&b) < 30:
                print key +" Common Pins: " +str(list(a & b))

            onlya = a - b
            onlyb = b - a

            percent_unique_a = print_per_pin(key, options.file1, a, onlya)
            percent_unique_b = print_per_pin(key, options.file2, b, onlyb)
            print ""


