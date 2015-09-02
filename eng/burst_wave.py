import argparse
import sys

__version__ = '1.0'

def units2float(s):
    if args.verbose >1:
        print "units2float: len(s) = " +str(len(s))
    mult = 1
    c = s[-1]
    if c == 'p':
        mult = 1e-12
    if c == 'n':
        mult = 1e-9
    if c == 'u':
        mult = 1e-6
    if c == 'm':
        mult = 1e-3
    if c == 'k':
        mult = 1e3
    if c == 'M':
        mult = 1e6
    if c == 'g':
        mult = 1e9
    #print mult
    if mult != 1:
        numstr = s[0:-1]
    else:
        numstr = s
    num = float(numstr) * float(mult)
    if args.verbose >0:
        print "units2float: order of mag char = '" +c +"' numstr = '" +numstr +"' = " +str(num)
    return num

    #print s[-1]

if __name__ == "__main__":
    graph_str = "\n          |----------------- period ----------|\n"
    graph_str  += "          |-----on_time --|                   |\n"
    graph_str  += "          |               |                   |\n"
    graph_str  += "          | /-------------\                   /--------------\n"
    graph_str  += "          |/ |            |\                 /\n"
    graph_str  += "   _______/  |            | \_______________/\n"
    graph_str  += "          |  |            |  |\n"
    graph_str  += "          rise            fall\n"
    graph_str  += "\n"
    graph_str  += "\n"
    graph_str  += "  init |----- burst   --|--- dead_time ----|\n"
    graph_str  += "    |  |                |                  |\n"
    graph_str  += "    |  |                |                  |\n"
    graph_str  += "   ____|-|__|-|__|-|__|-|__________________|-|__|-|__|-|__|-|__\n"

    desc_str = "The output is a list of timestamps and (string) value pairs, one pair per line. " \
               +"Value strings are specified with the --burst_list option; " \
               +"while --rise, --fall, --period and --on_time determine the timestamps. " \
               +"The intent is to create a (LT)spice pwl file for bursts of data." 

    epilog_str = "Note: This script can also be used to create arbitrary waveforms, in a csv style, using the --delim argument - for possible use in excel or MATLAB/octave"

    parser = argparse.ArgumentParser(description=desc_str, epilog=epilog_str,
            formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-i', '--init', dest='init', type=str, nargs='?',
                       help='initial value', default='0')
    parser.add_argument('-r', '--rise', dest='rise', type=str, nargs='?',
                       help='Rise time', default='2p')
    parser.add_argument('-f', '--fall', dest='fall', type=str, nargs='?',
                       help='Fall time', default='2p')
    parser.add_argument('-p', '--period', dest='period', type=str, nargs='?',
                       help='Total bit period', default='1n')
    parser.add_argument('-o', '--on_time', dest='on_time', type=str, nargs='?',
                       help='On time', default='500p')
    parser.add_argument('-l', '--burst_list', dest='burst_list', type=str, nargs='+',
                       help='Bits in burst', default=['1','0','1','0','1','0','1','1'])
    parser.add_argument('-N', '--num_cycles', dest='num_cycles', type=int, nargs='?',
                       help='Number of cycles', default='10')
    parser.add_argument('-d', '--dead_time', dest='dead_time', type=str, nargs='?',
                       help='Dead time', default='5n')
    parser.add_argument('--delim', dest='delim', type=str, nargs='?',
                       help='delimiter', default='  ')
    parser.add_argument('-V', '--verbose', dest='verbose', type=int, nargs='?',
                       help='Verbosity level (debug level)', default='0')
    parser.add_argument('-v', '--version', action='version', version='%(prog)s '+__version__)

    if '-h' in sys.argv or '--help' in sys.argv:
        print graph_str


    args = parser.parse_args()
    rise = units2float(args.rise)
    fall = units2float(args.fall)
    period = units2float(args.period)
    on_time = units2float(args.on_time)
    dead_time = units2float(args.dead_time)
    num_cycles = args.num_cycles
    if args.verbose > 0:
        print "rise = " +str(rise) +"  fall=" +str(fall) +"  period=" +str(period) +"  on_time=" +str(on_time)
        print "burst_list = " +str(args.burst_list) +"  dead_time=" +str(dead_time) +"  num_cycles=" +str(num_cycles)
        print ""

    t = 0
    print(str(t) +args.delim + args.init)
    old_bit = args.init
    for n in range(args.num_cycles):
        for bit in args.burst_list:
            if bit == '1':
                t += rise
            else:
                t += fall
            print(str(t) +args.delim +bit)

            if bit == '1':
                t += on_time -rise
            else:
                t += period -on_time -fall
            print(str(t) +args.delim +bit)

            old_bit = bit
        t += dead_time

#/cygdrive/f/projects/SeaLancet_AJ_ph2/MDM
#0 0
#1n 1
#2n 0
#3n 1
#4n 0
#5n 1
#6n 0
#7n 1
#8n 0
#9n 1
#10n 0
#101n 1
#102n 0
#103n 1
#104n 0
#105n 1
#106n 0
#107n 1
#108n 0
#109n 1
#110n 0

