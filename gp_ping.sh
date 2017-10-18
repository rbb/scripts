#!/bin/bash

# Plotting ping results, using gnuplot
# Inspired by:
#     http://hxcaine.com/blog/2013/02/28/running-gnuplot-as-a-live-graph-with-automatic-updates/ 
#     http://www.grant-trebbin.com/2013/04/logging-and-graphing-ping-from-linux.html

host=${1:-"localhost"}

fdata="/tmp/gp_ping_$host.txt"
fplot="/tmp/gp_ping_$host.plt"
fpng="/tmp/gp_ping_$host.png"

echo "DISPLAY = $DISPLAY"

DATE=$(date +%Y_%m_%e_%H_%M_%S)    #get date YYYY_MM_DD_HH_MM_SS
echo "$DATE, 0, 0" > $fdata

if [ -z "$DISPLAY" ]; then
   echo "set terminal dumb 121 28" > $fplot
else
   #echo "set term x11 1 noraise title \"gp_ping $host\"" > $fplot
   echo "set term png; set output \"$fpng\"" > $fplot
fi
cat << EOF >> $fplot
set datafile separator ","
set multiplot layout 2,1 rowsfirst
unset mouse
# ---- RTT Plot
set ylabel 'avg rtt (ms)'
set xdata time
set timefmt "%Y_%m_%d_%H_%M_%S"
#set format x ""
unset key
set grid
plot "$fdata" using 1:2 with lines
# ---- PL Plot
set ylabel 'Packet Loss (%)'
set xdata time
set timefmt "%Y_%m_%d_%H_%M_%S"
set xtics rotate
unset key
set grid
plot "$fdata" using 1:3 with lines
# ----- Loooping
unset multiplot
pause 1
reread
EOF

#if [ -z "$DISPLAY" ]; then
#   gnuplot -persist $fplot &
#else
#   gnuplot $fplot &
#fi
gnuplot $fplot > /dev/null 2>&1 &
open $fpng

#$ ping -c 3 aws-iperf
#PING aws-iperf (54.186.205.190) 56(84) bytes of data.
#64 bytes from aws-iperf (54.186.205.190): icmp_seq=1 ttl=40 time=628 ms
#64 bytes from aws-iperf (54.186.205.190): icmp_seq=2 ttl=40 time=637 ms
#64 bytes from aws-iperf (54.186.205.190): icmp_seq=3 ttl=40 time=640 ms
#
#--- aws-iperf ping statistics ---
#3 packets transmitted, 3 received, 0% packet loss, time 1999ms
#rtt min/avg/max/mdev = 628.275/635.111/640.051/5.033 ms


while true; do
   DATE=$(date +%Y_%m_%e_%H_%M_%S)    #get date YYYY_MM_DD_HH_MM_SS
   resp=$(ping -c 3 $host|awk -F '[ /%]' '/rtt/{avg=$8} /loss/{pl=$6} END{print avg, pl}')
   #echo "resp = $resp"
   avg=$(echo $resp | awk '{print $1}')
   pl=$(echo $resp | awk '{print $2}')
   if [ ! -z "$DISPLAY" ]; then
      #echo "DATE = $DATE"
      #echo "rtt = $rtt"
      echo "$DATE   $avg   $pl"
      #echo "avg = $avg"
   fi

   echo "$DATE, $avg, $pl" >> $fdata

   #echo ""
done

#echo "averages = ${averages[@]}"
#echo "${averages[@]}"| gnuplot -persist -e "set terminal dumb 121 28; set yrange[00:400]; plot '-' with impulses title 'Ping (ms)';"
#echo "${averages[@]}"| gnuplot persist -e "set terminal dumb 121 28; plot '-' with impulses title 'Ping (ms)';"

