# Updates the busybox version - download to SD card from here
# https://busybox.net/downloads/binaries/1.21.1/busybox-armv6l

# makes backup of original busybox
cp /bin/busybox /bin/busybox-orig
# copies new busybox binary
cp /mnt/busybox-armv6l /bin/busybox

# makes backup of original hosts file
cp /etc/hosts /etc/hosts.orig
# copies new hosts file blocking cloud services
cp /mnt/hosts.new /etc/hosts

# update root password to root - login via telnet now possible
(sleep 20 && echo "root:o.eyOMtPAPfbg:0:0:root:/root/:/bin/sh" > /etc/passwd && cat /etc/passwd ) &
