
#from PIL import Image
import Image
import numpy as np
from scipy import misc
import datetime
import time
import glob
import sys

start_time = datetime.datetime.now()
tic = time.clock()


filelist = glob.glob("*.jpg")
#print filelist

K=len(filelist)

#fname = 'IMG_'+str(start)+'.jpg'
fname = filelist[0]
print 'loading ' +fname
im_first=misc.imread(fname)

X=im_first.shape[0]
Y=im_first.shape[1]
depth = im_first.shape[2]

imar=np.zeros([X,Y,depth,2])
im_max=np.zeros([X,Y,depth])
im_sum=np.zeros([X,Y,depth])
k=0
#for n in range(start, stop):
for fname in filelist:
    print 'Processing ' +fname
    im = misc.imread(fname)
    #im = np.array(Image.open(fname))

    #a = datetime.datetime.now()
    imar[:,:,:,0] = im_max
    imar[:,:,:,1] = im
    #b = datetime.datetime.now()
    im_max = imar.max(3)
    #c = datetime.datetime.now()

    imar[:,:,:,0] = im_sum
    imar[:,:,:,1] = im
    #d = datetime.datetime.now()
    im_sum = imar.sum(3)
    #e = datetime.datetime.now()

    #print str(b-a) +', ' +str(c-b) +', ' +str(d-c) +', ' +str(e-d)

    k+=1

im_mean = im_sum / float(K)

print "Saving Outputs"
misc.imsave('im_max.jpg', im_max);
misc.imsave('im_mean.jpg', im_mean);
#misc.imsave('im_median.jpg', im_median);

end_time = datetime.datetime.now()
toc = time.clock()
print "Elapsed Wall Time:       " +str(end_time - start_time)
print "Elapsed Processing Time: " +str(toc - tic)

# Note: time.clock() might only return processor time on unix systems
