#!/bin/sh
#

# include config
. /mnt/config.txt

if [ "$VOICE" = "YES" ]; then
rm /home/VOICEOFF
rm /home/VOICEON
touch /home/VOICEOFF
else
rm /home/VOICEOFF
rm /home/VOICEON
touch /home/VOICEON
fi


if [ "$RESTORE" = "YES" ]; then
 /mnt/restore.sh

elif [ "$PERSISTENT" = "YES" ];then
rm /home/HACKP
rm /home/HACKSD
touch /home/HACKP
 /mnt/persistenthack.sh

elif [ ! "$PERSISTENT" = "YES" ];then
rm /home/HACKP
rm /home/HACKSD
touch /home/HACKSD
 /mnt/sdcardhack.sh
fi 




