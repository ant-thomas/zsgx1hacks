#!/bin/sh

#ANT-THOMAS

getHwInfo()
{
	grep $1 /home/hardinfo.bin | awk -F '>'  '{print $2}' | awk -F '<' '{print $1}'
}

getHwCfg()
{
	grep $1 /home/hwcfg.ini | awk '{printf $3}'
}

#check if stop app auto run
read -t 1 -p "Press 'q' in 1 seconds to exit: " q
if [ $? -eq 0 -a "$q" = "q" ]; then exit; fi


if [ -f /home/wpa_supplicant ]; then
	rm -f /bin/wpa_supplicant
	ln -s /home/wpa_supplicant /bin/wpa_supplicant
fi

cp -f /home/tees /bin
chmod -R 777 /home

#init isp
/home/sensor.sh

#check if old sc1135
#or if ii2 3229 is 2
mirror_type=$(getHwCfg gk_mirror_type)
if [ "$mirror_type" = "1" ]; then   
echo "sensor do not support vi mirror! check sensor_hw.bin"
mv -f /home/sensors/sc1135_hw.bin_old_10bits /home/sensors/sc1135_hw.bin
fi

#check if 1080, modify uboot args
/home/check_mem.sh

#drivers
insmod /home/gio.ko && mdev -s

#run custom init for board OEM
/home/custom_init.sh

BOARD_ID=$(getHwInfo BoardType)

#mount SD card
if [ -b /dev/mmcblk0p1 ]; then
	mount -t vfat /dev/mmcblk0p1  /mnt
elif [ -b /dev/mmcblk0 ]; then
	mount -t vfat /dev/mmcblk0 /mnt
fi

#upgrade firmware
if [ -f /mnt/firmware.bin ]; then
	sdc_tool -d $BOARD_ID -c /home/model.ini /mnt/firmware.bin

	#check upgrade from OTA or factory test
	if [ -f /mnt/OTA ]; then
		rm /mnt/firmware.bin
		rm /mnt/OTA
	else
		touch /opt/upgrading
	fi
fi

#Run facoty_tool.sh for burn id and change voice and change hwcfg.ini
/home/factory_tool.sh

#Run debug_cmd.sh
if [ -f "/mnt/debug_cmd.sh" ]; then
	echo "find debug cmd file, wait for cmd running..."
	/mnt/debug_cmd.sh
fi

############
# HACKS HERE

cp /home/hack/group /etc/group

# install updated version of busybox
cp /bin/busybox /bin/busybox-orig
cp /home/hack/busybox-armv6l /bin/busybox
/bin/busybox --install -s

# busybox httpd
busybox httpd -p 8080 -h /home/hack/www

# setup and install dropbear ssh server
cp /home/hack/dropbearmulti /bin/dropbearmulti
mkdir /etc/dropbear
cp /home/hack/dropbear_ecdsa_host_key /etc/dropbear/dropbear_ecdsa_host_key
/bin/dropbearmulti dropbear

# update hosts file to prevent communication
cp /home/hack/hosts.new /etc/hosts

# start ftp server
(tcpsvd -E 0.0.0.0 21 ftpd / ) &

# sync the time
(sleep 20 && ntpd -q -p 0.uk.pool.ntp.org ) &

# silence the voices
if [ ! -f /home/VOICE-orig.tgz ]; then
    cp /home/VOICE.tgz /home/VOICE-orig.tgz
fi

cp /home/hack/VOICE-new.tgz /home/VOICE.tgz

# turn off high pitched noise
(sleep 20 && /home/hack/goke_volume -s 0 ) &


#
############



umount /mnt

#update form flash
if [ -f /home/firmware.bin ]; then
	/bin/sdc_tool -d $BOARD_ID /home/firmware.bin
	if [ $? -eq 0 ]; then
		echo "upgrade success."
	else
		echo "upgrade failed."
	fi
	rm -f /home/firmware.bin
fi

#network init 
wifi_type=$(getHwCfg wifi_type)
if [ "$wifi_type" = "7601" ]; then 
insmod /home/mt7601Usta.ko
else
insmod /home/8188fu.ko
fi
sleep 1
ifconfig lo 127.0.0.1
ifconfig wlan0 up
ifconfig ra0 up
ifconfig eth0 up

#check if old sc1135
#or if ii2 3229 is 2
mirror_type=$(getHwCfg gk_mirror_type)
if [ "$mirror_type" = "1" ]; then
echo "sensor do not support vi mirror! check sensor_hw.bin"
mv -f /home/sensors/sc1135_hw.bin_old_10bits /home/sensors/sc1135_hw.bin
fi

#run tees for debug info
tees -s -v -b 20 -e ps -e 'ifconfig; route -n' -e 'wpa_cli status' -e 'mount' -e 'uptime' -e 'df' -e 'netstat -napt' -e free -a /tmp/closelicamera.log -o /mnt/mmc01/1/ipc.log -o /mnt/mmc01/0/ipc.log -O /tmp/upipc.log & (cat /proc/kmsg | /tmp/tees) &

#upzip files
tar -zxf /home/p2pcam.tar.gz -C /tmp
tar xzf /home/VOICE.tgz -C /tmp
if [ -f /tmp/VOICE/OVERSEA ]; then
cp /home/cloud_oversea.ini /tmp/cloud.ini
else
cp /home/cloud.ini /tmp
fi
cp /home/ca-bundle-add-closeli.crt /tmp


#init ptz
ptz_mcu=$(getHwCfg ptz_mcu)
has_ptz=$(getHwCfg support_ptz)
if [ "$ptz_mcu" = "1" ]; then
	mv -f /home/gkptz-dsa.ko /home/gkptz.ko
fi

if [ "$has_ptz" = "1" ]; then
	if [ -f /home/silent_reboot ]; then NO_SLFCK=1; rm /home/silent_reboot; else NO_SLFCK=0; fi
	insmod /home/gkptz.ko cfg_file=/home/ptz.cfg psp_file=/home/psp.dat no_selfck=$NO_SLFCK
fi

#wpa_supplicant -B -iwlan0 -c /home/wpa_supplicant.conf_EYERD &

mdev -s

cd /tmp
(
export CLOSELICAMERA_LOGMAXLINE=1000
./p2pcam; killall -10 tees)&
(
sleep 5
rm -f p2pcam

sync; echo 3 > /proc/sys/vm/drop_caches
free
)&
