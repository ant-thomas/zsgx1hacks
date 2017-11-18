#!/bin/sh
#

cp /mnt/group /etc/group

cp /bin/busybox /bin/busybox-orig
cp /mnt/busybox-armv6l /bin/busybox
/bin/busybox --install -s

cp /mnt/dropbearmulti /bin/dropbearmulti
mkdir /etc/dropbear
cp /mnt/dropbear_ecdsa_host_key /etc/dropbear/dropbear_ecdsa_host_key
/bin/dropbearmulti dropbear                                          

cp /mnt/hosts.new /etc/hosts

cp /mnt/wpa_supplicant.conf /home/wpa_supplicant.conf

/mnt/goke_volume -s 0

(sleep 20 && echo "root:o.eyOMtPAPfbg:0:0:root:/root/:/bin/sh" > /etc/passwd && cat /etc/passwd ) &
(sleep 20 && /mnt/mmc01/0/goke_volume -s 0 ) &                 
(sleep 20 && cp /mnt/mmc01/0/shadow /etc/shadow ) &


