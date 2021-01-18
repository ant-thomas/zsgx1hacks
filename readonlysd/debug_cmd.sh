#!/bin/sh

# ANT-THOMAS
############
# HACKS HERE

# mount sd card to separate location
if [ -b /dev/mmcblk0p1 ]; then
	mount -t vfat /dev/mmcblk0p1  /media
elif [ -b /dev/mmcblk0 ]; then
	mount -t vfat /dev/mmcblk0 /media
fi

# confirm hack type
touch /home/HACKSD

# possibly needed but may not be
mount --bind /media/hack/group /etc/group
(sleep 70 && mount --bind /media/hack/passwd /etc/passwd) &
mount --bind /media/hack/shadow /etc/shadow

mkdir -p /home/busybox

# install updated version of busybox
mount --bind /media/hack/busybox /bin/busybox
/bin/busybox --install -s /home/busybox

# set new env
mount --bind /media/hack/profile /etc/profile

# update hosts file to prevent communication
mount --bind /media/hack/hosts.new /etc/hosts

# include config
. /media/config.txt

# busybox httpd
/home/busybox/httpd -p 8080 -h /media/hack/www -r "Identify yourself:" -c /media/hack/httpd.conf

# setup and install dropbear ssh server - password login. hack/shadow file should contain a password!
mkdir /etc/dropbear
ln -s /media/.ssh/authorized_keys /etc/dropbear/authorized_keys
/media/hack/dropbearmulti dropbear -r /media/hack/dropbear_ecdsa_host_key -E >$logdir/dropbear.log 2>&1

# start ftp server
(/home/busybox/tcpsvd -E 0.0.0.0 21 /home/busybox/ftpd -w / ) &

# sync the time
(while true; do sleep 20 && /home/busybox/ntpd -q -p 0.uk.pool.ntp.org; done ) &

# silence the voices - uncomment if needed
#if [ ! -f /home/VOICE-orig.tgz ]; then
#    cp /home/VOICE.tgz /home/VOICE-orig.tgz
#fi
#
#cp /media/hack/VOICE-new.tgz /home/VOICE.tgz

#
############
export PATH=$PATH:/home/busybox

syslogd -O /media/syslog -b 4 -s 512

if [ -n $sshTunnelUser -a -n $sshTunnelServer -a -n $sshTunnelBindAddress ]
then
  ln -s /media/.ssh/ /root/.ssh
  /media/hack/ssh.sh         2>&1 | while IFS= read -r line; do echo "$(date) $line"; done >>$logdir/ssh_error.log    &
  /media/hack/sshwatchdog.sh 2>&1 | while IFS= read -r line; do echo "$(date) $line"; done >>$logdir/ssh_watchdog.log &
fi
/media/hack/ffmpeg.sh    2>&1 | while IFS= read -r line; do echo "$(date) $line"; done >>$logdir/ffmpeg.log    &
/media/hack/loadcheck.sh 2>&1 | while IFS= read -r line; do exho "$(date) $line"; done >>$logdir/load.log      &
/media/hack/videomove.sh 2>&1 | while IFS= read -r line; do echo "$(date) $line"; done >>$logdir/videomove.log &
(while true; do sleep 10; killall telnetd; if [ $? -eq 0 ]; then break; fi; done;) &
