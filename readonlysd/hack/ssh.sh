#!/bin/sh

##################################
## Build SSH tunnel to a host   ##
## Author: DBaluxa              ##
##################################

# include config
. /media/config.txt

HOME=/root
tunnelPort=`echo $sshTunnelBindAddress | cut -d : -f 2`
sshKillCmd='if [ `sudo netstat -tlpn | grep :'"$tunnelPort"' | grep sshd |wc -l` -gt 0 ]; then echo Killing sshd...; nohup sh -c "(sleep 5 ; sudo killall sshd ; sudo /etc/init.d/ssh restart)" >/dev/null 2>&1 &  fi; exit'

rm /tmp/ssh_chg.log
sleep 40

while true
do
	date +%s >/tmp/ssh_chg.log
	
	#Check if there is sticky non-working tunnel, and if there is one, restart SSHD to get rid of it
        /media/hack/dropbearmulti ssh -i /media/.ssh/rsa.id $sshTunnelUser@$sshTunnelServer $sshKillCmd </dev/zero >/tmp/pfcheck.log
        success=$?
        cat /tmp/pfcheck.log
        if [ $success -eq 0 ]
        then 
           echo Successfull testconnect, starting portfoward...
           if [ `grep Killing /tmp/pfcheck.log | wc -l` -gt 0 ]
           then
             echo Waiting for SSHD restart...
             sleep 10
           fi
	   /media/hack/dropbearmulti ssh -i /media/.ssh/rsa.id -T -R $sshTunnelBindAddress:localhost:8001 $sshTunnelUser@$sshTunnelServer "while true; do date +%s; sleep 40; done" </dev/zero >>/tmp/ssh_chg.log
        fi
	rm /tmp/ssh_chg.log
	sleep 10
done

