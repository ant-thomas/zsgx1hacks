#!/bin/sh
#

DIR="$(dirname "$0")"

cp "$DIR"/group /etc/group

# install updated version of busybox
cp /bin/busybox /bin/busybox-orig
cp "$DIR"/busybox-armv6l /bin/busybox
/bin/busybox --install -s

# setup and install dropbear ssh server
cp "$DIR"/dropbearmulti /bin/dropbearmulti
mkdir /etc/dropbear
cp "$DIR"/dropbear_ecdsa_host_key /etc/dropbear/dropbear_ecdsa_host_key
/bin/dropbearmulti dropbear

# update hosts file to prevent communication
cp "$DIR"/hosts.new /etc/hosts

# update the time
ntpd -q -p uk.pool.ntp.org

# wifi creds - currently doesn't work
#cp "$DIR"/wpa_supplicant.conf /home/wpa_supplicant.conf

# update wifi creds - currently doesn't work
#(sleep 20 && "$DIR"/goke_p2pcam_param --wifissid=SSID --wifipass=WIFIPASSKEY ) &

# turn off high pitched noise
(sleep 20 && "$DIR"/goke_volume -s 0 ) &
