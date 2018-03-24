#!/bin/sh
#

#Copy hack files
mkdir /home/hack
cp -R /mnt/hack/* /home/hack/

#Copy new hack start.sh
if [ ! -f /home/start.sh.orig ]; then
  cp /home/start.sh /home/start.sh.orig
fi

cp /mnt/start.sh /home/start.sh 

#Rename debug_cmd.sh to prevent it running again
mv /mnt/debug_cmd.sh /mnt/debug_cmd.sh.hack

#reboot to apply hacks
reboot      



