#!/bin/sh
#

#remove hack files
rm -rf /home/hack

#restore original start.sh
cp /home/start.sh.orig /home/start.sh

#restore original VOICE.tgz
cp /home/VOICE-orig.tgz /home/VOICE.tgz

#Rename debug_cmd.sh to prevent it running again
mv /mnt/debug_cmd.sh /mnt/debug_cmd.sh.restore

#reboot to apply hacks
reboot      



