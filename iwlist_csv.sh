#!/bin/bash
#set -x

# Example: cat iwlist_scan.txt | iwlist_csv.sh > iwlist_scan.csv
# Example: iwlist scan | iwlist_csv.sh > iwlist_scan.csv
# Example: iwlist ath0 scan | iwlist_csv.sh > iwlist_scan.csv

a=0;b=0;c=0;d=0;x=0

while read line
do
     #echo "processing \"$line\""
     [ "`echo $line | grep ESSID`" ] && essid[$a]=`echo "$line" | cut -d : -f 2 |  grep -o '[a-z,A-Z,0-9]*'` && ((a++))
     [ "`echo $line | grep Address`" ] && address[$b]=`echo "$line" | awk '{print $5}'` && ((b++))
     [ "`echo $line | grep Signal`" ] && signal[$c]=`echo "$line" | awk '{print $3}' | awk -F'=' '{print $2}'` && ((c++))
     #[ "`echo $line | grep Frequency`" ] && frequency[$d]=`echo "$line" | awk '{print $1}' | awk -F':' '{print $2}'` && ((d++))
     [ "`echo $line | grep Frequency`" ] && channel[$d]=`echo "$line" | awk '{print $4}' | awk -F')' '{print $1}' ` && ((d++))
done 
#done < <(iwlist scan 2>/dev/null )

echo -e "SSID,\t MAC,\t RSSI,\t Channel"

while [ $x -lt ${#essid[@]} ];do
     echo -e \"${essid[$x]}\", '\t' ${address[$x]}, '\t' ${signal[$x]}, '\t' ${channel[$x]}
     (( x++ ))
done
