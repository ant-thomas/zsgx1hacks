#!/bin/sh

######################################################################
# zsgx1 lockdown script
# 
# Creates a basic environment for tinkering with the ZS-GX1 IP camera.
# Very basic for now.
######################################################################

# Warning: 	Please configure this script by editing 'zs-gx1.cfg' to your liking.
# 			The defaults are probably NOT what you want.

# Features
# ========

# Updates the busybox version to 1.26.2 to give us more commands to play with.
# If you don't want to use the binaries from the GIT repository pleased download to SD card from here
# https://busybox.net/downloads/binaries/1.26.2-defconfig-multiarch/busybox-armv6l or build your own.

# Also sets a few basic environment things like a nice prompt ;).

# TODO: Add dropbear

# Note: This uses a LOT of symlinks due to the lack of something sane we can use as an overlay/union FS.

# Binary file hashes:
# MD5: af177e4a17185a5235f9c1a0ea15e1f8 busybox-armv6l

# Vairables
SD_MOUNT=/mnt
USR_NAND=/home/zs-gx1
LOG_DIR=${SD_MOUNT}
LOG_FILE=${LOG_DIR}/log-zs-gx1.txt

# Functions
log_init() {
    # Clear the previous log file
	echo "Starting to log..." > ${LOG_FILE}
	sync
}

log() {
    echo "$@" >> ${LOG_FILE}
    sync
}

get_config() {
    key=$1
    grep $1 ${SD_MOUNT}/zs-gx1.cfg  | cut -d"=" -f2
}

# Init log
log_init
#log "Starting to log..."

# Extracting sound files
log "Extracting sound files..."
tar xzf /home/VOICE.tgz -C /tmp

# Log mount points
log "List of mount points..."
mount >> ${LOG_FILE}

# Create a few directories on the SD to store backups
log "Create some directories on the SD to store backups..."
mkdir ${SD_MOUNT}/backups > ${LOG_FILE}

# Create a few directories on the NAND to store scripts and small binaries
log "Create some directories on the NAND to store scripts and small binaries..."
mkdir ${USR_NAND} > ${LOG_FILE}
mkdir ${USR_NAND}/bin > ${LOG_FILE}
mkdir ${USR_NAND}/etc > ${LOG_FILE}
mkdir ${USR_NAND}/scripts > ${LOG_FILE}
mkdir ${USR_NAND}/profile.d > ${LOG_FILE}

if [ -d ${USR_NAND}/profile.d/ ]; then
  ln -sf ${USR_NAND}/profile.d/ /etc/profile.d
fi

cp ${SD_MOUNT}/change_PS1.sh ${USR_NAND}/profile.d/
cp ${SD_MOUNT}/busybox-armv6l ${USR_NAND}/bin/busybox-armv6l

log "Configuring new Busybox..."
log "* Linking new binary."
if [ -f ${USR_NAND}/bin/busybox-armv6l ]; then
  ln -sf ${USR_NAND}/bin/busybox-armv6l /bin/busybox
fi

# Log mount points
log "List of mount points..."
mount >> ${LOG_FILE}

log "* Installing Busybox symlinks..."
/bin/busybox --install -s

log "* Removing mkfsdos symlinks (Built in closed source binary blob will auto format the SD card otherwise)."
rm -f /bin/mkdosfs
rm -f /sbin/mkdosfs

# Lockdown hosts file
log "Checking if hosts lockdown required:"
if [[ $(get_config LOCKDOWN_HOSTS) == "yes" ]]; then
	log "* Yes: Locking down hosts..."
	cp /etc/hosts ${SD_MOUNT}/backups/hosts.orig
	cp ${SD_MOUNT}/hosts.new ${USR_NAND}/etc/hosts
	log "* Installing new hosts file..."
	if [ -f ${USR_NAND}/etc/hosts ]; then
	  ln -sf ${USR_NAND}/etc/hosts /etc/hosts
	fi
else
	log "* No: Not locking down hosts (NOT RECOMENDED)..."
fi

# Still working on this...
log "Checking if Wireless configuration required:"
if [[ $(get_config CONFIGURE_WIRELESS) == "yes" ]]; then
	#log "Checking for Wireless configuration file..."
	#log $(find /home -name "wpa_supplicant.conf")
	
	#log "* Start Wireless configuration..."
	#res=$(/home/wpa_supplicant -B -i ra0 -c /home/wpa_supplicant.conf )
	#log "* Status for Wireless configuration=$?  (0 is good)"
	#log "* Wireless configuration answer: $res"
else
	log "* No: Wireless configuration untouched"
fi

log "Network configuration as follows..."
ifconfig | sed "s/^/    /" >> ${LOG_FILE}

log "Attempting to automatically set time... (Requires a network link up at this point)"
NTP_SERVER=$(get_config NTP_SERVER)
log "* Test the NTP server '${NTP_SERVER}':"
ping -c1 ${NTP_SERVER} >> ${LOG_FILE}
log "Previous datetime is $(date)"
ntpd -q -p ${NTP_SERVER}
log "New datetime is $(date)"

# Log the shadow files
log "Default Shadow file..."
cat /etc/shadow >> ${LOG_FILE}

# Take a copy of the RO Shadow file for use as our password list
if [ ! -f ${USR_NAND}/etc/shadow ]; then
  cp /etc/shadow ${USR_NAND}/etc/shadow
fi

if [ -f ${USR_NAND}/etc/shadow ]; then
  ln -sf ${USR_NAND}/etc/shadow /etc/shadow
fi

# Wait for things to settle a little
sleep 5

# Set the root password as specified in the config
root_pwd=$(get_config ROOT_PASSWORD)
[ $? -eq 0 ] &&  echo "root:$root_pwd" | chpasswd

# Log the shadow files
log "Modified Shadow file..."
cat /etc/shadow >> ${LOG_FILE}

log "Symlinks in /bin/..."
ls -ls /bin >> ${LOG_FILE}

## update root password to root - login via telnet now possible
(sleep 20 && echo "root:o.eyOMtPAPfbg:0:0:root:/root/:/bin/sh" > /etc/passwd && cat /etc/passwd ) &

# Start FTP server
log "Checking if FTP server required:"
if [[ $(get_config FTP_SERVER) == "yes" ]]; then
	log "* Yes: Starting FTP server..."
	if [[ $(get_config DEBUG) == "yes" ]] ; then
		tcpsvd -vE 0.0.0.0 21 ftpd -w / > /${LOG_DIR}/log_ftp.txt 2>&1 &
	else
		tcpsvd -vE 0.0.0.0 21 ftpd -w / &
	fi
	sleep 1
	log "* Checking for FTP process."
	ps | grep tcpsvd | grep -v grep >> ${LOG_FILE}
else
	log "* No: Skipping FTP server startup..."
fi

# Show filesystem use
log "Filesystem Use..."
df -h >> ${LOG_FILE}

log "Returning control to stock scripts..."

# Make sure logs are written and the file system is flushed
sync
