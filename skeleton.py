#!/usr/bin/python

import argparse
#import syslog
#import sys, os
#import subprocess as sp
#import glob


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--filename', dest='filename', action='store', default="uptime.rrd",
            help='IP address of Kymeta antenna default: %(default)s')
    parser.add_argument('-b', '--boolean', dest='boolean', action='store_false', default=True,
            help='Boolean flag')
    parser.add_argument('-v', '--verbose', dest='verbose', action='store', default=0,
            type=int, metavar = 'N',
            help='Verbosity level. Anything other than 0 for debug info.')
    parser.add_argument('-V', '--verbose_on', dest='verbose_on', action='store_true', 
            default=False,
            help='Set Verbosity level N = 1.')

    args = parser.parse_args()
    if args.verbose_on:
        args.verbose = max(1, args.verbose)

if __name__ == '__main__':
    main()
