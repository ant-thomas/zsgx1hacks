#!/bin/sh

###########################################################################################################################
## SSH watchdog process: periodically checks the SSH output for changes, if the output is stalled, kills the SSH process ##
## Author DBaluxa                                                                                                        ##
###########################################################################################################################

re='^[0-9]+$'

while true
do
  currdate=`date +%s`
  #echo $currdate
  
  if [ -e /tmp/ssh_chg.log ]
  then 
    lastdate=`/home/busybox/tail -n 1 /tmp/ssh_chg.log`

    if [ -n $lastdate ] 
    then 
      delta=`expr $currdate - $lastdate`
      #echo $delta

      if [ $delta -gt 90 ] 
      then
        echo Current time: `date`, ssh last update: `date -d @$lastdate`
        echo SSH is not responding till $delta secs, killing it...
        kill -9 `ps ax |grep dropbearmulti |grep ssh | /home/busybox/cut -c 1-6`
      fi
    else
      echo Last update date is not number: $lastdate
    fi 
  else
    echo /tmp/ssh_chg.log does not exits!
  fi
  sleep 10
done
echo ERROR:Check process exited
