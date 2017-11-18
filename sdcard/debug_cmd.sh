#!/bin/sh
#

cp /mnt/group /etc/group

# install updated version of busybox
cp /bin/busybox /bin/busybox-orig
cp /mnt/busybox-armv6l /bin/busybox
/bin/busybox --install -s

# setup and install dropbear ssh server
cp /mnt/dropbearmulti /bin/dropbearmulti
mkdir /etc/dropbear
cp /mnt/dropbear_ecdsa_host_key /etc/dropbear/dropbear_ecdsa_host_key
/bin/dropbearmulti dropbear                                          

# update hosts file to prevent communication
cp /mnt/hosts.new /etc/hosts

# wifi creds
cp /mnt/wpa_supplicant.conf /home/wpa_supplicant.conf

# update root password to root
(sleep 20 && echo "root:o.eyOMtPAPfbg:0:0:root:/root/:/bin/sh" > /etc/passwd && cat /etc/passwd ) &

# turn off high pitched noise
(sleep 20 && /mnt/mmc01/0/goke_volume -s 0 ) &                 

# update shadow password file
(sleep 20 && cp /mnt/mmc01/0/shadow /etc/shadow ) &


