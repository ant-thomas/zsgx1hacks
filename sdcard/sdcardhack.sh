#!/bin/sh

#ANT-THOMAS
############
# HACKS HERE

# mount sd card to separate location
if [ -b /dev/mmcblk0p1 ]; then
	mount -t vfat /dev/mmcblk0p1  /media
elif [ -b /dev/mmcblk0 ]; then
	mount -t vfat /dev/mmcblk0 /media
fi

cp /media/hack/group /etc/group

# install updated version of busybox
cp /bin/busybox /bin/busybox-orig
cp /media/hack/busybox-armv6l /bin/busybox
/bin/busybox --install -s

# busybox httpd
busybox httpd -p 8080 -h /media/hack/www

# setup and install dropbear ssh server
#cp /media/hack/dropbearmulti /bin/dropbearmulti
mkdir /etc/dropbear
cp /media/hack/dropbear_ecdsa_host_key /etc/dropbear/dropbear_ecdsa_host_key
/media/hack/dropbearmulti dropbear

# update hosts file to prevent communication
cp /media/hack/hosts.new /etc/hosts

# start ftp server
(tcpsvd -E 0.0.0.0 21 ftpd -w / ) &

# sync the time
(sleep 20 && ntpd -q -p 0.uk.pool.ntp.org ) &

# silence the voices
if [ ! -f /home/VOICE-orig.tgz ]; then
    cp /home/VOICE.tgz /home/VOICE-orig.tgz
fi

if [ -f /home/VOICEOFF ]; then
cp /media/hack/VOICE-new.tgz /home/VOICE.tgz
fi

# turn off high pitched noise
(sleep 20 && /media/hack/goke_volume -s 0 ) &

#
############
