#!/bin/sh

############################################################
# Load monitoring to workaround p2pcam CPU useage problems #
############################################################

maxload=12

#Load monitoring starts only after 20 mins..
sleep 1200

#We check the load every 5 mins
while true
do
  #Field 6 is the 15 min avg load
  load=`uptime | cut -d "," -f 6`
  echo $load

  #Bash does not support float numbers, therefore we use awk
  status=`echo $load HIGH LOW $maxload | awk '{if ($4 < $1) print $2; else print $3;}'`
  if [ $status = HIGH ]
  then
    echo Load is high: $load, rebooting...
    sleep 1
    reboot
  fi
  sleep 300
done

