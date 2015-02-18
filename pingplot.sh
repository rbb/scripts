#!/bin/sh

#host=${1:-$tmpdir}
host=$1

ping $host | grep "bytes from" --line-buffered| awk 'BEGIN{FS="[ =]"} {print $7 " " $11; system("")}' > /tmp/pingplot.data &
pid=$!
echo "ping pid = $pid"
echo "Waiting 4 seconds for some ping data to be present..."
sleep 4
gnuplot -persist -e "plot '/tmp/pingplot.data' title '$host' w lp" pingplot.plt

echo "Killing ping|awk process $pid"
kill $pid
