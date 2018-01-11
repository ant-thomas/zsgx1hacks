#!/bin/sh
#

DIR="$(dirname "$0")"

if [ $DIR = /home/sdcard ]; then
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
else
	# make folder for storing files
	# and backup original start.sh script
	if [ ! -d /home/sdcard ]; then
		mkdir /home/sdcard
		cp /home/start.sh /home/sdcard/start_orig.sh
	fi

	# copy files over
	cp "$DIR"/* /home/sdcard/

	# Patch start.sh script to look in /home/sdcard/
	sed '\;/mnt/debug_cmd\.sh$;a\
elif [ -f "/home/sdcard/debug_cmd.sh" ]; then\
	 /home/sdcard/debug_cmd.sh' \
		/home/sdcard/start_orig.sh > /home/start.sh

	# call us again from the new location
	exec /home/sdcard/debug_cmd.sh
fi
