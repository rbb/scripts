#!/usr/bin/python

import argparse
#import syslog
import sys, os
#import subprocess as sp
import glob
import zipfile
import shutil

from pgmagick.api import Image
from wand.image import Image
#import wand

def main():
    parser = argparse.ArgumentParser(description="unzip an epub archive to a "
            "tmp directory, scale images by 50%, and re-archive as epub.")
    parser.add_argument('-f', '--file', dest='file', action='store',
            default="",
            help='epub file to shrink images in. (REQUIRED argument)')
    parser.add_argument('-d', '--directory', dest='directory', action='store',
            default="/tmp/smaller_epub/",
            help='temporary directory: %(default)s')
    parser.add_argument('-p', '--prefix', dest='prefix', action='store',
            default="smallscale_",
            help='prefix to add to output files: %(default)s')
    parser.add_argument('-w', '--max-width', dest='max_width', action='store',
            type=int,
            default=640,
            help='Max width: %(default)s')
    parser.add_argument('-m', '--max-height', dest='max_height', action='store',
            type=int,
            default=480,
            help='Max height: %(default)s')
    parser.add_argument('-s', '--no-recursive-size', dest='no_recursive_size',
            action='store_true', default=False,
            help='Only half the size of large images once. Default: keep shrinking ' 
                 'the image by half until it is less than the max limits')
    parser.add_argument('-v', '--verbose', dest='verbose', action='store', default=0,
            type=int, metavar = 'N',
            help='Verbosity level. Anything other than 0 for debug info.')
    parser.add_argument('-V', '--verbose_on', dest='verbose_on', action='store_true', 
            default=False,
            help='Set Verbosity level N = 1.')

    args = parser.parse_args()
    if args.verbose_on:
        args.verbose = max(1, args.verbose)

    if not args.file:
        parser.print_help()
        sys.exit()

    fnoext = os.path.splitext( args.file)
    print "fnoext = " +fnoext[0]
    print "fext = " +fnoext[1]
    tmpdir = os.path.join(args.directory, fnoext[0])
    print "tmpdir = " +tmpdir
    if os.path.isdir(tmpdir):
        shutil.rmtree(tmpdir)
    os.makedirs(tmpdir)

    with zipfile.ZipFile(args.file, 'r') as zip_ref:
        zip_ref.extractall(tmpdir)


    for root, dirs, files in os.walk(tmpdir):
        for f in files:
            fpath = os.path.join(root, f) 
            #print "fpath = " +fpath
            flower = f.lower()
            if flower.endswith(".png"):
                 print("-----" +str(fpath))
                 img = Image(filename=fpath)
            elif flower.endswith(".gif"):
                 print("-----" +str(fpath))
                 img = Image(filename=fpath)
            elif flower.endswith(".jpg"):
                 print("-----" +str(fpath))
                 img = Image(filename=fpath)
            else:
                img = False

            if img:
                 print img.width, img.height
                 if not f.startswith(args.prefix):
                     small_file = False
                     fprefix = os.path.join(root, args.prefix +f)
                     while img.width > args.max_width or img.height > args.max_height:
                         width = int(img.width)/2
                         height = int(img.height)/2
                         #img.scale(0.5)        # pgmagick
                         #img.transform('50%')   # wand.image
                         img.resize( width,height )   # wand.image
                         if args.verbose:
                             #print "shrunk "  +f +" image to " +str(img.width) +"x" +str(img.height)
                             print "shrunk "  +f +" image to " +str(img.size)
                         small_file = True
                         if args.no_recursive_size:
                             break
                     if small_file:
                         if args.verbose:
                             print "writing " +str(img.width) +"x" +str(img.height) +" image to " +fprefix
                         #img.write( fprefix )
                         #img.write(fpath)         #pgmagick
                         img.save(filename=fpath)  #wand
    
    fbase = os.path.basename( os.path.abspath(args.file) )
    fdir = os.path.dirname( os.path.abspath(args.file) )
    outfile = os.path.join(fdir, args.prefix +args.file)
    outbase = os.path.join(fdir, args.prefix +fnoext[0])
    print "outbase = " +outbase
    print "outfile = " +outfile
    shutil.make_archive(outbase, 'zip', tmpdir)
    shutil.move(outbase +'.zip', outfile)


if __name__ == '__main__':
    main()


# vim sw=t ts=4
