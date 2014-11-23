

flist="*.mov"

for file in $flist
do
   t=`echo $file | cut -d . -f 1|sed s/-//g | cut -c 1-8` 
   #echo "touch -t ${t}0000 $file"
   touch -t ${t}0000 $file
done



